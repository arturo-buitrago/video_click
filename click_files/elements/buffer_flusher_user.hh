#ifndef CLICK_BUFFER_FLUSHER_USER_HH
#define CLICK_BUFFER_FLUSHER_USER_HH
#include <click/element.hh>
#include "elements/standard/simplequeue.hh"
CLICK_DECLS

class Buffer_Flusher_User : public Element { 
	public:
		Buffer_Flusher_User();
		~Buffer_Flusher_User();
		

		//inline Packet* deqyank();


		const char *class_name() const	{ return "Buffer_Flusher_User"; }
		const char *port_count() const	{ return "1/1"; }
		const char *processing() const	{ return "h/lh"; }
		int configure(Vector<String>&, ErrorHandler*);
		
		void push(int, Packet *);
		Packet* pull(int port);
	private:
		//uint32_t maxSize;
		//SimpleQueue *_q;
};


CLICK_ENDDECLS
#endif
