#include <click/config.h>
#include <click/confparse.hh>
#include <click/error.hh>
#include <click/args.hh>
#include <click/deque.hh>
#include "buffer_flusher.hh"

int32_t last_keyframe_id = -1;
//int nonkeyframenumber = 1;
uint32_t pkg_num = 1;
int num_non_keyframes_since_last_keyframe = 0;

Deque<Packet *> queue;


CLICK_DECLS
Buffer_Flusher::Buffer_Flusher()
{}

Buffer_Flusher::~ Buffer_Flusher()
{}

int Buffer_Flusher::configure(Vector<String> &conf, ErrorHandler *errh) {
	//click_chatter("configure");


	//if (cp_va_kparse(conf, this, errh, "MAXPACKETSIZE", cpkM, cpInteger, &maxSize, cpEnd) < 0) return -1;
	//if (maxSize <= 0) return errh->error("maxsize should be larger than 0");
	//return 0;

	//Element *e;

    //if (Args(conf, this, errh).read_mp("QUEUE", e).complete() < 0)
	//return -1;

    //if (!(_q = static_cast<SimpleQueue *>(e->cast("SimpleQueue"))))
	//return errh->error("QUEUE argument must be a Queue element");

    return 0;

}




void Buffer_Flusher::push(int, Packet *p){
	int32_t frame_id_number = 0;
	uint32_t offset = 0;
	//click_chatter(" ");
	//click_chatter("%i. pkg",pkg_num);
	pkg_num++;


	//char var = "0";
	//const char *var_pt = "1";
	//click_chatter("Got a packet of size %d",p->length());
	//click_chatter("GODDAMN");
	//click_chatter("last keyframe id: %i",last_keyframe_id);
	const unsigned char *start = p->data();
	//start+2;
	for (int i=0; i<45;i++){
		*start++;
		//click_chatter("%i -> %p",i,*start);	
	}
	//click_chatter("%p",*start);
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
		//click_chatter("keyframe");
		offset = num_non_keyframes_since_last_keyframe;
		//click_chatter("%i %i",num_non_keyframes_since_last_keyframe,offset);
		//num_non_keyframes_since_last_keyframe = 0;

		if(*segment == 0){
		//SI ES EL INICIO DE UN SEGMENTO
			if (frame_id_number > last_keyframe_id){
				//SI EL KEYFRAME ID ES MAYOR AL ANTERIOR 
				last_keyframe_id = frame_id_number;

				//click_chatter("Buffer Flush!");

				int queue_size = queue.size();
				//click_chatter("Queue length before flush : %i",queue.size());
				//offset = 
				//PRIMER CASO
				if(offset<queue_size){
					//click_chatter("Buffer Flush! [case1]");
					//click_chatter("offset is %i",offset);
					for(uint32_t z=0;z<offset;z++){
						queue.pop_back();
						//click_chatter("pop");
					}
				}

				//SEGUNDO CASO
				else if(offset>=queue_size){
					//click_chatter("Buffer Flush! [case2]");

					queue.clear();
				}

				//TERCER CASO
				//else{no hago nada}
				//click_chatter("Queue length after flush : %i",queue.size());
			}
		}

		queue.push_back(p);
		num_non_keyframes_since_last_keyframe = 0;
	} else {
		//NOT A KEYFRAME
		//click_chatter("Not a keyframe");
		num_non_keyframes_since_last_keyframe++;
		//click_chatter("Number of non-keyframes since last one %i",num_non_keyframes_since_last_keyframe);
		queue.push_back(p);
	}
	//*start = *(start);

	//click_chatter("len queue after push %i",queue.size());
	//click_chatter("%p",*start);
	//if (p->length() > maxSize)  p->kill();
	//else output(0).push(p);
}

Packet * Buffer_Flusher::pull(int){
	//click_chatter("pull");
	if (queue.empty() == false){ //osea si la q no esta vacia
		//click_chatter("Package pulled!");

		Packet *pkg =  queue.front();
		queue.pop_front();
		//click_chatter("Length of Queue after pull : %i",queue.size());
		return pkg;
	}else{
		return 0;
	}

}




CLICK_ENDDECLS
EXPORT_ELEMENT(Buffer_Flusher)
