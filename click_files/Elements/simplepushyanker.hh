#ifndef CLICK_SIMPLEPUSHYANKER_HH
#define CLICK_SIMPLEPUSHYANKER_HH
#include <click/element.hh>
#include "elements/standard/simplequeue.hh"
CLICK_DECLS

class SimplePushYanker : public Element { 
	public:
		SimplePushYanker();
		~SimplePushYanker();
		

		//inline Packet* deqyank();


		const char *class_name() const	{ return "SimplePushYanker"; }
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
