![alt text](https://github.com/hossein1387/pito_riscv/blob/master/doc/pics/pito_rv32i.png)

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

# Progress:

Upto this point, we have implemented a working core runs most RV32I instructsions except the following:

    RV32_FENCEI, RV32_FENCE, RV32_CSRRW, RV32_CSRRS, RV32_CSRRC, RV32_CSRRWI, RV32_CSRRSI, RV32_CSRRCI, RV32_ECALL, RV32_EBREAK, RV32_ERET, RV32_WFI

Here are the known issues with the core:

1. `riscv_tests` are not supported. This is because we still do not have a proper memory map. We have to make sure the gcc can target the correct memory regions (obviously based on the restrictions that we define like 32Kb of instruction ram and 32Kb of data ram).
2. We have assumed that access to memory happens in one clock cycle. Up to now, we have been using FPGA block ram. We assumed it takes one cycle to read and one cycle to write to the memory. 
3. :bug: Access to memory is word aligned not byte. According to ISA, the memory should be byte accessible: 
       
       A RISC-V hart has a single byte-addressable address space of 2XLEN bytes for all memory accesses. (Page 6 The RISC-V Instruction Set Manual Volume I: Unprivileged ISA Document Version 20191213)

We have to figure out a way to read/write in a byte aligned memory space. 

# TODO:

- [ ] Adding support for CSR related instructions.
- [x] We will attempt to implement the barreled data path. 
- [ ] Adding support for Exceptions, HALT, interrupts and traps.
