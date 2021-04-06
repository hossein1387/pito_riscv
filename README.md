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

To debug in GUI mode:

    cd build/pito_0/

And then open the vivado project for synthesis or simulation. Make sure you have run simulation or synthesis atleast once, otherwise fusesoc would not create a 
project file for you.
