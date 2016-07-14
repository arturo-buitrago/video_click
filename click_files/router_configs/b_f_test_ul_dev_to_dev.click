
FromDevice(eth0)
//	-> Queue(100000)

//	->BandwidthShaper(700000)

//	-> Unqueue

	-> Buffer_Flusher_User
	
	-> Socket(UDP, 192.168.45.2, 54001)

