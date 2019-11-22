![alt text](https://github.com/hossein1387/pito_riscv/blob/master/doc/pics/pito_rv32i.png)

# pito_riscv
A pito version of rv32i 


# How to Run:
The following shows how to run a verification test for core module. Assuming we have Vivado19.1 installed, first make sure the Vivado is sourced: 
    
    source /opt/Xilinx/Vivado/2018.2/settings64.sh
   
Then run the test as follow (No GUI):
   
    cd verification/core
    ./do_test.py -f files.f -t core_tester -s xilinx
    
To debug in GUI mode:

    cd verification/core
    ./do_test.py -f files.f -t core_tester -s xilinx -w -g
