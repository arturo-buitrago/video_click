//Create a router configuration file called prob7.click. It should read 
//packets from ‘f7a.dump’, maintaining the timing of the dump file. 
//(This means that if two adjacent packets in the dump ﬁle have 
//timestamps that are 0.5 seconds apart, the packets will be emitted 
//into the conﬁguration 0.5 seconds apart.) The packets should be written 
//into ‘f7b.dump’, except that:

	//Packets should be written to the dump at a maximum rate of 384 Kb/s. Since 
	//the input rate might be more than 384 Kb/s, this means you will need queuing 
	//and traffic shaping in your conﬁguration.

	// TCP should always get up to 75% of the bandwidth (up to 288 Kb/s). This 
	//means that if the TCP input rate is 288 Kb/s and the UDP input rate is also 
	//288 Kb/s, TCP’s output rate will equal 288 Kb/s and UDP’s output rate will be 
	//limited to 96 Kb/s. If the TCP input rate is less than 288 Kb/s, UDP and other
	//kinds of traffic can take up the remainder.

	 //Similarly, 25% of the bandwidth should be reserved for UDP and other 
	 //traffic, if there is enough UDP and other traffic to take up the slack.

//Packet timestamps in the output ﬁle should reﬂect the 384 Kb/s rate limit. 

FromDump(click-tutorial1/f7a.dump, STOP true, TIMING true)
//Timing true trata entonces de mantener el tiempo en el que los paquetes llegaron
	->ipclass :: IPClassifier(tcp, -)
	//para diferenciar paquetes TCP de los UDP
priority_scheduler :: PrioSched
	//"Each time a pull comes in the output, PrioSched pulls from each of 
	//the inputs starting from input 0. The packet from the first successful 
	//pull is returned. This amounts to a strict priority scheduler. 
	//The inputs usually come from Queues or other pull schedulers. 
	//PrioSched uses notification to avoid pulling from empty inputs." 

	//Osea el primero que le da un paquete es el que pasa, empezando por el 0
	//Entonces efectivamente les da prioridad continuamente

	//ahora implementamos dos queues separadas, una para UDP y otra para TCP
	ipclass[0] -> tcp_q :: Queue(10000) -> BandwidthShaper(36000) -> [0]priority_scheduler
	ipclass[1] -> udp_1 :: Queue(10000) -> [1]priority_scheduler
	//" BandwidthShaper is a pull element that allows a maximum bandwidth of 
	//RATE to pass through. That is, output traffic is shaped to RATE. If a 
	//BandwidthShaper receives a large number of evenly-spaced pull requests, 
	//then it will emit packets at the specified RATE with low burstiness. "

	//RATE es en Bytes/s
	//288 kb/s == 36 kB/s == 36000 B/s
	//384 kb/s == 48 kB/s == 48000 B/s

	//ahora para cuando no hay paquetes de ninguna de las dos queues, para
	//agarrar lo que queda de bandwidth

	tcp_q -> [2]priority_scheduler

priority_scheduler -> BandwidthShaper(48000) -> SetTimestamp -> ToDump(click-tutorial1/f7b.dump, ENCAP IP)
DriverManager(pause, wait 2s)