
FromDump(traceuser/tracedump_clean.pcap)
	
	-> BandwidthShaper(20000)
	
	-> Unqueue
	
	-> SimplePushYanker

	-> BandwidthShaper(10000)
	
	-> ToDump(traceuser/filtereddump.dump)



