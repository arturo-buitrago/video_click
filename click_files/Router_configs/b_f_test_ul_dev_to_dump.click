
FromDevice(eth0)
	
	-> Buffer_Flusher_User

	-> BandwidthShaper(100000)
	
	-> ToDump(video_click/Traces/output_traces/dev_to_dump.dump)

