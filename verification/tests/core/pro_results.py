all_tests = ['add','andi','bge','bltu','jalr','lbu','lui','ori','sll','slti','srl','sw',
             'xori','addi','auipc', 'bgeu','bne','j','lh','lw','sb','slli','sra','srli',
             'test','and','beq','blt','jal','lb','lhu','or','sh','slt','srai','sub','xor']

result = {}
for test in all_tests:
    filename = "log_" + test + ".log"
    with open(filename, 'r', errors='replace') as f:
        #print("processing {:s}".format(test))
        lines = f.readlines()
        result[test] = "NOT COMPLETE"
        for line in lines:
            if "O   K" in line:
                result[test] = "PASS"
                break
            elif "E   R   O" in line:
                result[test] = "FAIL"
                break
    print("{:10s}: {:s}".format(test, result[test]))

