#!/bin/bash

if [ ! -d Vitis-ai ]; then
    git clone https://github.com/Xilinx/Vitis-AI.git
    cd Vitis-AI
    git checkout a0cb80b55630ec955af266878e8a445ffce0961c
    cd ..
fi
export TRD_HOME=$PWD/Vitis-AI/DPU-TRD
export SDX_PLATFORM=ultra96v2_oob/platform_repo/ultra96v2_oob/export/ultra96v2_oob/ultra96v2_oob.xpfm
cd Vitis-AI/DPU-TRD/prj/Vitis
mv dpu_conf.vh dpu_conf.vh.bak
cat dpu_conf.vh.bak | sed -e 's/ine B4096/ine B1600/g' -e 's/POOL_AVG_ENABLE/POOL_AVG_DISABLE/g' -e 's/DWCV_ENABLE/DWCV_DISABLE/g' -e 's/DSP48_USAGE_LOW/DSP48_USAGE_HIGH/g' > dpu_conf.vh
cd config_file
mv prj_config prj_config.bak
cat prj_config.bak | sed -e 's/freqHz=300000000:dpu_xrt_top_2.aclk/#freqHz=300000000:dpu_xrt_top_2.aclk/g' -e 's/freqHz=600000000:dpu_xrt_top_2.ap_clk_2/#freqHz=600000000:dpu_xrt_top_2.aclk/g' | sed -e 's/300000000/250000000/g' -e 's/600000000/500000000/g' -e 's/sp=dpu_xrt_top_2/#sp=dpu_xrt_top_2/g' -e 's/nk=dpu_xrt_top:2/nk=dpu_xrt_top:1/g' | sed -e 's/Performance_Explore/Performance_ExtraTimingOpt/g' -e '27i prop=run.synth_1.strategy=Flow_AreaOptimized_high' > prj_config
cd ..
#make KERNEL=DPU DEVICE=ultra96v2
make KERNEL=DPU_SM DEVICE=ultra96v2
#cd ../../../../
#cp Vitis-AI/DPU-TRD/prj/Vitis/binary_container_1/dpu.xo .
#cp -r /platform/sd_card .
#cp -r Vitis-AI/DPU-TRD/prj/Vitis/binary_container_1/sd_card/* sd_card/boot

