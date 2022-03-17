![alt text](https://github.com/hossein1387/pito_riscv/blob/master/doc/pics/MVU_CORE%20-%20Barelled.png)

# pito_riscv
A pito version of rv32i 


# How to Run:
First make sure the Vivado is sourced, example for Vivado 2019.1: 
    
    source /opt/Xilinx/Vivado/2019.1/settings64.sh

Then make sure you have fusesoc installed:

    python3 -m pip install fusesoc

Then add `pito` to your fusesoc libraries:
    
    git clone https://github.com/hossein1387/pito_riscv.git
    cd pito_riscv
    fusesoc library add pito .

Then run simulation (No GUI):
   
    fusesoc run --target=sim pito

For synthesis:
    
    fusesoc run --target=synth pito

To open sim in GUI mode:

    cd build/pito_0/sim-vivado/ 
    make run-gui

And for synthesis:

    cd build/pito_0/synth-vivado/ 
    make build-gui


This should open the project for you. Make sure you have run simulation or synthesis atleast once, otherwise fusesoc would not create a 
project file for you.


# Publication

If you liked this project, please consider citing our paper:

    @INPROCEEDINGS{9114581,
      author={AskariHemmat, MohammadHossein and Bilaniuk, Olexa and Wagner, Sean and Savaria, Yvon and David, Jean-Pierre},
      booktitle={2020 IEEE 28th Annual International Symposium on Field-Programmable Custom Computing Machines (FCCM)}, 
      title={RISC-V Barrel Processor for Accelerator Control}, 
      year={2020},
      volume={},
      number={},
      pages={212-212},
      doi={10.1109/FCCM48280.2020.00063}}
      
      @INPROCEEDINGS{9401617,
      author={AskariHemmat, MohammadHossein and Bilaniuk, Olexa and Wagner, Sean and Savaria, Yvon and David, Jean-Pierre},
      booktitle={2021 IEEE International Symposium on Circuits and Systems (ISCAS)}, 
      title={RISC-V Barrel Processor for Deep Neural Network Acceleration}, 
      year={2021},
      volume={},
      number={},
      pages={1-5},
      doi={10.1109/ISCAS51556.2021.9401617}}
