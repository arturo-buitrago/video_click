
FromDevice(eth0)
	-> Queue(100000)

	-> BandwidthShaper(50000)
	
	-> DelayUnqueue(2)
	
	-> Buffer_Flusher_User

	-> BandwidthShaper(50000)
	
	-> ToDevice(eth0)

