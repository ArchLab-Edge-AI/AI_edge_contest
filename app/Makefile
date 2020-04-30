.PHONY: run clean

all:
	g++ -std=c++11 -O3 -mcpu=cortex-a53 -ffast-math -I. -o demo_yolov3_tiny demo_yolov3_tiny.cpp -lopencv_core -lopencv_video -lopencv_videoio -lopencv_imgproc -lopencv_imgcodecs -lopencv_highgui -lglog -lxnnpp -ldpproto -lprotobuf -ldpbase -lpthread

run:
	time ./demo_yolov3_tiny ~/test_images/ -1
	cat result[0-9].txt > result.txt
	python3 convert_json_submit2.py

clean:
	rm -f result*.txt
