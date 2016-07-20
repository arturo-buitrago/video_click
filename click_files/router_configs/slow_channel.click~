//Takes the slow channel benchmark and follows the delay betweeen packages
//Sends it then to the Socket specified below

define($FILE video_click/traces/clean_traces/benchmark_slow_channel.pcap, $IPADDR 192.168.45.2 $PORT 54001)


FromDump($FILE, TIMING true)

	-> Buffer_Flusher_User
	
	-> Socket(UDP, $IPADDR, $PORT)

