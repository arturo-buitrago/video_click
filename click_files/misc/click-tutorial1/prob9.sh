#! /bin/sh

click -e "
FromDump($1, STOP true)
   -> c :: Counter
   -> ip :: IPClassifier(tcp, udp, -)
   -> ct :: Counter
   -> shunt :: { input -> output }
   -> sa :: AggregateIP(ip src/8)
   -> s :: AggregateCounter(BYTES true)
   -> da :: AggregateIP(ip dst/8)
   -> d :: AggregateCounter(BYTES true)
   -> Discard

sa[1] -> Print -> Discard
da[1] -> Print -> Discard
ip[1] -> cu :: Counter -> shunt
ip[2] -> shunt

DriverManager(pause, print c.count, print c.byte_count,
      print ct.count, print ct.byte_count,
      print cu.count, print cu.byte_count,
      write d.write_ascii_file -,
      print ip.config, // get odd line
      write s.write_ascii_file -)
" | perl -e ’
$cn = <STDIN>; $cn_nonz = ($cn + 0) || 1;
$cb = <STDIN>;
$ctn = <STDIN>; $ctn_nonz = ($ctn + 0) || 1;
$ctb = <STDIN>;
$cun = <STDIN>; $cun_nonz = ($cun + 0) || 1;
$cub = <STDIN>;
print $cn, int($cb/$cn_nonz), "\n", int($ctb/$ctn_nonz), "\n", int($cub/$cun_nonz), "\n";
while (($_ = <STDIN>) && $_ !˜ /ˆt/) {
   print "dst $_" if !/ˆ!/;
}
while (($_ = <STDIN>)) {
   print "src $_" if !/ˆ!/;
}
’