	//Lee paquetes de f3a.dump y segun el error que encuentra los trata de forma diferente.
	//Problem 								Action
	//Invalid IP header or checksum 			Discard packet
	//Invalid TCP header or checksum 			Discard packet
	//Invalid UDP header or checksum 			Discard packet
	//Invalid ICMP header or checksum 			Discard packet
	//Expired IP TTL (time to live) 			Generate appropriate ICMP error message, send message to ‘f3f.dump’
	//Packet longer than 1500 bytes 			Discard packet 

FromDump(click-tutorial1/f4a.dump, STOP true)
	
		//me parece que este control flow tira cuando no se especifica siempre el primer elemento
		//e.g. first_filter[0]

		-> CheckIPHeader 
		// "CheckIPHeader emits valid packets on output 0. 
		//Invalid packets are pushed out on output 1, unless output 1 was unused; 
		//if so, drops invalid packets"
		//osea que es el primer filtro nada mas, revisa que no sea alguna estupidez que no es IP
		//lo tira en un solo output a first filter

		-> first_filter :: IPClassifier(tcp, udp, icmp, -)
		//"Classifies IP packets according to tcpdump-like patterns. 
		//The IPClassifier has N outputs, each associated with the corresponding pattern from the configuration string. 
		//The input packets must have their IP header annotation set; CheckIPHeader and MarkIPHeader do this"
		// ojo lo de tirar CheckIPHeader primero!
		//se splittea en 4 categorias:
		//ff[0] = TCP packets
		//ff[1] = UDP 
		//ff[2] = ICMP
		//ff[3] = todo lo demas

		->CheckTCPHeader(VERBOSE true)
		//muy parecido a CheckIPHeader
		//'Expects TCP/IP packets as input. Checks that the TCP header length and checksum fields are valid. 
		//Pushes invalid packets out on output 1, unless output 1 was unused; if so, drops invalid packets'
		//aqui agarramos ff[0] y botamos todo lo que tenga un header malo

		-> time_to_live :: IPClassifier(ttl > 0, -)
		//aqui lo que hace es revisar que el time to live sea positivo, que el paquete no haya llegado DoA
		//splittea en dos
		//ttl[0] = TCP vivas
		//ttl[1] = TCP muertas

		-> check_length :: CheckLength(1500)
		//hace lo que dice
		//'CheckLength checks every packet's length against LENGTH. 
		//If the packet is no larger than LENGTH, it is sent to output 0; otherwise, it is sent to output 1 (or dropped if there is no output 1). '
		//checkea ttl[0] para ver si no es muy grande

		-> clasificacion_final :: IPClassifier(dst 131.179.0.0/16, dst 131.0.0.0/8, dst 18.0.0.0/8, -)
		//aqui lo dividimos dependiendo del destino que tiene
		//splittea en 4 checklength, los primeros 3 son destinos especificos, en la 4ta el resto

	first_filter[1] -> CheckUDPHeader(VERBOSE true) -> time_to_live
	//' Expects UDP/IP packets as input. Checks that the UDP header length and checksum fields are valid. 
	//Pushes invalid packets out on output 1, unless output 1 was unused; if so, drops invalid packets.'
	
	first_filter[2] -> CheckICMPHeader(VERBOSE true) -> time_to_live
	//"Expects ICMP packets as input. Checks that the packet's length is sensible and that its checksum field is valid. 
	//Pushes invalid packets out on output 1, unless output 1 was unused; if so, drops invalid packets. "

	first_filter[3] -> time_to_live
	//OJO que pasa todos por time to live

	time_to_live[1] -> ICMPError(18.26.7.1, timeexceeded, transit)
								//Esta direccion es el MIT
		-> ToDump(click-tutorial1/f3f.dump, ENCAP IP)
	//el segundo output de time to live es el que nos da los paquetes que ya estan muy viejos!
	// aqui generamos una noticia de ICMP del source dado y le decimos que nos diga si es
	//un error en timeexceeded o transit
	//lo guardamos en f3f.dump, que es el de los errores para un TTL expirado


	clasificacion_final[0] -> ToDump(click-tutorial1/f3c.dump, ENCAP IP)
	clasificacion_final[1] -> ToDump(click-tutorial1/f3b.dump, ENCAP IP)
	clasificacion_final[2] -> ToDump(click-tutorial1/f3d.dump, ENCAP IP)
	clasificacion_final[3] -> ToDump(click-tutorial1/f3e.dump, ENCAP IP)