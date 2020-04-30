# ハードウェアプラットフォームの再現方法

ハードウェアプラットフォームの作成方法からSDカードの作成方法まで以下で説明する

ハードウェアプラットフォーム設計には以下のサイトを参考にした

- https://qiita.com/basaro_k/items/e71a7fcb1125cf8df7d2

## このディレクトリのファイル構成

- platform/
  - readme.txt          : このファイル
  - ultra96x_vitis.sh   : Vitisでハードウェアプラットフォームを作成するスクリプト
  - ultra96x_vitisai.sh : Vitis-AIを使用したDPUのビルドとハードウェアプラットフォームへの組み込みを行うスクリプト

## 必要な環境の構築

以下のサイトを参考にVitis，XRT，ボードファイル，Petalinuxのインストールを行い，環境変数の設定を行う

- https://qiita.com/basaro_k/items/86811ed78397d2a3b4b1

以下を参照してDockerの環境も構築しておく

- https://github.com/Xilinx/Vitis-AI/

## ハードウェアプラットフォームの作成

(1) ultra96x_vitis.shを実行してベースとなるハードウェアプラットフォームを作成する

```
$ source ultra96x_vitis.sh
```

## Vitis-AIを使用したDPUのビルドとハードウェアプラットフォームへの組み込み

(1) ultra96x_vitisai.shの「SDX_PLATFORM」を適切に変更する

ultra96x_vitis.shを実行したディレクトリと同じディレクトリで作業を行う場合は変更は不要


(2) ultra96x_vitisai.shを実行する

```
$ source ultra96x_vitisai.sh
```

動作周波数の制約を満たさないため，ビルドが失敗したというメッセージが表示される

(3) プラットフォームを設計するVivadoのプロジェクトファイルを開く

```
$ vivado Vitis-AI/DPU-TRD/prj/Vitis/binary_container_1/link/vivado/vpl/prj/prj.xpr
```

(4) 「Open Block Design」を選択しプラットフォームのブロックデザインを開く

(5) ブロックデザインから不要なIPの削除を行う

VivadoのTcl Consoleで以下のコマンドを実行する

```
delete_bd_objs [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTA] [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTB] [get_bd_cells axi_bram_ctrl_0_bram]
delete_bd_objs [get_bd_intf_nets interconnect_axilite_M01_AXI] [get_bd_cells axi_bram_ctrl_0]
delete_bd_objs [get_bd_intf_nets interconnect_axihpm0fpd_M00_AXI] [get_bd_cells axi_register_slice_0]
delete_bd_objs [get_bd_intf_nets ps_e_M_AXI_HPM0_FPD] [get_bd_cells interconnect_axihpm0fpd]
delete_bd_objs [get_bd_intf_nets interconnect_axilite_M09_AXI] [get_bd_cells system_management_wiz_0]
```

(6) ブロックデザインを保存してウィンドウを閉じる

(7) 「Generate Bitstream」を選択し論理合成，配置配線，ビットストリームの生成を行う

今度は制約を満たし，ビットストリームの生成が完了したというメッセージが表示される

(8) 再ビルドを途中から始めるためにMakefileを編集する

以下のコマンドを実行してディレクトリを移動

```
$ cd Vitis-AI/DPU-TRD/prj/Vitis
$ cp Makefile Makeflie.old
```

ディレクトリ内のMakefileを以下のように修正する

```
70c70
<       v++ $(XOCC_OPTS) -l --temp_dir binary_container_1 --log_dir binary_container_1/logs --remote_ip_cache binary_container_1/ip_cache -o "$@" $(+)
---
>       v++ $(XOCC_OPTS) -l --temp_dir binary_container_1 --log_dir binary_container_1/logs --remote_ip_cache binary_container_1/ip_cache -o "$@" $(+) --from_step rtdgen
```

(9) 以下のコマンドを実行してDPUの再ビルドを行う

```
$ make KERNEL=DPU_SM DEVICE=ultra96v2
```

今度はビルドが成功したというメッセージが表示される

(10) 必要なファイルをまとめる

ultra96x_vitis.shとultra96x_vitisai.shを実行したディレクトリが同一の場合は以下のコマンドを実行

```
$ cd ../../../../
$ cp Vitis-AI/DPU-TRD/prj/Vitis/binary_container_1/dpu.xo .
$ cp -r Vitis-AI/DPU-TRD/prj/Vitis/binary_container_1/sd_card/* sd_card/boot
```

それ以外の場合はパスを適切に変更

## SDカードの作成と必要なファイルのコピー

(1) SDカードのパーティションを作成

以下のサイトを参考にしてパーティションを分割する

- https://qiita.com/yoshiyasu1111/items/e734eba7a842e3ba422d

添付したsd.imgは以下のパーティションとなっている

- 第1パーティション : vfat,  1GB, boot領域
- 第2パーティション : ext4, 11GB, root領域

(2) ビルドしたプラットフォームの必要ファイルをSDカードにコピー

sd_card/bootの内容をSDカードのvfatでフォーマットされたboot領域にコピー
sd_card/rootの内容をSDカードのext4でフォーマットされたroot領域にコピー

SDカードのboot領域を/media/$USER/bootに，root領域を/media/$USER/rootにマウントした場合，以下のコマンドを実行

```
$ cp ./sd_card/boot/* /media/$USER/boot
$ sudo tar -C /media/$USER/root -xzvf ./sd_card/rootfs/rootfs.tar.gz
```

(3) Xilinxが提供しているVitis AI runtimeからライブラリをコピー

Vitis-AIのGitHubリポジトリをクローンし以下のコマンドを実行

```
cd Vitis-AI
./docker_run.sh xilinx/vitis-ai:runtime-1.0.0-cpu
```

SDカードのroot領域を/media/$USER/rootにマウントした場合，以下のコマンドを実行してライブラリをコピー

```
$ cp -r /opt/vitis_ai/xilinx_vai_board_package /media/$USER/root/home/root
$ cp -r /opt/vitis_ai/petalinux_sdk/sysroots/aarch64-xilinx-linux/usr/lib /media/$USER/root/usr/lib/vitisai
```

(4) ライブラリのパスを通す

SDカードのroot領域内の/etc/ld.so.confを編集して/usr/lib/vitisaiを追加

(5) コンテストの画像ファイルとDPUカーネルのelfファイルを含むアプリケーションをSDカードのroot領域にコピー

(6) SDカードを挿入したUltra96v2を起動後にVitis-AIライブラリのインストールを行う

先述のxilinx_vai_board_packageをホームディレクトリにコピーしている場合，以下のコマンドを実行してライブラリをインストール

```
$ cd ~/xilinx_vai_board_package/
$ ./initall.sh
```
