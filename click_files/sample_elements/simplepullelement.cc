#include <click/config.h>
#include <click/confparse.hh>
#include <click/error.hh>
#include "simplepullelement.hh"

int keyframenumber = 1;
int nonkeyframenumber = 1;


CLICK_DECLS
SimplePullElement::SimplePullElement()
{}

SimplePullElement::~ SimplePullElement()
{}

int SimplePullElement::configure(Vector<String> &conf, ErrorHandler *errh) {
	if (cp_va_kparse(conf, this, errh, "MAXPACKETSIZE", cpkM, cpInteger, &maxSize, cpEnd) < 0) return -1;
	if (maxSize <= 0) return errh->error("maxsize should be larger than 0");
	return 0;
}

Packet* SimplePullElement::pull(int){
	Packet* p = input(0).pull();
	if(p == 0){
		return 0;
	}
	click_chatter("Got a packet of size %d",p->length());
	const unsigned char *start = p -> data();
	for (int i=0; i<45;i++){
		*start++;
		//click_chatter("%i -> %p",i,*start);
		
	}
	click_chatter("Is it a keyframe -> %p",*start);
	
	if (*start==1){
		click_chatter("KEYFRAME NUMBER %i",keyframenumber);
		keyframenumber++;
		output(0) -> return(p);
	} else {
		click_chatter("NONKEYFRAME NUMBER %i",nonkeyframenumber);
		nonkeyframenumber++;
		output(1) -> return(p);
	}


}

CLICK_ENDDECLS
EXPORT_ELEMENT(SimplePullElement)
