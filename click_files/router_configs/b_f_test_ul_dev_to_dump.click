
FromDevice(eth0)
	//-> Queue(100000)
	
	//-> BandwidthShaper(8000)
	
	//-> Unqueue
	
	-> Buffer_Flusher_User

	-> BandwidthShaper(50000)
	
	-> ToDump(video_click/Traces/output_traces/dev_to_dump.dump)
