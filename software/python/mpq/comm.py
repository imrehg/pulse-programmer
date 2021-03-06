import struct
import socket
import lxx


# constants
MY_PORT  = 0x221e
HIS_PORT = 0x2229
HIS_IP   = '192.168.0.229'
RETRY_COUNT = 5
MAX_FRAME_LENGTH = 984

PCP_START_REQUEST   = "\x04\x00\x00\x0b\x00\x00\x01"
PCP_STOP_REQUEST    = "\x04\x00\x00\x0b\x00\x00\x02"
DDS_RESET_REQUEST   = "\x07\x00\x00\x0f\x00\x00\x61\x00\x00\x44\x00"
DDS_UNRESET_REQUEST = "\x07\x00\x00\x0f\x00\x00\x61\x00\x00\x44\xff"


# globals
client_socket = None


# functions
def print_binary(code):
	length = len(code) / 4
	code_list = struct.unpack("!"+str(length)+"L", code[:length*4])
	for i in range(length):
		if i % 8 == 0:
			print
			print "%04x" % i, "|",
		print "%08x" % code_list[i],
	for i in range(len(code)%4, 0, -1):
		print "%02x" % ord(code[-i]),
	print


def send_frame(data):
	# create a client_socket
	global client_socket
	if client_socket == None:
		client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		client_socket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, True)
		client_socket.bind(('', MY_PORT))
		client_socket.settimeout(0.1)  # seconds
	
	# frame header
	datastring = '\x00\x02'
	# version
	datastring += '\x00\x15'
	# Data has the following format:
	#   opcode
	#   0x00
	#   total length (two bytes)
	#   0x00 0x00
	#   payload
	datastring += data

	#print_binary(datastring)

	# send the frame
	retry_count = 0
	while retry_count < RETRY_COUNT:
		result = client_socket.sendto(datastring, (HIS_IP, HIS_PORT))
		if result != len(datastring):
			raise RuntimeError, "Socket operation did not send all bytes."
		reply_data = recv_frame()
		if len(reply_data) > 0:
			break
		retry_count += 1
	if len(reply_data) > 0:
		return reply_data
	raise RuntimeError, "No Pulse Transfer Protocol reply received."


def recv_frame():
	try:
		data = client_socket.recvfrom(1024)
		# data is a tuple (string, (ip_address, port))
		data = data[0]
		total_length = ord(data[6]) << 8 | ord(data[7])
		return data[4:total_length]
	except socket.timeout:
		return ""


def pack_write_frame(offset, payload):
	total_length = len(payload) + 14
	# opcode
	data = "\x02\x00"
	# length
	data += chr((total_length>>8) & 0xff) + chr(total_length & 0xff)
	# unused
	data += "\x00\x00"
	# subopcode
	data += "\x01" + chr((offset>>16) & 0xff) + chr((offset>>8) & 0xff) + chr(offset & 0xff)
	# payload
	data += payload
	return data


def reset_dds():
	send_frame(DDS_RESET_REQUEST)
	send_frame(DDS_UNRESET_REQUEST)


def send_code(code):
	# stop the processor
	send_frame(PCP_STOP_REQUEST)

	# write the pulse program in chunks
	byte_pos = 0
	while byte_pos < len(code):
		payload = code[byte_pos:byte_pos+MAX_FRAME_LENGTH]
		send_frame(pack_write_frame(byte_pos, payload))
		byte_pos += MAX_FRAME_LENGTH

	# start the processor
	send_frame(PCP_START_REQUEST)
