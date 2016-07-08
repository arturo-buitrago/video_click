
FromDevice(eth0)
	
	//-> BandwidthShaper(20000)
	
	//-> Queue(100000)
	
	-> Buffer_Flusher

	//->BandwidthShaper(100000)

	//-> Queue(10000000)
	
	-> ToDevice(eth0)


