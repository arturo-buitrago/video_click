import socket

UDP_IP = '0.0.0.0'
UDP_PORT = 54002

NUMBER = 1

num_pkg = 1

socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
socket.bind((UDP_IP,UDP_PORT))
socket.settimeout(5)

while True:
	try:
		data,addr = socket.recvfrom(4096)
		print("%i Pkg received" % num_pkg)
		num_pkg+=1
	except:
		print("Packets received: %i" % num_pkg)
		break
