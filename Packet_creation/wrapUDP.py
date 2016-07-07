#! /usr/bin/python3

#log level to benefit from Scapy warnings apparently

import logging
logging.getLogger("scapy").setLevel(1)

import scapy.all

import string

import socket

DROPPED_PKGS = 0
GOOD_PKGS = 0
LARGEST = 0
FILTER = 0

TAIL = bytearray(1472)

IF_ONE_ENCODE_INFO = 1

AVAILABLE_FILES = ('trace.txt','minitrace.txt','microtrace.txt','microtrace2.txt','dummytrace_6.txt')
CHOSEN_FILE = 4

NUMBER_OF_LINES = 0

socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

UDP_IP = '0.0.0.0'
UDP_PORT = 54001

class VideoTrace(scapy.packet.Packet):
	#6 fields
	name = "VideoTrace Packet "
	fields_desc = [ scapy.all.SignedIntField("Frame_Type",0),
					scapy.all.SignedIntField("Frame_Identifier",0),
					scapy.all.SignedIntField("Segment_Number",0),
					scapy.all.SignedIntField("Frame_Size",0),
					scapy.all.IEEEFloatField("Event_Ocurred",0),
					scapy.all.IEEEFloatField("m2st",0)]

def strip(string):
	return string.split('\n')[0]


def make_videotrace(a=1,b=2,c=3,d=4,e=5,f=6):
	return VideoTrace(Frame_Type = a, Frame_Identifier = b, Segment_Number = c, Frame_Size = d, Event_Ocurred = e, m2st = f)

def makea():
	a = make_videotrace(6,5,4,3,2,1)
	a.show()



def readtrace():
	#print('a')
	trace = open(AVAILABLE_FILES[CHOSEN_FILE],'r')
	#print(size(trace))
	lines = trace.readlines()
	NUMBER_OF_LINES = len(lines)
	
	for x in range(NUMBER_OF_LINES):
		makepackages(lines,x)
	#print("%i lines." % NUMBER_OF_LINES)
	#print(lines)
	#return (make_videotrace(1,2,3,4,5,6), make_videotrace(7,8,9,10,11,12))
def makepackages(lines,index):
	#for x in range(NUMBER_OF_LINES):
	ok = 1
	short = 0

	lines = strip(lines[index])
	linessplit = lines.split(',')
	#print(linessplit)
	a = make_videotrace(int(linessplit[0]),int(linessplit[1]),int(linessplit[2]),long(linessplit[3]),float(linessplit[4]),float(linessplit[5]))
	if linessplit[0] == '-100' and FILTER:
		print('weird -100 shit')
		ok = 0
	elif linessplit[2] == '-1' and FILTER:
		print("start of a frame")
		ok = 0

	if FILTER == 0:
		print("RAW DOG")
		wrap_and_send(str(a))



	#print (b)
	if long(linessplit[3]) > LARGEST:
		global LARGEST
		LARGEST = long(linessplit[3])

	if long(linessplit[3]) < 12304:
		short = (long(linessplit[3])/8)-len(str(a))-42
		print("shawty")

	if IF_ONE_ENCODE_INFO and ok and not short:
		print("good")
		wrap_and_send(str(a))
		global GOOD_PKGS
		GOOD_PKGS+=1
		#print(len(str(a)))
	elif short and ok and short>0:
		correct_length(str(a),short)
		global GOOD_PKGS
		GOOD_PKGS+=1
	else:
		global DROPPED_PKGS
		DROPPED_PKGS +=1
		pass

	#output = scapy.all.hexdump(a)
	#text_file = open('output.txt', 'w')
	#text_file.write(scapy.utils.linehexdump(a))
	#text_file.close()
	#scapy.all.hexdump(a)
	#print (str(a))

def correct_length(incoming, difference):
	incoming = incoming + bytearray(difference)
	socket.sendto(incoming,(UDP_IP,UDP_PORT))
	print(len(incoming))

def wrap_and_send(incoming):
	incoming = incoming + TAIL
	socket.sendto(incoming,(UDP_IP,UDP_PORT))
	print(len(incoming))



if __name__ == "__main__":
	#scapy.all.interact(mydict = globals())
	#print('here goes nothing')
	#print("d4c3 b2a1 0200 0400 0000 0000 0000 0000 d007 0000 0c00 0000")
	#print('well ok')
	print(len(TAIL))
	readtrace()
	print("dropped %i" % DROPPED_PKGS)
	print("Good ones %i" % GOOD_PKGS)
	print("largest frame %i" % LARGEST)
	
	#makepackages()
	#makea()




	#SignedIntField