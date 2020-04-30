# YOLOv3-tinyの推論アプリケーションについて

このディレクトリのファイル構成は以下の通り

- app/
  - readme.txt              : このファイル
  - convert_json_submit2.py : アプリケーションの出力結果を提出用のjsonフォーマットに変換するアプリケーション
  - demo_yolov3_tiny        : アプリケーションの実行可能ファイル
  - demo_yolov3_tiny.cpp    : アプリケーションのソースコードファイル
  - Makefile                : アプリケーションの実行に用いるMakefile
  - tinyyolov3/
    - dpu_tinyyolov3.elf    : YOLOv3-tinyのDPUカーネル
    - meta.json             : DPUカーネルなどの情報を記載した設定ファイル
    - yolov3-tiny.prototxt  : アプリケーションの構造上必要な空のダミーファイル

アプリケーションのコンパイルには以下を用いた

- https://github.com/Xilinx/Vitis-AI
