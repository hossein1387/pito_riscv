import argparse
import rv32_decoder

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', help='input instruction', required=True)
    parser.add_argument('-f', '--input_fromat', help='input instruction format', required=False, choices=['h', 'b', 'd', 'f'], default='h')
    args = parser.parse_args()
    return vars(args)

def decode_instruction_file(input_file):
    stop_cnt = 0

    with open(input_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            line = line.split("\n")[0]
            # import ipdb as pdb; pdb.set_trace()
            decoded_instruction = rv32_decoder.decode(line)
            decoded_instruction_str = rv32_decoder.get_instr_str(decoded_instruction)
            if decoded_instruction_str == "0x00000013   addi  x0, x0, 0":
                stop_cnt += 1
                if stop_cnt>10:
                    break
            print(decoded_instruction_str)


if __name__ == '__main__':
    args = parse_args()
    instruction_format = args['input_fromat']
    instruction = ""
    if instruction_format == 'h':
        decoded_instruction = rv32_decoder.decode(args['input'])
        decoded_instruction_str = rv32_decoder.get_instr_str(decoded_instruction)
        print(decoded_instruction_str)
    elif instruction_format == 'd':
        instruction = bin(int(args['input']))[2:].zfill(32)
        decoded_instruction = rv32_decoder.decode(instruction)
    elif instruction_format == 'b':
        instruction = args['input']
    elif instruction_format == 'f':
        decoded_instr = decode_instruction_file(args['input'])
    else:
        import sys
        print("Unknown input type {}".format(instruction_format))
        sys.exit()
