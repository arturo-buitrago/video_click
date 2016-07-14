//	Lee paquetes de f2a.dump y los routea siguiendo una cierta routing table
//	131.0.0.0/8 -> f2b.dump
//	131.179.0.0/16 -> f2c.dump
//	18.0.0.0/8 -> f2d.dump
//	otros -> f2e.dump
//
//	RadixIPLookup (read.cs.ucla.edu/click/elements/radixiplookup)
//	Al parecer por como traversa el arbol es mejor usar este que algun 
//  otro metodo linear.



FromDump(click-tutorial1/f2a.dump, STOP true)
//el stop hace que pare de leer cuando ya no queden mas elementos que leer
	-> r :: RadixIPLookup(131.0.0.0/8 0, 131.179.0.0/16 1, 18.0.0.0/8 2, 0/0 3)
	// RadixIPLookup(ADDR1/MASK1 [GW1] OUT1, ADDR2/MASK2 [GW2] OUT2, ...) 
r[0] -> ToDump(click-tutorial1/f2b.dump, ENCAP IP)
r[1] -> ToDump(click-tutorial1/f2c.dump, ENCAP IP)
r[2] -> ToDump(click-tutorial1/f2d.dump, ENCAP IP)
r[3] -> ToDump(click-tutorial1/f2e.dump, ENCAP IP)