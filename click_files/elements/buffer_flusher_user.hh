#ifndef CLICK_BUFFER_FLUSHER_USER_HH
#define CLICK_BUFFER_FLUSHER_USER_HH
#include <click/element.hh>
#include "elements/standard/simplequeue.hh"
CLICK_DECLS

/*                  HEADER FILE                 */
/*This one is the header file for the flusher.  */
/*It's there pretty much so that click knows what*/
/*your element does and how to know whether it's*/
/*being applied correctly                       */

class Buffer_Flusher_User : public Element { 
	public:
		Buffer_Flusher_User();
		~Buffer_Flusher_User();

		const char *class_name() const	{ return "Buffer_Flusher_User"; }
		//Sets the name for the element. Click needs this to find your element.
		const char *port_count() const	{ return "1/1"; }
		//Sets the input/output ports.
		//I thought of having a second output for dropped packages, which is very doable, but decided
		//that it was ultimately unnecessary.
		const char *processing() const	{ return "h/lh"; }
		//This one took a long time to find. Due to the fact that this element works essentially like
		//a queue, its neither PUSH nor PULL nor AGNOSTIC. This type of processing is undeclared
		//and I only managed to find it by trawling through the header files of the Queues.

		//Defines the functions that the element has.
		int configure(Vector<String>&, ErrorHandler*);
		
		void push(int, Packet *);
		Packet* pull(int port);
	private:

};


CLICK_ENDDECLS
#endif