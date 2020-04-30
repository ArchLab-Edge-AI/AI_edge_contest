# YOLOv3-tinyのモデルについて

このディレクトリのファイル構成は以下の通り

- model/
  - readme.txt                           : このファイル
  - darknet/
    - yolov3-tiny-obj_A.cfg              : darknetでのYOLOv3-tinyのconfigファイル
    - yolov3-tiny-obj_A.weights          : darknetでのYOLOv3-tinyのweightファイル
  - caffe/
    - yolov3-tiny_A.prototxt             : caffeに変換されたYOLOv3-tinyのconfigファイル
    - yolov3-tiny_A.caffemodel           : caffeに変換されたYOLOv3-tinyのweightファイル
    - yolov3-tiny_A_quantized.prototxt   : 量子化されたYOLOv3-tinyのcaffeのconfigファイル
    - yolov3-tiny_A_quantized.caffemodel : 量子化されたYOLOv3-tinyのcaffeのweightファイル
  - kernel/
    - dpu-11-18-2019-18-45.dcf           : 設計したプラットフォームのハードウェア情報ファイル
    - dpu_tinyyolov3.elf                 : コンパイルされたYOLOv3-tinyのDPUカーネル

darknetの環境は以下を用いた

- https://github.com/AlexeyAB/darknet

darknetモデルからcaffeモデルへの変換ツールは以下を用いた

- https://github.com/Xilinx/Edge-AI-Platform-Tutorials/tree/3.1/docs/Darknet-Caffe-Conversion

caffeモデルの量子化とコンパイルは以下を用いた

- https://github.com/Xilinx/Vitis-AI
