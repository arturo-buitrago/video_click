// PROBLEM 5

//5. Compound elements [3 points]. Create a partial router configuration 
//file called prob5.click. This file should deﬁne a compound element 
//named ‘ErrorChecker’ with one input and one output that implements 
//all the error checks from Problem 3. All erroneous packets should 
//be dropped (not written to a file). 

//Osea aqui ya creamos nuestro propio elemento que haga las carajadas
//que ya hicimos 2 veces


elementclass ErrorChecker{
	input -> checkip :: CheckIPHeader
		-> classifier :: IPClassifier(tcp, udp, icmp, -)
		-> checktcp :: CheckTCPHeader
		-> ttl :: IPFilter(drop ttl 0, allow all)
			//IP Filter es mas simple que IPClassifier, hace lo que dice
		->checklength :: CheckLength(1500)
		-> output;

	classifier[1] -> checkudp :: CheckUDPHeader -> ttl
	classifier[2] -> checkicmp :: CheckICMPHeader -> ttl
	classifier[3] -> ttl

}
