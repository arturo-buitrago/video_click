 //4. Handlers [2 points]. Create a router configuration file called prob4.click, 
//based on prob3.click. It should read from ‘f4a.dump’ and write to ‘f4*.dump’. 
//But this time, in addition to checking for errors, running the configuration 
//should generate a file ‘f4.drops’ containing the following 6 lines:

//    The number of packets with invalid IP headers or checksums;
//    The number of packets with invalid TCP headers or checksums;
//    The number of packets with invalid UDP headers or checksums;
//    The number of packets with invalid ICMP headers or checksums;
//    The number of packets with expired IP TTLs; and
//    The number of packets longer than 1500 bytes.

//Each packet will show up in at most one of these counts. 

/*
Aqui basicamente lo que hay que hacer es lo mismo que en el ejercicio pasado
solo que contando todos los paquetes que se detallan arriba.
*/

FromDump(click-tutorial1/f4a.dump, STOP true)
	-> checkip :: CheckIPHeader
	-> classifier :: IPClassifier(tcp, udp, icmp, -)
	-> checktcp :: CheckTCPHeader
	-> timetolive :: IPClassifier(ttl 0, -) [1]
	-> checklength :: CheckLength(1500)
	-> ipdest :: IPClassifier(dst 131.179.0.0/16, dst 131.0.0.0/8, dst 18.0.0.0/8, -)

classifier[1] -> checkudp :: CheckUDPHeader -> timetolive
classifier[2] -> checkicmp :: CheckICMPHeader -> timetolive
classifier[3] -> timetolive

timetolive[0] -> count_timetolive :: Counter
//"Passes packets unchanged from its input to its output, 
//maintaining statistics information about packet count and packet rate."

//aqui contamos todos los paquetes que fallaron el ttl

	-> ICMPError(18.26.7.3, timeexceeded, transit)
	-> ToDump(click-tutorial1/f4f.dump, ENCAP IP)

ipdest[0] -> ToDump(click-tutorial1/f4c.dump, ENCAP IP)
ipdest[1] -> ToDump(click-tutorial1/f4b.dump, ENCAP IP)
ipdest[2] -> ToDump(click-tutorial1/f4d.dump, ENCAP IP)
ipdest[3] -> ToDump(click-tutorial1/f4e.dump, ENCAP IP)

checklength[1] -> count_checklength :: Counter -> Discard
//contamos la cantidad de paquetes que son demasiado largos
//ojo que es el segundo output de CheckLength

DriverManager(pause, 
	print >click-tutorial1/f4.drops "Dropped IP packets",
	print >>click-tutorial1/f4.drops checkip.drops, //los que bota el CheckIPHeader
	print >>click-tutorial1/f4.drops "",

	print >>click-tutorial1/f4.drops "Dropped TCP packets",
	print >>click-tutorial1/f4.drops checktcp.drops, //TCP
	print >>click-tutorial1/f4.drops "",

	print >>click-tutorial1/f4.drops "Dropped UDP packets",
	print >>click-tutorial1/f4.drops checkudp.drops, //UDP
	print >>click-tutorial1/f4.drops "",

	print >>click-tutorial1/f4.drops "Dropped ICMP packets",
	print >>click-tutorial1/f4.drops checkicmp.drops, //ICMP
	print >>click-tutorial1/f4.drops "",

	print >>click-tutorial1/f4.drops "Dropped packets due to TTL",
	print >>click-tutorial1/f4.drops count_timetolive.count, //aqui dejamos de usar .drops porque la funcion no es un CheckXXX
	print >>click-tutorial1/f4.drops "",

	print >>click-tutorial1/f4.drops "Dropped packets due to length",
	print >>click-tutorial1/f4.drops count_checklength.count,
	print >>click-tutorial1/f4.drops "",
	)

//esto es nada mas un scrip que imprime lo que queremos en el documento f4.drops
// ">>" significa en newline
//si no escribimos en newline, la line se sobreescribe