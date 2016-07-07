//" Add error handling à la Problem 4 to the configuration of Problem 7. 
//The router configuration file should be called prob8.click, it should read 
//from ‘f8a.dump’ and write to ‘f8b.dump’, it should discard IP TTL-expired 
//packets rather than generate errors, and ‘f8.drops’ should report any 
//packets dropped from queues after the errors already mentioned. "


//entonces esta es la elementclass del ejercicio 5
//con 2 counters extra para contar los paquetes muy largos y DoA

//funciona como un filtro con un output

elementclass ErrorChecker {
   input -> cip :: CheckIPHeader
      -> i1 :: IPClassifier(tcp, udp, icmp, -)
      -> ctcp :: CheckTCPHeader
      -> ttl :: IPFilter(1 ttl 0, allow all)
      -> cl :: CheckLength(1500)
      -> output;
   i1[1] -> cudp :: CheckUDPHeader -> ttl
   i1[2] -> cicmp :: CheckICMPHeader -> ttl
   i1[3] -> ttl
   ttl[1] -> cttl :: Counter -> d :: Discard
   cl[1] -> ccl :: Counter -> d
}

FromDump(click-tutorial1/f8a.dump, STOP true, TIMING true)
   -> e :: ErrorChecker
   -> proto :: IPClassifier(tcp, -)

p :: PrioSched
  proto[0] -> tcp_q :: Queue(10000) -> BandwidthShaper(36000) -> [0] p
  proto[1] -> udp_q :: Queue(10000) -> [1] p
  tcp_q -> [2] p

p -> BandwidthShaper(48000) -> SetTimestamp -> ToDump(click-tutorial1/f8b.dump, ENCAP IP)

DriverManager(pause, print >click-tutorial1/f8.drops e/cip.drops,
   print >>click-tutorial1/f8.drops e/ctcp.drops,
   print >>click-tutorial1/f8.drops e/cudp.drops,
   print >>click-tutorial1/f8.drops e/cicmp.drops,
   print >>click-tutorial1/f8.drops e/cttl.count,
   print >>click-tutorial1/f8.drops e/ccl.count,
   print >>click-tutorial1/f8.drops tcp_q.drops,
   print >>click-tutorial1/f8.drops udp_q.drops)