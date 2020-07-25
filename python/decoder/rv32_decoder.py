#  RISC-V 2.2 Opcode Table
from bitstring import BitArray

def hex_str_to_int(instr_str, slice_high, slice_low=None, signed=False):
    if slice_low == None:
        return  int(instr_str[slice_low], 2) 
    else:
        if signed:
            val_str = instr_str[slice_low:slice_high+1][::-1]
            val_str = 32*val_str[0] + val_str
            val_str = val_str[::-1][0:32][::-1]
            return BitArray(bin=val_str).int
        else:
            return int(instr_str[slice_low:slice_high+1][::-1], 2)

csr_dict = {
    "111100010001": "CSR_MVENDORID",      # F11 
    "111100010010": "CSR_MARCHID",        # F12 
    "111100010011": "CSR_MIMPID",         # F13 
    "111100010100": "CSR_MHARTID",        # F14 
    "001100000000": "CSR_MSTATUS",        # 300
    "001100000001": "CSR_MISA",           # 301
    "001100000100": "CSR_MIE",            # 304
    "001100000101": "CSR_MTVEC",          # 305
    "001101000000": "CSR_MSCRATCH",       # 340
    "001101000001": "CSR_MEPC",           # 341
    "001101000010": "CSR_MCAUSE",         # 342
    "001101000011": "CSR_MTVAL",          # 343
    "001101000100": "CSR_MIP",            # 344
    "101100000000": "CSR_MCYCLE",         # B00
    "101100000010": "CSR_MINSTRET",       # B02
    "101110000000": "CSR_MCYCLEH",        # B80
    "101110000010": "CSR_MINSTRETH",      # B82
    "101100001100": "CSR_MCALL",          # B0C
    "101100001101": "CSR_MRET",           # B0D
    "111100100000": "CSR_MVU_MUL_MODE",   # F20
    "111100100001": "CSR_MVU_COUNTDOWN",  # F21
    "111100100010": "CSR_MVU_WPRECISION", # F22
    "111100100011": "CSR_MVU_IPRECISION", # F23
    "111100100100": "CSR_MVU_OPRECISION", # F24
    "111100100101": "CSR_MVU_WBASEADDR",  # F25
    "111100100110": "CSR_MVU_IBASEADDR",  # F26
    "111100100111": "CSR_MVU_OBASEADDR",  # F27
    "111100101000": "CSR_MVU_WSTRIDE_0",  # F28
    "111100101001": "CSR_MVU_WSTRIDE_1",  # F29
    "111100101010": "CSR_MVU_WSTRIDE_2",  # F2A
    "111100101011": "CSR_MVU_ISTRIDE_0",  # F2B
    "111100101100": "CSR_MVU_ISTRIDE_1",  # F2C
    "111100101101": "CSR_MVU_ISTRIDE_2",  # F2D
    "111100101110": "CSR_MVU_OSTRIDE_0",  # F2E
    "111100101111": "CSR_MVU_OSTRIDE_1",  # F2F
    "111100110000": "CSR_MVU_OSTRIDE_2",  # F30
    "111100110001": "CSR_MVU_WLENGTH_0",  # F31
    "111100110010": "CSR_MVU_WLENGTH_1",  # F32
    "111100110011": "CSR_MVU_WLENGTH_2",  # F33
    "111100110100": "CSR_MVU_ILENGTH_0",  # F34
    "111100110101": "CSR_MVU_ILENGTH_1",  # F35
    "111100110110": "CSR_MVU_ILENGTH_2",  # F36
    "111100110111": "CSR_MVU_OLENGTH_0",  # F37
    "111100111000": "CSR_MVU_OLENGTH_1",  # F38
    "111100111001": "CSR_MVU_OLENGTH_2"   # F39
}

def get_imm(instr, instr_type):
    if instr_type == "RV32_TYPE_UNKNOWN":
        return None
    else:
        if instr_type == "RV32_TYPE_I":
            if instr[0:7][::-1] == "1110011":
                if instr[14] == "1":
                    return hex_str_to_int(instr, 19, 15)
                else:
                    return None
            else:
                return hex_str_to_int(instr, 31, 20, True)
        elif instr_type == "RV32_TYPE_S":
            val_str = 32*instr[31] + instr[25:32][::-1]+instr[7:12][::-1]
            val_str = val_str[::-1][0:32][::-1]
            return BitArray(bin=val_str).int
        elif instr_type == "RV32_TYPE_B":
            val_str = 32*instr[31] + instr[31] + instr[7] + instr[25:31][::-1] + instr[8:12][::-1]
            val_str = val_str[::-1][0:32][::-1]
            return BitArray(bin=val_str).int
        elif instr_type == "RV32_TYPE_U":
            val_str = instr[12:32][::-1] + 12*"0"
            return BitArray(bin=val_str).int
        elif instr_type == "RV32_TYPE_J":
            val_str = 32*instr[31] + instr[31] + instr[12:20][::-1] + instr[20] + instr[21:31][::-1]
            val_str = val_str[::-1][0:32][::-1]
            return BitArray(bin=val_str).int
        else:
            return None


def decode(instruction):
    # import ipdb as pdb; pdb.set_trace()
    instr = format(int(instruction, 16), "032b")[::-1]  # "032b" is used for 0 padding if hex contains 0's at MSB
    rv32_rs1 = hex_str_to_int(instr, 19, 15);
    rv32_rs2 = hex_str_to_int(instr, 24, 20);
    rv32_rd = hex_str_to_int(instr, 11,  7);
    rv32_shamt = hex_str_to_int(instr, 24, 20);
    rv32_type = "RV32_TYPE_UNKNOWN"
    rv32_imm = 0
    rv32_opcode = "RV32_UNKNOWN"
    csr_flag = False
    rv32_dec_dict = {
        "instr": "",
        "rs1": 0,
        "rs2": 0,
        "rd": 0,
        "imm": 0,
        "shamt": 0,
        "opcode": "",
        "csr": ""
    }
    try:
        if instr[2:7][::-1] == "01101":
            rv32_opcode = "RV32_LUI"
            rv32_type = "RV32_TYPE_U"
        elif instr[2:7][::-1] == "00101":
            rv32_opcode = "RV32_AUIPC"
            rv32_type = "RV32_TYPE_U"
        elif instr[2:7][::-1] == "11011":
            rv32_opcode = "RV32_JAL"
            rv32_type = "RV32_TYPE_J"
        elif instr[2:7][::-1] == "11001" and instr[12:15][::-1] == "000":
            rv32_opcode = "RV32_JALR"
            rv32_type = "RV32_TYPE_J"
        elif instr[2:7][::-1] == "11000": # BEQ, BNE, BLT, BGE, BLTU, BGEU
            rv32_type = "RV32_TYPE_B"
            if instr[12:15][::-1] == "000": 
                rv32_opcode = "RV32_BEQ"
            elif instr[12:15][::-1] == "001": 
                rv32_opcode = "RV32_BNE"
            elif instr[12:15][::-1] == "100": 
                rv32_opcode = "RV32_BLT"
            elif instr[12:15][::-1] == "101": 
                rv32_opcode = "RV32_BGE"
            elif instr[12:15][::-1] == "110": 
                rv32_opcode = "RV32_BLTU"
            elif instr[12:15][::-1] == "111": 
                rv32_opcode = "RV32_BGEU"
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        elif instr[2:7][::-1] == "00000": # LB, LH, LW, LBU, LHU
            rv32_type = "RV32_TYPE_I"
            if instr[12:15][::-1] == "000":
                rv32_opcode = "RV32_LB"
            elif instr[12:15][::-1] == "001":
                rv32_opcode = "RV32_LH"
            elif instr[12:15][::-1] == "010":
                rv32_opcode = "RV32_LW"
            elif instr[12:15][::-1] == "100":
                rv32_opcode = "RV32_LBU"
            elif instr[12:15][::-1] == "101":
                rv32_opcode = "RV32_LHU"
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        elif instr[2:7][::-1] == "01000": # SB, SH, SW
            rv32_type = "RV32_TYPE_S"
            if instr[12:15][::-1] == "000" :
                rv32_opcode = "RV32_SB"
            elif instr[12:15][::-1] == "001" :
                rv32_opcode = "RV32_SH"
            elif instr[12:15][::-1] == "010" :
                rv32_opcode = "RV32_SW"
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        elif instr[2:7][::-1] == "00100": # ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, NOP
            rv32_type = "RV32_TYPE_I"
            if (instr[30] + instr[12:15][::-1]) == "0000" : 
                rv32_opcode = "RV32_ADDI"
            elif (instr[30] + instr[12:15][::-1]) == "0001" : 
                rv32_opcode = "RV32_SLLI"
            elif (instr[30] + instr[12:15][::-1]) == "0010" : 
                rv32_opcode = "RV32_SLTI"
            elif (instr[30] + instr[12:15][::-1]) == "0011" : 
                rv32_opcode = "RV32_SLTIU"
            elif (instr[30] + instr[12:15][::-1]) == "0100" : 
                rv32_opcode = "RV32_XORI"
            elif (instr[30] + instr[12:15][::-1]) == "0101" : 
                rv32_opcode = "RV32_SRLI"
            elif (instr[30] + instr[12:15][::-1]) == "1101" : 
                rv32_opcode = "RV32_SRAI"
            elif (instr[30] + instr[12:15][::-1]) == "0110" : 
                rv32_opcode = "RV32_ORI"
            elif (instr[30] + instr[12:15][::-1]) == "0111" : 
                rv32_opcode = "RV32_ANDI"
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        elif instr[2:7][::-1] == "01100": # ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            rv32_type = "RV32_TYPE_R"
            if (instr[30] + instr[12:15][::-1]) == "0000" : 
                rv32_opcode = "RV32_ADD"
            elif (instr[30] + instr[12:15][::-1]) == "1000" : 
                rv32_opcode = "RV32_SUB"
            elif (instr[30] + instr[12:15][::-1]) == "0001" : 
                rv32_opcode = "RV32_SLL"
            elif (instr[30] + instr[12:15][::-1]) == "0010" : 
                rv32_opcode = "RV32_SLT"
            elif (instr[30] + instr[12:15][::-1]) == "0011" : 
                rv32_opcode = "RV32_SLTU"
            elif (instr[30] + instr[12:15][::-1]) == "0100" : 
                rv32_opcode = "RV32_XOR"
            elif (instr[30] + instr[12:15][::-1]) == "1101" : 
                rv32_opcode = "RV32_SRA"
            elif (instr[30] + instr[12:15][::-1]) == "0101" : 
                rv32_opcode = "RV32_SRL"
            elif (instr[30] + instr[12:15][::-1]) == "0110" : 
                rv32_opcode = "RV32_OR"
            elif (instr[30] + instr[12:15][::-1]) == "0111" : 
                rv32_opcode = "RV32_AND"
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        elif instr[2:7][::-1] ==  "00011": # FENCE, FENCEI
            rv32_type = "RV32_TYPE_I"
            if instr[12:15][::-1] == "000":
                rv32_opcode = "RV32_FENCE"
            elif instr[12:15][::-1] == "001": 
                rv32_opcode = "RV32_FENCEI"
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        elif instr[2:7][::-1] ==  "11100": # ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
            rv32_type = "RV32_TYPE_I"
            if (instr[12:15][::-1]) == "000":
                if instr[20] == "0":
                    rv32_opcode = "RV32_ECALL"
                elif instr[20] == "1":
                    rv32_opcode = "RV32_EBREAK"
                else:
                    rv32_type = "RV32_TYPE_UNKNOWN"
            elif (instr[12:15][::-1]) == "001":
                rv32_opcode = "RV32_CSRRW"
                csr_flag = True
            elif (instr[12:15][::-1]) == "010":
                rv32_opcode = "RV32_CSRRS"
                csr_flag = True
            elif (instr[12:15][::-1]) == "011":
                rv32_opcode = "RV32_CSRRC"
                csr_flag = True
            elif (instr[12:15][::-1]) == "101":
                rv32_opcode = "RV32_CSRRWI"
                csr_flag = True
            elif (instr[12:15][::-1]) == "110":
                rv32_opcode = "RV32_CSRRSI"
                csr_flag = True
            elif (instr[12:15][::-1]) == "111":
                rv32_opcode = "RV32_CSRRCI"
                csr_flag = True
            else:
                rv32_type = "RV32_TYPE_UNKNOWN"
        else:
            rv32_opcode = "RV32_UNKNOWN"
    except KeyError:
        return "ERROR"
    # import ipdb as pdb; pdb.set_trace()
    rv32_imm = get_imm(instr, rv32_type)
    rv32_csr = csr_dict[instr[20:32][::-1]] if csr_flag else None 

    rv32_dec_dict["instr"]  = instr
    rv32_dec_dict["rs1"]    = rv32_rs1
    rv32_dec_dict["rs2"]    = rv32_rs2
    rv32_dec_dict["rd"]     = rv32_rd
    rv32_dec_dict["imm"]    = rv32_imm
    rv32_dec_dict["shamt"]  = rv32_shamt
    rv32_dec_dict["opcode"] = rv32_opcode
    rv32_dec_dict["csr"]    = rv32_csr

    return rv32_dec_dict

def get_instr_str(inst, print_ = False):
    str_to_print = ""
    if inst['opcode'] == "RV32_LUI":
        str_to_print = "{:5s} x{}, {}".format("lui", inst['rd'], inst['imm'])
    elif inst['opcode'] == "RV32_AUIPC":
        str_to_print = "{:5s} x{}, {}".format("auipc", inst['rd'], inst['imm'])
    elif inst['opcode'] == "RV32_JAL":
        str_to_print = "{:5s} x{}, {}".format("jal", inst['rd'], inst['imm'])
    elif inst['opcode'] == "RV32_JALR":
        str_to_print = "{:5s} x{}, ({})x{}".format("jalr", inst['rd'], inst['imm'], x['rs1'])
    elif inst['opcode'] == "RV32_BEQ":
        str_to_print = "{:5s} x{}, x{}, {}".format("beq", inst['rs1'], inst['rs2'], inst['imm'])
    elif inst['opcode'] == "RV32_BNE":
        str_to_print = "{:5s} x{}, x{}, {}".format("bne", inst['rs1'], inst['rs2'], inst['imm'])
    elif inst['opcode'] == "RV32_BLT":
        str_to_print = "{:5s} x{}, x{}, {}".format("blt", inst['rs1'], inst['rs2'], inst['imm'])
    elif inst['opcode'] == "RV32_BGE":
        str_to_print = "{:5s} x{}, x{}, {}".format("bge", inst['rs1'], inst['rs2'], inst['imm'])
    elif inst['opcode'] == "RV32_BLTU":
        str_to_print = "{:5s} x{}, x{}, {}".format("bltu", inst['rs1'], inst['rs2'], inst['imm'])
    elif inst['opcode'] == "RV32_BGEU":
        str_to_print = "{:5s} x{}, x{}, {}".format("bgeu", inst['rs1'], inst['rs2'], inst['imm'])
    elif inst['opcode'] == "RV32_LB":
        str_to_print = "{:5s} x{}, ({})x{}".format("lb", inst['rd'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_LH":
        str_to_print = "{:5s} x{}, ({})x{}".format("lh", inst['rd'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_LW":
        str_to_print = "{:5s} x{}, ({})x{}".format("lw", inst['rd'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_LBU":
        str_to_print = "{:5s} x{}, ({})x{}".format("lbu", inst['rd'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_LHU":
        str_to_print = "{:5s} x{}, ({})x{}".format("lhu", inst['rd'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_SB":
        str_to_print = "{:5s} x{}, ({})x{}".format("sb", inst['rs2'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_SH":
        str_to_print = "{:5s} x{}, ({})x{}".format("sh", inst['rs2'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_SW":
        str_to_print = "{:5s} x{}, ({})x{}".format("sw", inst['rs2'], inst['imm'], inst['rs1'])
    elif inst['opcode'] == "RV32_ADDI":
        str_to_print = "{:5s} x{}, x{}, {}".format("addi", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_SLLI":
        str_to_print = "{:5s} x{}, x{}, {}".format("slli", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_SLTI":
        str_to_print = "{:5s} x{}, x{}, {}".format("slti", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_SLTIU":
        str_to_print = "{:5s} x{}, x{}, {}".format("Sltiu", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_XORI":
        str_to_print = "{:5s} x{}, x{}, {}".format("xori", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_SRLI":
        str_to_print = "{:5s} x{}, x{}, {}".format("srli", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_SRAI":
        str_to_print = "{:5s} x{}, x{}, {}".format("srai", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_ORI":
        str_to_print = "{:5s} x{}, x{}, {}".format("ori", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_ANDI":
        str_to_print = "{:5s} x{}, x{}, {}".format("andi", inst['rd'], inst['rs1'], inst['imm'])
    elif inst['opcode'] == "RV32_ADD":
        str_to_print = "{:5s} x{}, x{}, x{}".format("add", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_SUB":
        str_to_print = "{:5s} x{}, x{}, x{}".format("sub", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_SLL":
        str_to_print = "{:5s} x{}, x{}, x{}".format("sll", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_SLT":
        str_to_print = "{:5s} x{}, x{}, x{}".format("slt", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_SLTU":
        str_to_print = "{:5s} x{}, x{}, x{}".format("Sltu", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_XOR":
        str_to_print = "{:5s} x{}, x{}, x{}".format("xor", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_SRA":
        str_to_print = "{:5s} x{}, x{}, x{}".format("sra", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_SRL":
        str_to_print = "{:5s} x{}, x{}, x{}".format("srl", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_OR":
        str_to_print = "{:5s} x{}, x{}, x{}".format("or", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_AND":
        str_to_print = "{:5s} x{}, x{}, x{}".format("and", inst['rd'], inst['rs1'], inst['rs2'])
    elif inst['opcode'] == "RV32_FENCE":
        str_to_print = "{:5s}".format("fence")
    elif inst['opcode'] == "RV32_FENCEI":
        str_to_print = "{:5s}".format("fencei")
    elif inst['opcode'] == "RV32_ECALL":
        str_to_print = "{:5s}".format("ecall")
    elif inst['opcode'] == "RV32_EBREAK":
        str_to_print = "{:5s}".format("ebreak")
    elif inst['opcode'] == "RV32_CSRRW":
        str_to_print = "{:5s} x{}, {}, x{}".format("csrrw", inst['rd'], inst['csr'], inst['rs1'])
    elif inst['opcode'] == "RV32_CSRRS":
        str_to_print = "{:5s} x{}, {}, x{}".format("csrrs", inst['rd'], inst['csr'], inst['rs1'])
    elif inst['opcode'] == "RV32_CSRRC":
        str_to_print = "{:5s} x{}, {}, x{}".format("csrrc", inst['rd'], inst['csr'], inst['rs1'])
    elif inst['opcode'] == "RV32_CSRRWI":
        str_to_print = "{:5s} x{}, {}, x{}".format("csrrwi", inst['rd'], inst['csr'], inst['imm'])
    elif inst['opcode'] == "RV32_CSRRSI":
        str_to_print = "{:5s} x{}, {}, x{}".format("csrrsi", inst['rd'], inst['csr'], inst['imm'])
    elif inst['opcode'] == "RV32_CSRRCI":
        str_to_print = "{:5s} x{}, {}, x{}".format("csrrci", inst['rd'], inst['csr'], inst['imm'])
    else:
        str_to_print = "{:5s}".format("unknown")
        print(inst['opcode'])
    if print_:
        print(str_to_print)
    else:
        return str_to_print