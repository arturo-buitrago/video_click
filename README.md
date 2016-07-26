INTRO : BUFFER FLUSHER

The aim of this project is to implement a buffer flushing mechanism as described in the paper "Low Delay Video Transmission Strategies" (Bachhuber et al, find it under video_click/papers). It works by maintaining a queue of outgoing packets that reacts to new packets being appended to it. Whenever a packet belonging to a frame marked as a "keyframe" flows in, the queue is flushed of "non-keyframes", so that the transmission of the keyframe can happen as quickly as possible. Any keyframes in the queue before the new one gets there will not be affected.

The flusher is implemented using the Click Modular Router (see INTRO_TO_CLICK.txt in this same folder), which creates virtual routers and is capable of running them as a kernel thread (as of now, however, the buffer can only run at the userlevel). 

FOLDER STRUCTURE

./click_files - This subfolder contains all the files pertaining to click, including the router configurations used, elements written and other useful files.

./documentation - Contains documentation about the project, including status reports and results.

./packet_creation - Contains small programs and scripts to create and send the packages out of the traces given from one computer to the other. 

./papers - Contains various scientific papers pertaining to the topic at hand, including a couple of useful presentations to familiarize yourself with click.

./screenshots - Contains screenshots of useful information, mostly bugs.

./traces - Contains all traces used, especially cross-traffic and input traces. The traces that show the result of the measurements are stored in a different repository due to portability.

