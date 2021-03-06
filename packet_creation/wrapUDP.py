#! /usr/bin/python3

#log level to benefit from Scapy warnings apparently

import logging
logging.getLogger("scapy").setLevel(1)
import scapy.all
import string
import time
import socket


DROPPED_PKGS = 0
GOOD_PKGS = 0
LARGEST = 0
FILTER = 1

"""This ones here to ensure the right length for each package"""
TAIL = bytearray(1472)

IF_ONE_ENCODE_INFO = 1

AVAILABLE_FILES = ('trace.txt','dummytrace_6.txt','only1.txt',"../traces/video_traces_as_given/medium_channel.txt","../traces/video_traces_as_given/slow_channel.txt")
CHOSEN_FILE = 0

NUMBER_OF_LINES = 0

NUMBER_OF_ONES = 0

socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

UDP_IP = '10.152.4.54'
UDP_PORT = 54001


"""This creates the package for the line read. It has 6 fields, which should be self explanatory.
4 are signed ints, 2 are floats"""

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

'''Dummy video trace'''

def make_videotrace(a=1,b=2,c=3,d=4,e=5,f=6):
	return VideoTrace(Frame_Type = a, Frame_Identifier = b, Segment_Number = c, Frame_Size = d, Event_Ocurred = e, m2st = f)

def makea():
	a = make_videotrace(6,5,4,3,2,1)
	a.show()


"""This reads the lines of the .txt file, calls the makepackages function after reading each line"""

def readtrace():
	trace = open(AVAILABLE_FILES[CHOSEN_FILE],'r')
	lines = trace.readlines()
	NUMBER_OF_LINES = len(lines)
	
	for x in range(NUMBER_OF_LINES):
		makepackages(lines,x)

def makepackages(lines,index):

	ok = 1
	short = 0

	lines = strip(lines[index])
	linessplit = lines.split(',')

	a = make_videotrace(int(linessplit[0]),int(linessplit[1]),int(linessplit[2]),long(linessplit[3]),float(linessplit[4]),float(linessplit[5]))
	
	"""Filters out the strange -100 frames and start of frames"""
	if linessplit[0] == '-100' and FILTER:
		ok = 0

	
	elif linessplit[2] == '-1' and FILTER:
		ok = 0



	if FILTER == 0:
		print("RAW PKG")
		wrap_and_send(str(a))


	"""Tracks the larges package that is sent"""
	if long(linessplit[3]) > LARGEST and ok:
		global LARGEST
		LARGEST = long(linessplit[3])

	"""Fixes the packages that are shorter (last pkg of a frame) with the correct size"""
	if long(linessplit[3]) < 12304:
		short = (long(linessplit[3])/8)-len(str(a))-42

	if linessplit[0] == '1' and ok:
		global NUMBER_OF_ONES
		NUMBER_OF_ONES += 1

	"""Sends packages that make the cut"""
	if IF_ONE_ENCODE_INFO and ok and not short:
		#print("good")
		wrap_and_send(str(a))
		global GOOD_PKGS
		GOOD_PKGS+=1

	elif short and ok and short>0:
		correct_length(str(a),short)
		global GOOD_PKGS
		GOOD_PKGS+=1
	else:
		global DROPPED_PKGS
		DROPPED_PKGS +=1
		pass


def correct_length(incoming, difference):
	incoming = incoming + bytearray(difference)
	socket.sendto(incoming,(UDP_IP,UDP_PORT))
	print(len(incoming))

def wrap_and_send(incoming):
	incoming = incoming + TAIL
	socket.sendto(incoming,(UDP_IP,UDP_PORT))
	print(len(incoming))



def main():

	print("Please choose a file to send to %s at port %s: " % (UDP_IP,UDP_PORT))
	print("Enter \"0\" to choose a different IP address.")
	for x in range(1,len(AVAILABLE_FILES)+1):	
		print("%i. %s" % ( x, AVAILABLE_FILES[x-1] ) )


	print("")
	filenum = input("Enter a number: ")
	print(filenum)

	if filenum is not 0:
		print("oh yeah")
		global CHOSEN_FILE
		CHOSEN_FILE = int(filenum - 1)
	else:
		global UDP_IP
		UDP_IP = raw_input("Please enter the new address: ")
		print("Restarting...")
		main()
		return



	print("Will send %i. %s." % (CHOSEN_FILE, AVAILABLE_FILES[CHOSEN_FILE]))
	#time.sleep(3)

	#print(len(TAIL))
	readtrace()
	print("Frames Discarded %i" % DROPPED_PKGS)
	print("Frames Sent %i" % GOOD_PKGS)
	print("Of which, there were %i Keyframes" % NUMBER_OF_ONES)
	print("Largest Frame Sent %i" % LARGEST)
	return
	

if __name__ == "__main__":
	main()