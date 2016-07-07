
FromDevice(eth0)
	
	//-> BandwidthShaper(20000)
	
	//-> Unqueue
	
	-> Buffer_Flusher

	//-> BandwidthShaper(10000)
	
	-> ToDevice(eth0)


