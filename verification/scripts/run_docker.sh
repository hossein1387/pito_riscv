xhost + 127.0.0.1
open -a xQuartz
docker run -it --cpuset-cpus="0-3" -h xilinx_container -e DISPLAY=docker.for.mac.localhost:0 -v /Volumes/MySD/sdx:/local/xilinx/ -v /Users/Hossein/MyRepos/pito_riscv/:/root/MyRepos/pito_riscv/ hossein1387/xilinx-tools-installed
