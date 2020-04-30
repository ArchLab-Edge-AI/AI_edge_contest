#!/bin/bash
mkdir ultra96v2_oob
cd ultra96v2_oob

git clone -b 2019.2 https://github.com/Xilinx/Vitis_Embedded_Platform_Source.git
cp -rf ./Vitis_Embedded_Platform_Source/Xilinx_Official_Platforms/zcu102_base/* .
mkdir hdl
mkdir petalinux_oob
mkdir bdf
mkdir download
cd download
#download Git
git clone -b 2019.1 https://github.com/Avnet/petalinux.git
git clone -b 2019.1 https://github.com/Avnet/hdl.git
#make work directory
mkdir ../hdl/Boards
mkdir ../hdl/IP
mkdir ../hdl/Projects
mkdir ../hdl/Scripts
mkdir ../hdl/Scripts/ProjectScripts
mkdir ../petalinux_oob/scripts
mkdir ../petalinux_oob/configs
mkdir ../petalinux_oob/configs/device-tree
mkdir ../petalinux_oob/configs/kernel
mkdir ../petalinux_oob/configs/meta-user
mkdir ../petalinux_oob/configs/project
mkdir ../petalinux_oob/configs/rootfs
mkdir ../petalinux_oob/configs/u-boot

#copy files
cp -rf hdl/Boards/ULTRA96V2 ../hdl/Boards
cp -rf hdl/IP/PWM_w_Int ../hdl/IP
cp -rf hdl/Projects/ultra96v2_oob ../hdl/Projects
cp hdl/Scripts/make_ultra96v2_oob.tcl ../hdl/Scripts
cp hdl/Scripts/make.tcl ../hdl/Scripts
cp hdl/Scripts/bin_helper.tcl ../hdl/Scripts
cp hdl/Scripts/ProjectScripts/ultra96v2_oob.tcl ../hdl/Scripts/ProjectScripts
cp hdl/Scripts/tag.tcl ../hdl/Scripts

cp petalinux/scripts/make_ultra96v2_oob_bsp.sh ../petalinux_oob/scripts
cp petalinux/configs/device-tree/system-user.dtsi.ULTRA96V2 ../petalinux_oob/configs/device-tree
cp petalinux/configs/kernel/user.cfg.ULTRA96V2 ../petalinux_oob/configs/kernel
cp -rf petalinux/configs/meta-user/ultra96v2_oob ../petalinux_oob/configs/meta-user
cp petalinux/configs/project/config.ultra96v2_oob.patch ../petalinux_oob/configs/project
cp petalinux/configs/project/config.sd_ext4_boot.patch ../petalinux_oob/configs/project
cp petalinux/configs/rootfs/config.ultra96v2_oob ../petalinux_oob/configs/rootfs
cp petalinux/configs/u-boot/platform-top.h.ultra96v2_sd_boot ../petalinux_oob/configs/u-boot
cp petalinux/configs/u-boot/bsp.cfg ../petalinux_oob/configs/u-boot

cd ..

#change vivado 
cd vivado
mv zcu102_base_xsa.tcl ultra96v2_oob_xsa.tcl.bak

cat ultra96v2_oob_xsa.tcl.bak | sed -e 's/zcu102_base/ultra96v2_oob/g' -e 's/zcu102/ultra96/g' > ultra96v2_oob_xsa.tcl1.bak
cat ultra96v2_oob_xsa.tcl1.bak | sed -e '43i   source ../hdl/Boards/ULTRA96V2/ultra96v2_oob.tcl -notrace' | sed -e '44i avnet_create_project ultra96v2_oob ultra96v2_oob Project' | sed -e '45i set_property board_part em.avnet.com:ultra96v2:part0:1.0 [current_project]' | sed -e '47,51d' > ultra96v2_oob_xsa.tcl2.bak
cat ultra96v2_oob_xsa.tcl2.bak | sed -e '47i set_property ip_repo_paths  ../hdl/IP [current_fileset]' | sed -e '48i update_ip_catalog' | sed -e '388,1890d' | sed -e '388i  avnet_add_ps_preset ultra96v2_oob ultra96v2_oob ultra96v2_oob' |  sed -e '389i set_property name ps_e [get_bd_cells zynq_ultra_ps_e_0]' |  sed -e '431i avnet_add_user_io_preset ultra96v2_oob ultra96v2_oob ultra96v2_oob' > ultra96v2_oob_xsa.tcl3.bak
cat ultra96v2_oob_xsa.tcl3.bak | sed -e '439s/set i 1/set i 10/g' | sed -e '469i add_files -fileset constrs_1 -norecurse ../hdl/Projects/ultra96v2_oob/ultra96v2_oob.xdc'| sed -e '470i import_files -fileset constrs_1 ../hdl/Projects/ultra96v2_oob/ultra96v2_oob.xdc' > ultra96v2_oob_xsa.tcl4.bak
cat ultra96v2_oob_xsa.tcl4.bak | sed -e 's/-jobs 16/-jobs 6/g' > ultra96v2_oob_xsa.tcl5.bak
cat ultra96v2_oob_xsa.tcl5.bak | sed -e 's/CONFIG.CLKOUT1_JITTER {107.579}/CONFIG.CLKOUT1_JITTER {89.612}/g' -e 's/CONFIG.CLKOUT2_JITTER {94.872}/CONFIG.CLKOUT2_JITTER {79.341}/g' -e 's/CONFIG.CLKOUT3_JITTER {122.171}/CONFIG.CLKOUT3_JITTER {101.340}/g' -e 's/CONFIG.CLKOUT4_JITTER {115.843}/CONFIG.CLKOUT4_JITTER {72.605}/g' -e 's/CONFIG.CLKOUT5_JITTER {102.096}/CONFIG.CLKOUT5_JITTER {81.911}/g' | sed -e 's/PHASE_ERROR {87.187}/PHASE_ERROR {76.967}/g' -e 's/CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {100.000}/CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {500.000}/g' -e 's/CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {200.000}/CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {250.000}/g' | sed -e 's/CONFIG.CLKOUT6_USED {true}/CONFIG.CLKOUT6_USED {false}/g' -e 's/CONFIG.CLKOUT7_USED {true}/CONFIG.CLKOUT7_USED {false}/g' | sed -e 's/CONFIG.MMCM_CLKFBOUT_MULT_F {12.000}/CONFIG.MMCM_CLKFBOUT_MULT_F {15.000}/g' -e 's/CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000}/CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000}/g' -e 's/CONFIG.MMCM_CLKOUT1_DIVIDE {4}/CONFIG.MMCM_CLKOUT1_DIVIDE {5}/g' -e 's/CONFIG.MMCM_CLKOUT2_DIVIDE {16}/CONFIG.MMCM_CLKOUT2_DIVIDE {20}/g' -e 's/CONFIG.MMCM_CLKOUT3_DIVIDE {12}/CONFIG.MMCM_CLKOUT3_DIVIDE {3}/g' -e 's/CONFIG.MMCM_CLKOUT4_DIVIDE {6}/CONFIG.MMCM_CLKOUT4_DIVIDE {6}/g' -e 's/CONFIG.NUM_OUT_CLKS {7}/CONFIG.NUM_OUT_CLKS {5}/g' | sed -e 's/  set proc_sys_reset_5/# set proc_sys_reset_5/g' -e 's/  set proc_sys_reset_6/# set proc_sys_reset_6/g' -e 's/  connect_bd_net -net Net/# connect_bd_net -net Net/g' -e '404i   connect_bd_net -net Net [get_bd_pins clk_wiz_0/resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins proc_sys_reset_2/ext_reset_in] [get_bd_pins proc_sys_reset_3/ext_reset_in] [get_bd_pins proc_sys_reset_4/ext_reset_in] [get_bd_pins ps_e/pl_resetn0]' | sed -e 's/  connect_bd_net -net clk_wiz_0_clk_out7/# connect_bd_net -net clk_wiz_0_clk_out7/g' -e 's/  connect_bd_net -net clk_wiz_0_clk_out8/# connect_bd_net -net clk_wiz_0_clk_out8/g' -e 's/  connect_bd_net -net clk_wiz_0_locked/# connect_bd_net -net clk_wiz_0_locked/g' -e '413i   connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked] [get_bd_pins proc_sys_reset_1/dcm_locked] [get_bd_pins proc_sys_reset_2/dcm_locked] [get_bd_pins proc_sys_reset_3/dcm_locked] [get_bd_pins proc_sys_reset_4/dcm_locked]' | sed -e 's/  set_property PFM.CLOCK/# set_property PFM.CLOCK/g' -e '435i   set_property PFM.CLOCK {clk_out1 {id "0" is_default "true" proc_sys_reset "proc_sys_reset_0" status "fixed"} clk_out2 {id "1" is_default "false" proc_sys_reset "proc_sys_reset_1" status "fixed"} clk_out3 {id "2" is_default "false" proc_sys_reset "/proc_sys_reset_2" status "fixed"} clk_out4 {id "3" is_default "false" proc_sys_reset "/proc_sys_reset_3" status "fixed"} clk_out5 {id "4" is_default "false" proc_sys_reset "/proc_sys_reset_4" status "fixed"}} [get_bd_cells /clk_wiz_0]' > ultra96v2_oob_xsa.tcl
rm *.bak

#Chang directory for script
cd ..
cd hdl/Boards/ULTRA96V2
mv ultra96v2_oob.tcl ultra96v2_oob.tcl.bak
cat ultra96v2_oob.tcl.bak | sed -e '68,71d' | sed -e '442,444d' | sed -e '479i startgroup' | sed  -e '480i set_property -dict [list CONFIG.PSU__USE__M_AXI_GP1 {0}] [get_bd_cells zynq_ultra_ps_e_0]' | sed   -e '481i set_property -dict [list CONFIG.PSU__USE__M_AXI_GP2 {1}] [get_bd_cells zynq_ultra_ps_e_0]' | sed -e '482i set_property -dict [list CONFIG.PSU__USE__S_AXI_GP5 {1}] [get_bd_cells zynq_ultra_ps_e_0]' | sed -e  '483i endgroup' > ultra96v2_oob.tcl1.bak
cat ultra96v2_oob.tcl1.bak | sed -e  '462,464d' | sed -e '61,77d' | sed -e '61i delete_bd_objs [get_bd_nets axi_intc_0_irq]' | sed -e '62i startgroup' | sed -e '63i create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0' | sed -e '64i endgroup' | sed -e '65i set_property -dict [list CONFIG.NUM_PORTS {1}] [get_bd_cells xlconcat_0]' | sed -e '66i connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins ps_e/pl_ps_irq0]' | sed -e '67i connect_bd_net [get_bd_pins axi_intc_0/irq] [get_bd_pins xlconcat_0/In0]' > ultra96v2_oob.tcl2.bak
cat ultra96v2_oob.tcl2.bak | sed -e  's/zynq_ultra_ps_e_0\/pl_clk0 (100 MHz)/clk_wiz_0\/clk_out3 (75 MHz)/g' -e  's/zynq_ultra_ps_e_0\/M_AXI_HPM0_FPD/ps_e\/M_AXI_HPM0_LPD/g' -e 's/ps8_0_axi_periph/interconnect_axilite/g' > ultra96v2_oob.tcl3.bak
cat ultra96v2_oob.tcl3.bak | sed -e '243,249d' | sed -e '244d' | sed -e 's/CONFIG.NUM_PORTS {5}/CONFIG.NUM_PORTS {6}/g' -e 's/xlconcat_0\/In4/xlconcat_0\/In5/g' -e 's/xlconcat_0\/In3/xlconcat_0\/In4/g' -e 's/xlconcat_0\/In2/xlconcat_0\/In3/g' -e 's/xlconcat_0\/In1/xlconcat_0\/In2/g' -e '240,250s/xlconcat_0\/In0/xlconcat_0\/In1/g' | sed -e '243,424s/zynq_ultra_ps_e_0/ps_e/g' > ultra96v2_oob.tcl4.bak
mv ultra96v2_oob.tcl4.bak ultra96v2_oob.tcl
rm *.bak

cd ../../../..

#cp -rf vivado ultra96v2_oob
cd ultra96v2_oob/vivado
make PLATFORM=ultra96v2_oob
#cp ../../ultra96v2_oob.xsa .
cd ../../

## copy vivado 
cp ultra96v2_oob/vivado/ultra96v2_oob.xsa ultra96v2_oob/petalinux

cd ultra96v2_oob/petalinux
make refresh_hw XSA_DIR=../vivado

cd project-spec/configs
mv config config.bak
mv rootfs_config rootfs_config.bak

cat config.bak | sed -e 's/PSU_UART_0_/PSU_UART_1_/g' -e 's/# CONFIG_SUBSYSTEM_SERIAL_PSU_UART_1_SELECT is not set/# CONFIG_SUBSYSTEM_SERIAL_PSU_UART_0_SELECT is not set/g' -e 's/psu_uart_0/psu_uart_1/g' -e 's/cadence/cadence1/g' > config1.bak
cat config1.bak | sed -e 's/zcu102-rev1.0/avnet-ultra96-rev1/g' -e 's/xilinx_zynqmp_zcu102_rev1_0_defconfig/avnet_ultra96_rev1_defconfig/g' -e 's/xilinx-zcu102/ultra96v2-oob/g' -e 's/zcu102-zynqmp/ultra96-zynqmp/g' -e 's/CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_1_SELECT=y/CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_0_SELECT=y/g' -e 's/# CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_0_SELECT is not set/# CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_1_SELECT is not set/g' > config2.bak
cat config2.bak | sed -e 's/CONFIG_SUBSYSTEM_ROOTFS_INITRAMFS=y/# CONFIG_SUBSYSTEM_ROOTFS_INITRAMFS is not set/g' -e 's/# CONFIG_SUBSYSTEM_ROOTFS_EXT is not set/CONFIG_SUBSYSTEM_ROOTFS_EXT=y/g' -e 's/115200 clk_ignore_unused/115200 clk_ignore_unused root=\/dev\/mmcblk0p2 rw rootwait/g' | sed -e '182i CONFIG_SUBSYSTEM_SDROOT_DEV="/dev/mmcblk0p2"' > config3.bak
cat rootfs_config.bak | sed -e 's/# CONFIG_bc is not set/CONFIG_bc=y/g' -e 's/# CONFIG_i2c-tools is not set/CONFIG_i2c-tools=y/g' -e 's/# CONFIG_usbutils is not set/CONFIG_usbutils=y/g' -e 's/# CONFIG_ethtool is not set/CONFIG_ethtool=y/g' -e  's/# CONFIG_git is not set/CONFIG_git=y/g' > rootfs_config1.bak
cat rootfs_config1.bak | sed -e 's/# CONFIG_coreutils is not set/CONFIG_coreutils=y/g' -e 's/# CONFIG_openamp-fw-echo-testd is not set/CONFIG_openamp-fw-echo-testd=y/g' -e 's/# CONFIG_openamp-fw-mat-muld is not set/CONFIG_openamp-fw-mat-muld=y/g' -e 's/# CONFIG_openamp-fw-rpc-demo is not set/CONFIG_openamp-fw-rpc-demo=y/g' > rootfs_config2.bak
cat rootfs_config2.bak | sed -e 's/# CONFIG_packagegroup-petalinux is not set/CONFIG_packagegroup-petalinux=y/g' -e 's/# CONFIG_packagegroup-petalinux-benchmarks is not set/CONFIG_packagegroup-petalinux-benchmarks=y/g' -e 's/# CONFIG_packagegroup-petalinux-matchbox is not set/CONFIG_packagegroup-petalinux-matchbox=y/g' > rootfs_config3.bak
cat rootfs_config3.bak | sed -e 's/# CONFIG_packagegroup-petalinux-openamp is not set/CONFIG_packagegroup-petalinux-openamp=y/g' -e 's/# CONFIG_packagegroup-petalinux-self-hosted is not set/CONFIG_packagegroup-petalinux-self-hosted=y/g' -e 's/# CONFIG_packagegroup-petalinux-utils is not set/CONFIG_packagegroup-petalinux-utils=y/g' -e 's/# CONFIG_packagegroup-petalinux-v4lutils is not set/CONFIG_packagegroup-petalinux-v4lutils=y/g' -e 's/# CONFIG_packagegroup-petalinux-x11 is not set/CONFIG_packagegroup-petalinux-x11=y/g' -e 's/# CONFIG_imagefeature-package-management is not set/CONFIG_imagefeature-package-management=y/g' > rootfs_config4.bak
cat rootfs_config4.bak | sed -e '$a CONFIG_wilc=y' -e '$a CONFIG_libftdi=y' -e '$a CONFIG_bonniePLUSPLUS=y' -e '$a CONFIG_cmake=y' -e '$a CONFIG_iperf3=y' -e '$a CONFIG_iw=y' -e '$a CONFIG_lmsensors-sensorsdetect=y' -e '$a CONFIG_nano=y' -e '$a CONFIG_packagegroup-base-extended=y' -e '$a CONFIG_packagegroup-petalinux-96boards-sensors=y' -e '$a CONFIG_packagegroup-petalinux-ultra96-webapp=y' -e '$a CONFIG_python-pyserial=y' -e '$a CONFIG_python3-pip=y' -e '$a CONFIG_ultra96-ap-setup=y' -e '$a CONFIG_ultra96-misc=y' -e '$a CONFIG_wilc-firmware-wilc3000=y' -e '$a CONFIG_ultra96-radio-leds=y' -e '$a CONFIG_ultra96-wpa=y' -e '$a CONFIG_sds-lib=y' -e '$a CONFIG_wilc3000-fw=y'  -e '$a CONFIG_ultra96-startup-pages=y'  > rootfs_config5.bak
cat rootfs_config5.bak | sed -e 's/# CONFIG_packagegroup-petalinux-weston is not set/CONFIG_packagegroup-petalinux-weston=y/g' > rootfs_config6.bak
mv config3.bak config
mv rootfs_config6.bak rootfs_config
rm *.bak

cd ..
#meta-user/recipes-kernel/linux/linux-xlnx/user_2019-10-31-20-33-00.cfg

cd meta-user/recipes-bsp/device-tree/
cp ../../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/device-tree/device-tree.bbappend .
cd files
cp -rf ../../../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/device-tree/files/multi-arch .
cat system-user.dtsi | sed -e '1,25d' > system-user.dtsi.bak
cat ../../../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/device-tree/files/system-user.dtsi system-user.dtsi.bak > system-user.dtsi
cat openamp.dtsi | sed -e '1,42d' > openamp.dtsi.bak
cat ../../../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/device-tree/files/openamp.dtsi | sed -e '56,57d' > openamp.dtsi1.bak
cat openamp.dtsi1.bak openamp.dtsi.bak > openamp.dtsi
cp ../../../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/device-tree/files/xen.dtsi .
cp ../../../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/device-tree/files/zynqmp-qemu-arm.dts .
rm *.bak

cd ../../..

#meta-user copy
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-core .
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-graphics .
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-modules .
mkdir recipes-utils 
cd recipes-utils 
cp -rf ../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-utils/ultra96-radio-leds .
cp -rf ../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-utils/ultra96-wpa .
cp -rf ../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-utils/ultra96-ap-setup .
cd ..
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-apps/sds-lib recipes-apps
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/u-boot recipes-bsp
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/pmu-firmware recipes-bsp
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/ultra96-misc recipes-bsp
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-bsp/wilc3000-fw recipes-bsp
cp -rf ../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-kernel .

cd conf
mv petalinuxbsp.conf petalinuxbsp.conf.bak
mv user-rootfsconfig user-rootfsconfig.bak 
mv ../../../../petalinux_oob/configs/meta-user/ultra96v2_oob/recipes-core/images/petalinux-image-full.bbappend petalinux-image-full.bbappend.bak
cat petalinuxbsp.conf.bak | sed -e '$a MACHINE_FEATURES_remove_ultra96-zynqmp = "mipi"' -e '$a DISTRO_FEATURES_append = " bluez5 dbus"' -e '$a PREFERRED_VERSION_wilc-firmware = "15.2" ' > petalinuxbsp.conf
cat petalinux-image-full.bbappend.bak | sed -e '3,4d' | sed -e '/#/d' | sed -e "/^[<space><tab>]*$/d" | sed -e 's/IMAGE_INSTALL_append = " /CONFIG_/g' -e 's/"//g' > user-rootfsconfig1.bak
cat user-rootfsconfig.bak user-rootfsconfig1.bak | sed  -e '$a CONFIG_ultra96-startup-pages'  > user-rootfsconfig
rm *.bak
cd ..

cd recipes-kernel/linux

mv linux-xlnx_%.bbappend linux-xlnx_%.bbappend.bak
cat  linux-xlnx_%.bbappend.bak | sed -e '3iSRC_URI += "file://user.cfg"' > linux-xlnx_%.bbappend
rm *.bak

cd ../..

cd recipes-kernel/linux/linux-xlnx
mv user_2019-10-31-20-33-00.cfg user_2019-10-31-20-33-00.cfg.bak
cat user_2019-10-31-20-33-00.cfg.bak | sed -e 's/CONFIG_CMA_SIZE_MBYTES=1024/CONFIG_CMA_SIZE_MBYTES=512/g'  > user_2019-10-31-20-33-00.cfg
cd ../../../../..

make all XSA_DIR=../vivado PLATFORM=ultra96v2_oob
make sysroot
cd ..

mv Makefile Makefile.bak
cat Makefile.bak | sed -e 's/zcu102_base/ultra96v2_oob/g' > Makefile
rm *.bak
mv scripts/zcu102_base_pfm.tcl scripts/ultra96v2_oob_pfm.tcl
make pfm

cd ..

if [ ! -d sd_card ]; then
    mkdir sd_card
    mkdir sd_card/boot 
    mkdir sd_card/rootfs
fi
cp ultra96v2_oob/petalinux/images/linux/image.ub ultra96v2_oob/petalinux/images/linux/BOOT.BIN ultra96v2_oob/petalinux/images/linux/system.dtb sd_card/boot
cp ultra96v2_oob/petalinux/images/linux/rootfs.tar.gz sd_card/rootfs 

rm -rf /tmp/zcu102_base-2019.10.21-10.17.36-v3a
