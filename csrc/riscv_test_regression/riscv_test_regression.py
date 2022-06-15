import os, sys
from shutil import copyfile
from pathlib import Path
import subprocess

all_tests= ["addi", "and", "andi", "auipc", "beq", "bge", "bgeu", "blt", "bltu",
"j", "jal", "jalr", "lb", "lbu", "lh", "lhu", "lui", "lw", "or", "ori", "sll", 
"slli", "slt", "slti", "sra", "srai", "srl", "srli", "sub", "xor",
"xori", "bne", "sw", "sb", "sh", "add"]
# all_tests = ['bne']
# ommitted tests:
# 

riscv_test_dir = "../asm_test/"
cur_dir = os.getcwd()


def run_command(command_str, split=True):
        try:
            print("running: {}".format(command_str))
            # subprocess needs to receive args seperately
            if split:
                res = subprocess.call(command_str.split())
            else:
                res = subprocess.call(command_str, shell=True)
            if res == 1:
                print("Errors while executing: {0}".format(command_str))
                sys.exit()
        except OSError as e:
            print("Unable to run {0} command".format(command_str))
            sys.exit()

def compile_tests():
    for test in all_tests:
        file_name = test + ".S"
        test_file_path = riscv_test_dir + test + "/" + file_name
        copyfile(test_file_path, cur_dir+"/"+file_name)
        run_command("make {}.hex PROJ={}".format(test, test))

# def link_binaries():
#     for test in all_tests:
#         text_hex = riscv_test_dir + test + "/" + "{}_text.hex".format(test)
#         run_command("ln -s {} ".format(text_hex))
#         data_hex = riscv_test_dir + test + "/" + "{}_data.hex".format(test)
#         run_command("ln -s {} ".format(data_hex))

def run_sim():
    wd = os.getcwd()
    os.chdir("/users/hemmat/MyRepos/pito_riscv/")
    for test in all_tests:
        print("Testsing {} ...".format(test))
        cmd = "fusesoc run --target=sim pito --firmware=./csrc/riscv_test_regression/{}_text.hex --rodata=./csrc/riscv_test_regression/{}_data.hex > ./csrc/riscv_test_regression/{}.log".format(test, test, test)
        run_command(cmd, False)
    os.chdir(wd)

def parse_logs():
    for test in all_tests:
        # print(" Parsing {} ...".format(test))
        file_name = test + ".log"
        with open(file_name, "r") as f:
            lines = f.readlines()
            lines = lines[::-1]
            for line in lines:
                if "RISC-V TEST Result:" in line:
                    if "OK" in line:
                        print("Test {:5s}: PASSED".format(test))
                    elif "ERO" in line:
                        print("Test {:5s}: FAILED".format(test))
                    else:
                        print("Test {:5s}: UNKMWON".format(test))
                    break
            f.close()

# link_binaries()
# compile_tests()
# run_sim()
parse_logs()
