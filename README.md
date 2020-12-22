![alt text](https://github.com/hossein1387/pito_riscv/blob/master/doc/pics/MVU_CORE%20-%20Barelled.png)

# pito_riscv
A pito version of rv32i 


# How to Run:
The following shows how to run a verification test for core module. Assuming we have Vivado18.2 installed, first make sure the Vivado is sourced: 
    
    source /opt/Xilinx/Vivado/2018.2/settings64.sh
   
Then run the test as follow (No GUI):
   
    cd verification/core
    ./do_test.py -f files.f -t core_tester -s xilinx -l libs.f -m vlogmacros.f
    
To debug in GUI mode:

    cd verification/core
    ./do_test.py -f files.f -t core_tester -s xilinx -w -g -l libs.f -m vlogmacros.f

# TODO:

- [x] Adding support for CSR related instructions.
- [x] We will attempt to implement the barreled data path. 
- [x] Adding support for Exceptions, HALT, interrupts and traps.
