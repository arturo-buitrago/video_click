//receives packages from the specified device and first filters them
//"23/11" means that after a 23 byte offset the number should be 11
//which means its a UDP package. You can change it easily to mean anything else.

//For some reason IPClassifier causes segfaults in the machine used to test, so I couldn't further filter the packages by port. This shouldnt be too much of a problem.


FromDevice(eth0)

	-> Classifier(23/11)

	-> Buffer_Flusher_User

	-> BandwidthShaper(2048000)

	-> ToDump(video_click/traces/output_traces/RENAME_ME.dump)

	-> Socket (UDP, 0.0.0.0, 54002)
