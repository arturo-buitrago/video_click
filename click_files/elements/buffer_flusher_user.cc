#include <click/config.h>
#include <click/confparse.hh>
#include <click/error.hh>
#include <click/args.hh>
#include <click/deque.hh>
#include "buffer_flusher_user.hh"

int32_t last_keyframe_id = -1;
uint32_t pkg_num = 1;
int num_non_keyframes_since_last_keyframe = 0;

//This is the actual queue, we use a structure that is already defined by click.
//Often (required for running at Kernel level)
Deque<Packet *> queue;


CLICK_DECLS
Buffer_Flusher_User::Buffer_Flusher_User()
{}

Buffer_Flusher_User::~ Buffer_Flusher_User()
{}

int Buffer_Flusher_User::configure(Vector<String> &conf, ErrorHandler *errh) {
	//click_chatter("configure");
    return 0;

}

/*------------------------------------------PUSH------------------------------------------------*/
/*Most of the workload will fall on the push function below, because it's at the push moment that we 
want our buffer flusher implemented. You could also conceivably move this functionality over
to the pull function, but this seemed more natural                                              */

void Buffer_Flusher_User::push(int, Packet *p){
	int32_t frame_id_number = 0;
	uint32_t offset = 0;

	//keeps track of the packet number
	pkg_num++;

	/*                            POINTERS -> IDENTIFIERS                                      */
	/* In this section we make sure that the pointers that we need do so in the right direction*/
	/*                                                                                         */

	//Here we move a pointer to where the keyframe identifier should be
	// 1 means keyframe, 0 means non-keyframe
	const unsigned char *start = p->data();
	
	for (int i=0; i<45;i++){
		*start++;
	}
	//This loop looks kinda dumb, but just simply adding 45 doesn't work


	//Here we determine the frame identifier, which is 2 bytes ahead of the keyframe identifier
	const unsigned char *frame_id = start;
	for (int i=0; i<3;i++){
		*frame_id++;
	} 
	//To avoid int overflow, we calculate the first byte, then the second one and add them together
	frame_id_number += (*frame_id)*(256);
	*frame_id++;
	frame_id_number += *frame_id;

	//Here we continue with segment id
	//This isn't strictly needed, but would come in handy if we wanted to ensure that
	//the packages come at exactly the right order
	const unsigned char *segment = frame_id;
	for (int i=0; i<4;i++){
		*segment++;
	}

	/*                                     BUFFER FLUSHER                                      */
	/* Here's where the proverbial flushing of buffers take place. Note that most of the       */
	/* functions called are ones you already know. Deque is a double-ended queue! For more info*/
	/* look for the doxygen documentation on deque or look at the deque.h file.                */


	if (*start==1){
	//If we have a keyframe
		offset = num_non_keyframes_since_last_keyframe;
		//Hold the number of non keyframes since our last keyframe as the offset

		if(*segment == 0){
		//If it is the start of a segment:
		//This is very important, flushing at every keyframe would theoretically work but would
		//be a waste of resources. Click eats enough CPU as it is.

			if (frame_id_number > last_keyframe_id){
				//Pretty much a failsafe, ensures that the order is correct
				
				last_keyframe_id = frame_id_number;
				//Resets last keyframe
				
				int queue_size = queue.size();


				//FIRST FLUSH CASE
				//The queue has a mix of both keyframes and non-keyframes
				//This is the rarer of the two cases
				if(offset<queue_size){
					for(uint32_t z=0;z<offset;z++){
						queue.pop_back();
						//Get rid of all non-keyframes that have been pushed so far up to the last keyframe pushed
					}
				}

				//SECOND FLUSH CASE
				//The queue is full of non-keyframes
				//This is the more likely case, unless you have long queues or low bandwidth
				else if(offset>=queue_size){
					queue.clear();
					//Drops all packages in queue
				}

			}
		}

		queue.push_back(p);
		num_non_keyframes_since_last_keyframe = 0;
		//We push after all appropriate flushing has taken place
		//And reset the number of non-keyframes since last keyframe

	} else {
		//If not a keyframe:

		num_non_keyframes_since_last_keyframe++;
		queue.push_back(p);
		//Just add to queue normally
	}

}


/*------------------------------------------PULL------------------------------------------------*/
/*This function works as in a very normal queue. It was modeled after the SimpleQueue element, */
/*if you want to borrow any other ideas. Never had had trouble with it                          */
/*Pops if not empty.                                                                            */

Packet * Buffer_Flusher_User::pull(int){

	if (queue.empty() == false){
		Packet *pkg =  queue.front();
		queue.pop_front();
		return pkg;
	}else{
		return 0;
	}

}




CLICK_ENDDECLS
EXPORT_ELEMENT(Buffer_Flusher_User)
