#include <click/config.h>
#include <click/confparse.hh>
#include <click/error.hh>
#include "simplepushelement.hh"

int keyframenumber = 1;
int nonkeyframenumber = 1;

CLICK_DECLS
SimplePushElement::SimplePushElement()
{}

SimplePushElement::~ SimplePushElement()
{}

int SimplePushElement::configure(Vector<String> &conf, ErrorHandler *errh) {
	if (cp_va_kparse(conf, this, errh, "MAXPACKETSIZE", cpkM, cpInteger, &maxSize, cpEnd) < 0) return -1;
	if (maxSize <= 0) return errh->error("maxsize should be larger than 0");
	//return 0;
}

void SimplePushElement::push(int, Packet *p){
	//click_chatter("Got a packet of size %d",p->length());
	//click_chatter("GODDAMN");
	const unsigned char *start = p->data();
	//start+2;
	for (int i=0; i<45;i++){
		*start++;
		//click_chatter("%i -> %p",i,*start);
		
	}

	//click_chatter("Is it a keyframe -> %p",*start);


	if (*start==1){
		//click_chatter("KEYFRAME NUMBER %i",keyframenumber);
		keyframenumber++;
		output(0).push(p);
	} else {
		//click_chatter("NONKEYFRAME NUMBER %i",nonkeyframenumber);
		nonkeyframenumber++;
		output(1).push(p);
	}
	//*start = *(start);

	//click_chatter("%p",*p->end_data());
	//click_chatter("%p",*start);
	//if (p->length() > maxSize)  p->kill();
	//else output(0).push(p);
}

CLICK_ENDDECLS
EXPORT_ELEMENT(SimplePushElement)
