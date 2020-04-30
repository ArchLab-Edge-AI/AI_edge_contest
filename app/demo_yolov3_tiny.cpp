/*
 * Copyright 2019 Xilinx Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <glog/logging.h>
#include <google/protobuf/text_format.h>
#include <cmath>
#include <iostream>
#include <future>
#include <thread>
#include <numeric>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <xilinx/ai/dpu_task.hpp>
#include <xilinx/ai/nnpp/yolov3.hpp>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdbool.h>
#include <dirent.h>

#include <mutex>
std::mutex mtx_;

using namespace std;
using namespace cv;

#define IMAGEDIR argv[1]
// #define IMAGEDIR "/home/root/dataset/image500_640_480/"
#define ORIG_WIDTH 1936
#define ORIG_HEIGHT 1216
#define IMAGE_WIDTH 416
#define IMAGE_HEIGHT 416
#define KERNEL_NAME "tinyyolov3"

#define THREADS 2
#define BLOCK_SIZE 50

const char *yolov3_config = {
    "   name: \"tinyyolov3\" \n"
    "   model_type : YOLOv3 \n"
    "   yolo_v3_param { \n"
    "     num_classes: 10 \n"
    "     anchorCnt: 3 \n"
    "     conf_threshold: 0.25 \n"
    "     nms_threshold: 0.45 \n"
    "     biases: 10 \n"
    "     biases: 14 \n"
    "     biases: 23 \n"
    "     biases: 27 \n"
    "     biases: 37 \n"
    "     biases: 58 \n"
    "     biases: 81 \n"
    "     biases: 82 \n"
    "     biases: 135 \n"
    "     biases: 169 \n"
    "     biases: 344 \n"
    "     biases: 319 \n"
    "     test_mAP: false \n"
    "   } \n"};

xilinx::ai::proto::DpuModelParam dpu_config;

int image_num;
string img_dir;

#define SLEEP 1
int t_cnt = 0;
void barrier(int tid){
    {
        std::lock_guard<std::mutex> lock(mtx_);
        t_cnt++;
    }
    while(1){
        {
            std::lock_guard<std::mutex> lock(mtx_);
            if(t_cnt % THREADS == 0) break;
        }
        usleep(SLEEP);
    }
}
/*std::condition_variable cv_;
void barrier2(int tid){
    {
        std::unique_lock<std::mutex> uniq_lk(mtx_);
        t_cnt++;
        cv_.wait(uniq_lk, []{return t_cnt % THREADS == 0;});
    }
    cv_.notify_all();
}*/

inline double etime_sum(timespec ts02, timespec ts01){
    return (ts02.tv_sec+(double)ts02.tv_nsec/(double)1000000000)
            - (ts01.tv_sec+(double)ts01.tv_nsec/(double)1000000000);
}

std::vector<string> img_filenames;

vector<string> ListImages(const char *path) {
    vector<string> images;
    images.clear();
    struct dirent *entry;

    /*Check if path is a valid directory path. */
    struct stat s;
    lstat(path, &s);
    if (!S_ISDIR(s.st_mode)) {
        fprintf(stderr, "Error: %s is not a valid directory!\n", path);
        exit(1);
    }

    DIR *dir = opendir(path);
    if (dir == nullptr) {
        fprintf(stderr, "Error: Open %s path failed.\n", path);
        exit(1);
    }

    while ((entry = readdir(dir)) != nullptr) {
        if (entry->d_type == DT_REG || entry->d_type == DT_UNKNOWN) {
            string name = entry->d_name;
            string ext = name.substr(name.find_last_of(".") + 1);
            if ((ext == "JPEG") || (ext == "jpeg") || (ext == "JPG") ||
                (ext == "jpg") || (ext == "PNG") || (ext == "png")) {
                images.push_back(name);
            }
        }
    }

    closedir(dir);
    sort(images.begin(), images.end());

    return images;
}

int main_thread(int s_num, int e_num, int tid) {

    struct timespec ts01, ts02, ts03, tt01, tt02;
    double sum1 = 0, sum2 = 0, sum3 = 0, sumt = 0;

    string filename = "result" + std::to_string(tid) + ".txt";
    FILE *fp = fopen(filename.c_str(), "w");

    auto task = [] {
        std::lock_guard<std::mutex> lock(mtx_);         // Important!
        return xilinx::ai::DpuTask::create(KERNEL_NAME);
    }();
    task->setMeanScaleBGR({0.0f, 0.0f, 0.0f}, {0.00390625f, 0.00390625f, 0.00390625f});

    auto input_tensor = task->getInputTensor(0);
    CHECK_EQ((int)input_tensor.size(), 1)
        << " the dpu model must have only one input";

    const auto size = cv::Size(IMAGE_WIDTH, IMAGE_HEIGHT); // Set image size

    string image_file_name[BLOCK_SIZE];
    cv::Mat input_image[BLOCK_SIZE];

    // Main Loop
    int cnt=0;
    for(cnt=s_num; cnt<=e_num; cnt+=BLOCK_SIZE){
        clock_gettime(CLOCK_REALTIME, &ts01);

        for(int i=0; i<BLOCK_SIZE;i++){
            if(cnt+i>e_num) break;

            image_file_name[i] = img_filenames[cnt+i];
            input_image[i] = cv::imread(img_dir+image_file_name[i]);
            if (input_image[i].empty()) {
                printf("cannot load %s%s\n", img_dir, image_file_name[i].c_str());
                abort();
            }
        }

        barrier(tid);
        
        usleep(1000);
        clock_gettime(CLOCK_REALTIME, &ts02);
        sum1 += etime_sum(ts02,ts01);
        barrier(tid);

        for(int i=0; i<BLOCK_SIZE;i++){
            if(cnt+i>e_num) break;
            // Resize the image, Begin B
            cv::Mat image;
            cv::resize(input_image[i], image, size);

            // Set the input image into dpu and run, Begin C
            task->setImageRGB(image);
            {
                std::lock_guard<std::mutex> lock(mtx_);
                //clock_gettime(CLOCK_REALTIME, &tt01);
                task->run(0);
                //clock_gettime(CLOCK_REALTIME, &tt02);
            }
            // Get output
            const auto output_tensor = task->getOutputTensor(0);
            const auto results = xilinx::ai::yolov3_post_process(
                input_tensor, output_tensor, dpu_config, ORIG_WIDTH, ORIG_HEIGHT);

            for (auto& box : results.bboxes) {
                float xmin = box.x * ORIG_WIDTH + 1;
                float ymin = box.y * ORIG_HEIGHT + 1;
                float xmax = xmin + box.width * ORIG_WIDTH;
                float ymax = ymin + box.height * ORIG_HEIGHT;
                if (xmin < 0.) xmin = 1.;
                if (ymin < 0.) ymin = 1.;
                if (xmax > ORIG_WIDTH) xmax = ORIG_WIDTH;
                if (ymax > ORIG_HEIGHT) ymax = ORIG_HEIGHT;
                fprintf(fp, "%s %d %d %d %d %d\n", image_file_name[i].c_str(), box.label, (int)xmin, (int)ymin, (int)xmax, (int)ymax);
            }
            double tmp_time = etime_sum(tt02, tt01);
            sumt += tmp_time;//etime_sum(ts03, ts02);
            //printf("%s | count : %4d %d \t | %8.3lf[ms]\n", image_file_name[i].c_str(), cnt, tid, tmp_time*1000); // For Debug

        }
        barrier(tid);
        clock_gettime(CLOCK_REALTIME, &ts03);
        sum2 += etime_sum(ts03, ts02);
        sum3 += etime_sum(ts03, ts01);
    }
    fclose(fp);

    printf("sum1       : %8.3lf[s]\n", sum1);
    printf("sum2       : %8.3lf[s]\n", sum2);
    printf("FPS        : %8.3lf (%8.3lf [ms])\n", (float)image_num/sum2, (float)sum2/image_num*1000);
    //printf("dpu_runtime: %8.3lf[ms]\n", (float)sumt/(image_num/THREADS)*1000);
    fflush(stdout);

    int tmp = image_num%(THREADS*BLOCK_SIZE);
    //printf("%d %d\n", tid, tmp);
    if(tid >= tmp){
        usleep(SLEEP);
        barrier(tid);
        usleep(SLEEP);
        barrier(tid);
        usleep(SLEEP);
        barrier(tid);
    }

    return 0;
}

int main(int argc, char* argv[]) {
    printf("AI Edge Contest Application V058\n");
    printf("Usage: %s dir_name image_num_per_thread\n", argv[0]);
    if(argc!=3) return 0;

    // Set dpu_config
    auto ok = google::protobuf::TextFormat::ParseFromString(yolov3_config, &dpu_config);
    if (!ok) {
        cerr << "Set parameters failed!" << endl;
        abort();
    }

    // Get image Num
    int run_num = atoi(argv[2]);
    img_dir = IMAGEDIR;
    img_filenames = ListImages(IMAGEDIR);
    image_num = (run_num < 0) ? img_filenames.size() : run_num;

    // Calc start & end id of each thread
    int th_srt[THREADS];
    int th_end[THREADS];
    th_srt[0] = 0;
    th_end[0] = image_num / THREADS;
    if((image_num%THREADS)==0) {
        th_end[0]--;
    }
    for(int i=1;i<THREADS;i++){
        th_srt[i] = th_end[i-1]+1;
        th_end[i] = th_srt[i]+(image_num / THREADS);
        if(i>=(image_num%THREADS)){
            th_end[i]--;
        }
    }
    //if(image_num-1!=th_end[THREADS-1]){
    //    printf("Something wrong: image_num %d, th_end[%d]+1=%d\n", image_num, THREADS-1, th_end[THREADS-1]+1);
        for(int i=0;i<THREADS;i++){
            printf("th_srt[%d] = %d, th_end[%d] = %d\n", i, th_srt[i], i, th_end[i]);
        }
    //    exit(1);
    //}
    //printf("CHECK: image_num %d, th_end[%d]+1=%d\n", image_num, THREADS-1, th_end[THREADS-1]+1);


    vector<thread> ths;
    for (int i = 1; i < THREADS; i++){
        ths.emplace_back(thread(main_thread, th_srt[i], th_end[i], i));
    }
    main_thread(th_srt[0], th_end[0], 0);

    for (auto& th: ths){
        th.join();
    }

    return 0;
}
