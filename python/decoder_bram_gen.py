import argparse

rv32_instr_dict = {
        'RV32_LB'     : "0011000000",
        'RV32_LH'     : "0011000001",
        'RV32_LW'     : "0011000010",
        'RV32_LBU'    : "0011000011",
        'RV32_LHU'    : "0011000100",
        'RV32_SB'     : "0011000101",
        'RV32_SH'     : "0011000110",
        'RV32_SW'     : "0011000111",
        'RV32_SLL'    : "0000001000",
        'RV32_SLLI'   : "0000001001",
        'RV32_SRL'    : "0001001010",
        'RV32_SRLI'   : "0001001011",
        'RV32_SRA'    : "0010001100",
        'RV32_SRAI'   : "0010001101",
        'RV32_ADD'    : "0011001110",
        'RV32_ADDI'   : "0011001111",
        'RV32_SUB'    : "0100010000",
        'RV32_LUI'    : "1111010001",
        'RV32_AUIPC'  : "1111010010",
        'RV32_XOR'    : "0101010011",
        'RV32_XORI'   : "0101010100",
        'RV32_OR'     : "0110010101",
        'RV32_ORI'    : "0110010110",
        'RV32_AND'    : "0111010111",
        'RV32_ANDI'   : "0111011000",
        'RV32_SLT'    : "1000011001",
        'RV32_SLTI'   : "1000011010",
        'RV32_SLTU'   : "1001011011",
        'RV32_SLTIU'  : "1001011100",
        'RV32_BEQ'    : "1100011101",
        'RV32_BNE'    : "1101011110",
        'RV32_BLT'    : "1000011111",
        'RV32_BGE'    : "1010100000",
        'RV32_BLTU'   : "1001100001",
        'RV32_BGEU'   : "1011100010",
        'RV32_JAL'    : "1111100011",
        'RV32_JALR'   : "1111100100",
        'RV32_FENCE'  : "1111100101",
        'RV32_FENCEI' : "1111100110",
        'RV32_CSRRW'  : "1111100111",
        'RV32_CSRRS'  : "1111101000",
        'RV32_CSRRC'  : "1111101001",
        'RV32_CSRRWI' : "1111101010",
        'RV32_CSRRSI' : "1111101011",
        'RV32_CSRRCI' : "1111101100",
        'RV32_ECALL'  : "1111101101",
        'RV32_EBREAK' : "1111101110",
        'RV32_ERET'   : "1111101111",
        'RV32_WFI'    : "1111110000",
        'RV32_NOP'    : "1111110001",
        'RV32_UNKNOWN': "1111111111"
}

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input_file', help='input file defining rv32 instructions', required=True)
    parser.add_argument('-o', '--output_file', help='output file that contains bram values', required=True)
    parser.add_argument('-t', '--output_type', help='output instruction type', required=True)
    args = parser.parse_args()
    return vars(args)

def parse_instr_def_file(file):
    with open(file) as f:
        instr_dict = {}
        lines = f.readlines()
        cnt = 0
        for line in lines:
            # import ipdb as pdb; pdb.set_trace()
            line = ''.join(line.split())
            instr= line.split(":")[0]
            val  = line.split(":")[-1][0:32][::-1] 
            val  = val[30] + val[20] + val[12:15][::-1] + val[2:7][::-1] 
            instr_dict[instr] = val
            # print("[{0:2}] {1:12}:{2}".format(cnt, instr, val))
            cnt += 1
    return instr_dict

def replace_char(str, pos, val):
    new_str = list(str)
    new_str[pos] = val
    return "".join(new_str)

def build_bram(bram_dict, num_bits, outputfile, output_type):
    bram = ["RV32_UNKNOWN" for i in range(0,2**num_bits)]
    for key in bram_dict.keys():
        instr = key
        if isinstance(bram_dict[key], str):
            indx = int(bram_dict[key], 2)
            bram[indx] = instr
        else:        
            for val in bram_dict[key]:
                # import ipdb as pdb; pdb.set_trace()
                indx = int(val, 2)
                if bram[indx] != "RV32_UNKNOWN":
                    print("Index conflict at {:8}, previous instr: {} current instr: {}".format(val, bram[indx], instr))
                else:
                    bram[indx] = instr
    with open(outputfile, "w") as f:
        for addr in range(0,2**num_bits):
            bram_val = bram[addr]
            # import ipdb as pdb; pdb.set_trace()
            # print("[{:4}]:  {:12}".format(addr, bram_val))
            if output_type == "text":
                f.write(bram_val+"\n")
            elif output_type == "int":
                f.write(str(int(rv32_instr_dict[bram_val], 2))+"\n")
            elif output_type == "hex":
                f.write(hex(int(rv32_instr_dict[bram_val], 2))[2:]+"\n")
            else:
                f.write(str(int(rv32_instr_dict[bram_val], 2))+"\n")
        f.close()
    return bram

def expand_instr(instr_dict):
    def expand_x(instr, instrs):
        for pos, x in enumerate(instr):
            if x == "x":
                with_0 = replace_char(instr, pos, "0")
                with_1 = replace_char(instr, pos, "1")
                if (not "x" in with_0) and (not with_0 in instrs):
                    instrs.append(with_0)
                if (not "x" in with_1) and (not with_1 in instrs):
                    instrs.append(with_1)
                expand_x(with_0, instrs)
                expand_x(with_1, instrs)
        return instrs
    bram_dict = {}
    for instr in instr_dict.keys():
        instrs = []
        # import ipdb as pdb; pdb.set_trace()
        if 'x' in instr_dict[instr]:
            instrs = expand_x(instr_dict[instr], instrs)
        else:
            instrs = instr_dict[instr]
        bram_dict[instr] = instrs
    return bram_dict


if __name__ == '__main__':
    args = parse_args()
    input_file = args['input_file']
    output_file = args['output_file']
    output_type = args['output_type']
    instr_dict = parse_instr_def_file(input_file)
    bram_dict = expand_instr(instr_dict)
    # import ipdb as pdb; pdb.set_trace()
    # print(bram_dict)
    build_bram(bram_dict, 10, output_file, output_type)