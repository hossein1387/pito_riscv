from instr import *
from utility import *

def decoder(instr):
    rv32i_inst = rv32i('rv32i')
    opcode = utility.get_bits(int(instr), 0, 6)
    print(rv32i_inst.get_inst_str(opcode))


if __name__ == '__main__':
    bin_file = "test.bin"
    with open(file)