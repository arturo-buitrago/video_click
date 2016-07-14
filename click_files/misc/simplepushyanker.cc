#include <click/config.h>
#include <click/confparse.hh>
#include <click/error.hh>
#include <click/args.hh>
#include <click/deque.hh>
#include "simplepushyanker.hh"

int32_t last_keyframe_id = -1;
//int nonkeyframenumber = 1;
int num_non_keyframes_since_last_keyframe = 0;

Deque<Packet *> q;


CLICK_DECLS
SimplePushYanker::SimplePushYanker()
{}

SimplePushYanker::~ SimplePushYanker()
{}

int SimplePushYanker::configure(Vector<String> &conf, ErrorHandler *errh) {
	//if (cp_va_kparse(conf, this, errh, "MAXPACKETSIZE", cpkM, cpInteger, &maxSize, cpEnd) < 0) return -1;
	//if (maxSize <= 0) return errh->error("maxsize should be larger than 0");
	//return 0;

	Element *e;

    if (Args(conf, this, errh).read_mp("QUEUE", e).complete() < 0)
	return -1;

    if (!(_q = static_cast<SimpleQueue *>(e->cast("SimpleQueue"))))
	return errh->error("QUEUE argument must be a Queue element");

    return 0;

}

namespace {

struct Foo {
    const unsigned char *s;
    Foo(const char *ss) : s(reinterpret_cast<const unsigned char *>(ss)) { }
    bool operator()(const Packet *p) {
	for (const unsigned char *ss = s; *ss; ss++){
		//click_chatter("%c",p->data);
	    if (p->data()[0] == *ss){
	    	//click_chatter("match in foo!");
		return true;}
	}
	return false;
    }
};

}


void SimplePushYanker::push(int, Packet *p){
	int32_t frame_id_number = 0;

	//char var = "0";
	const char *var_pt = "1";
	//click_chatter("Got a packet of size %d",p->length());
	//click_chatter("GODDAMN");
	//click_chatter("last keyframe id: %i",last_keyframe_id);
	const unsigned char *start = p->data();
	//start+2;
	for (int i=0; i<45;i++){
		*start++;
		//click_chatter("%i -> %p",i,*start);	
	}

	//start ahora esta en el pointer de 1/0

	const unsigned char *frame_id = start;
	for (int i=0; i<3;i++){
		*frame_id++;
	} 
	//esto por lo del int overflow
	frame_id_number += (*frame_id)*(256);
	*frame_id++;
	frame_id_number += *frame_id;
	//click_chatter("Frame id -> %p",*frame_id);	


	const unsigned char *segment = frame_id;
	for (int i=0; i<4;i++){
		*segment++;
	}
	//click_chatter("Segment -> %p",*segment);	


	if (*start==1){
	//SI ES UN KEYFRAME
		num_non_keyframes_since_last_keyframe = 0;

		if(*segment == 0){
		//SI ES EL INICIO DE UN SEGMENTO
			if (frame_id_number > last_keyframe_id){
				//SI EL KEYFRAME ID ES MAYOR AL ANTERIOR 
				last_keyframe_id = frame_id_number;

				click_chatter("YANK DAT");

				int queue_size = q->size();

				//PRIMER CASO
				if(num_non_keyframes_since_last_keyframe<queue_size){
					for(int i=0;i<num_non_keyframes_since_last_keyframe;i++){
						q->pop_back();;
					}
				}

				//SEGUNDO CASO
				else if(num_non_keyframes_since_last_keyframe>=queue_size){
					q->clear();
				}

				//TERCER CASO
				//else{no hago nada}
				}
			}
		}

		output(0).push(p);
	} else {
		//NOT A KEYFRAME
		num_non_keyframes_since_last_keyframe++;
		output(0).push(p);
	}
	//*start = *(start);

	click_chatter("len queue after push %i",_q->size());
	//click_chatter("%p",*start);
	//if (p->length() > maxSize)  p->kill();
	//else output(0).push(p);
}

CLICK_ENDDECLS
EXPORT_ELEMENT(SimplePushYanker)
