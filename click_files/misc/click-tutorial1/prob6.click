//6.	Compound element overloading [3 points]. Create a partial router
// 		configuration file called prob6.click, based on prob5.click. This time,
// 		the ErrorChecker compound element should support three different use
// 		patterns. 

//		If it is used with one input and one output, it should behave 
// 		like in Problem 5. 

//		If it is used with one input and two outputs, then all 
// 		erroneous packets should be emitted on the second output (not dropped). 
 		

//		If it is used with one input and seven outputs, then the ﬁrst output 
// 		is for correct packets, and the following six outputs are used 
// 		for the six different errors. 


//		osea implementemos una subclase que haga todo el brete y cuando termine
//		hacemos una superfuncion que bote lo que no necesitamos


elementclass Core{
	input -> checkip :: CheckIPHeader
		-> classifier :: IPClassifier(tcp, udp, icmp, -)
		-> checktcp :: CheckTCPHeader
		-> ttl :: IPFfilter(drop ttl 0, allow all)
		-> cl :: CheckLength(1500)
		-> output;

	classifier[1] -> cudp :: CheckUDPHeader -> ttl
	classifier[2] -> cimcp :: CheckICMPHeader -> ttl
	classifier[3] -> ttl

	checkip[1] -> [1]output
	// IP Malos
	checktcp[1] -> [2]TCP
	//output malos
	cudp[1] -> [3]output
	//UDP malos
	cimcp[1] -> [4]output
	//IMCP malos
	ttl[1] -> [5]output
	//paquetes DoA
	cl[1] -> [6]output
}

elementclass ErrorChecker{
	//primer caso, solo queremos un output, el primero
	//osea nada mas botamos los otros 6 que no necesitamos

	input -> error :: Core -> output
	error[1] -> d :: Discard
	//al parecer para dos comandos en una linea si separamos con ;
	error[2] -> d ; error[5] -> d; error[3] -> d; error[4] -> d; error[6] -> d

|| // un oder aparentemente

	//mandamos todos los errores al segundo output
	input -> error :: Core -> output
	error[1] -> [1]output; error[2] -> [1]output; error[3] -> [1]output
	error[4] -> [1]output; error[5] -> [1]output; error[6] -> [1]output

||

	//soltamos todo donde debe ser
	input -> error :: Core -> output
	error[1] -> [1]output; error[2] -> [2]output; error[3] -> [3]output
	error[6] -> [6]output; error[4] -> [4]output; error[5] -> [5]output

}