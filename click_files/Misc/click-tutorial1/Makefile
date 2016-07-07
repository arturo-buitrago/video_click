check: check-prob1 check-prob2 check-prob3 check-prob4 check-prob7 check-prob9
# check-prob5 check-prob6 check-prob7 check-prob8 check-prob9 check-prob10

check-prob1: f1a.dump
	@if [ -f prob1.click ]; then \
	    /bin/rm -f f1b.dump; \
	    click prob1.click && ./compare-traces -p 1 f1a.dump f1b.dump; \
	else echo "*** Problem 1 not started" 1>&2; fi

check-prob2: f2a.dump
	@if [ -f prob2.click ]; then \
	    /bin/rm -f f2b.dump f2c.dump f2d.dump f2e.dump; \
	    click prob2.click && ./compare-traces -p 2 f2b.dump good/f2b.dump \
	    && ./compare-traces -p 2 f2c.dump good/f2c.dump \
	    && ./compare-traces -p 2 f2d.dump good/f2d.dump \
	    && ./compare-traces -p 2 f2e.dump good/f2e.dump; \
	else echo "*** Problem 2 not started" 1>&2; fi

check-prob3: f3a.dump
	@if [ -f prob3.click ]; then \
	    /bin/rm -f f3b.dump f3c.dump f3d.dump f3e.dump f3f.dump; \
	    click prob3.click && ./compare-traces -p 3 f3b.dump good/f3b.dump \
	    && ./compare-traces -p 3 f3c.dump good/f3c.dump \
	    && ./compare-traces -p 3 f3d.dump good/f3d.dump \
	    && ./compare-traces -p 3 f3e.dump good/f3e.dump \
	    && click -e "FromDump(f3f.dump, STOP true) -> StoreData(12, \<00000000>) -> SetIPChecksum -> ToDump(f3f-z.dump, ENCAP IP)" \
	    && ./compare-traces -t -p 3 f3f-z.dump good/f3f.dump; \
	else echo "*** Problem 3 not started" 1>&2; fi

check-prob4: f4a.dump
	@if [ -f prob4.click ]; then \
	    /bin/rm -f f4b.dump f4c.dump f4d.dump f4e.dump f4f.dump; \
	    click prob4.click && ./compare-traces -p 4 f4b.dump good/f3b.dump \
	    && ./compare-traces -p 4 f4c.dump good/f3c.dump \
	    && ./compare-traces -p 4 f4d.dump good/f3d.dump \
	    && ./compare-traces -p 4 f4e.dump good/f3e.dump \
	    && click -e "FromDump(f4f.dump, STOP true) -> CheckIPHeader -> StoreData(12, \<00000000>) -> SetIPChecksum -> ToDump(f4f-z.dump, ENCAP IP)" \
	    && ./compare-traces -t -p 4 f4f-z.dump good/f3f.dump \
	    && cmp f4.drops good/f4.drops; \
	else echo "*** Problem 4 not started" 1>&2; fi

check-prob7: f7a.dump
	@if [ -f prob7.click ]; then \
	    /bin/rm -f f7b.dump f7.interval f7.tcount f7.ucount; \
	    click prob7.click \
	    && click -e 'FromDump(f7b.dump, END_AFTER 2s, STOP true) -> tr :: TimeRange -> c :: IPClassifier(tcp, -) -> ct :: Counter -> d :: Discard; c[1] -> cu :: Counter -> d; DriverManager(wait_stop, save tr.interval f7.interval, save ct.count f7.tcount, save cu.count f7.ucount)' \
	    && perl -e '$$i = `cat f7.interval`; $$t = `cat f7.tcount`; $$u = `cat f7.ucount`; chomp($$i, $$t, $$u); $$n = $$t+$$u; $$r = $$n*266*8 / $$i; if ($$r < 375000 || $$r > 393000) { print STDERR "*** Problem 7: bad rate ($$r, should be ~384000)\n"; exit(1); } if ($$t < 2.85*$$u) { print STDERR "*** Problem 7: too few TCP packets ($$t/$$n, should be ~3/4)\n"; exit(1); } if ($$t > 3.15*$$u) { print STDERR "*** Problem 7: too few non-TCP packets ($$u/$$n, should be ~1/4)\n"; exit(1); } if ($$t + $$u < 300) { print STDERR "*** Problem 7: too few packets ($$n)\n"; exit(1); } exit(0);' \
	    && echo "--- Problem 7 Success" 1>&2; \
	else echo "*** Problem 7 not started" 1>&2; fi

check-prob9:
	@if [ -x prob9 ]; then \
	    /bin/rm -f f9; \
	    ./prob9 f1a.dump > f9 && cmp f9 good/f9 && echo "--- Problem 9 Success: f9 == good/f9" 1>&2; \
	else echo "*** Problem 9 not started" 1>&2; fi

distdir = readable-ps2
dist:
	rm -rf $(distdir)
	mkdir $(distdir) $(distdir)/good
	chmod 777 $(distdir) $(distdir)/good
	cp Makefile VERSION compare-traces f1a.dump f7a.dump $(distdir)
	cd $(distdir) && ln -s f1a.dump f2a.dump && ln -s f1a.dump f3a.dump && ln -s f1a.dump f4a.dump && ln -s f1a.dump f8a.dump
	ln good/f??.dump good/f4.drops good/f9 $(distdir)/good
	tar czf $(distdir).tar.gz $(distdir)
	rm -rf $(distdir)

f2a.dump f3a.dump f4a.dump f8a.dump: f1a.dump
	ln -s $< $@

.PHONY: check check-prob1 check-prob2 check-prob3 check-prob4 check-prob5 \
	check-prob6 check-prob7 check-prob8 check-prob9 check-prob10 dist
