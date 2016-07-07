import socket

UDP_IP = '0.0.0.0'
UDP_PORT = 54001

NUMBER = 1

socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
socket.bind((UDP_IP,UDP_PORT))

while True:
	data,addr = socket.recvfrom(2048)
	#rint(data.decode())