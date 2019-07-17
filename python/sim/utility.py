'''
Returns the val bits starting from start position to end position.

+---------------+--------------------+---------+
|               | region of interest |         |
+---------------+--------------------+---------+
^               ^                    ^         ^
num_bits-1     end                 start       0

'''
def get_bits(val, start, end, num_bits=32):
    mask = []
    for i in range(0, num_bits):
        if i>= start and i<=end:
            mask.append('1')
        else:
            mask.append('0')
    mask.reverse()
    mask = ''.join(mask)
    return (int(mask, 2)&val)>>start
