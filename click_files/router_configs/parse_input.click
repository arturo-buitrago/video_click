FromDump(video_click/traces/input_traces/medium_channel_no_changes.dump, TIMING true)

	//-> Classifier(23/11)

	-> Buffer_Flusher_User

	-> BandwidthShaper(128000)

	-> ToDump(video_click/traces/output_traces/rename_me.dump)

	-> Socket (UDP, 0.0.0.0, 54002)
