//Takes the medium channel benchmark and follows the delay betweeen packages
//Sends it then to the Socket specified below
//TIMING makes it follow the delay between packages specified in the input dump file
//STOP makes the router configuration close after the whole file has been read

define($FILE video_click/traces/clean_traces/benchmark_slow_channel.pcap)


FromDump($FILE, TIMING true, STOP true)

	-> Buffer_Flusher_User
	
	-> Socket(UDP, 192.168.45.2, 54002)

