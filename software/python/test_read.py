from test_config import *

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))

setup()
payload = read_imem(0x00, 16)
i=0
for byte in payload:
    print('addr: '+hex(i)+'['+hex(byte)+']')
    i +=1 
teardown()

