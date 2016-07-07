
FromDump(video_click/Traces/clean_traces/tracedump_clean.pcap)
	
	-> BandwidthShaper(20000)
	
	-> Unqueue
	
	-> Buffer_Flusher

	-> BandwidthShaper(10000)
	
	-> ToDump(video_click/Traces/output_traces/trace_output.dump)



