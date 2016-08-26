INTRODUCTION TO CLICK
=======

The Click Modular Router (http://read.cs.ucla.edu/click/click) is a project that was born out of a paper by Kohler et al. in 2000. It is designed to be a virtual router that is easily extendible and connects seamlessly with the linux kernel. 

The software works by mounting a router configuration file (see ./click_files/router_configs), which is written in Click's own simple syntax, either at the userlevel or as a kernel thread (see running your config file section below).

Click works by concatenating elements that can have multiple inputs and outputs, which then route, analyze and drop (among other things) packages which they receive. Inputs and Outputs can be either Pull, Push or Agnostic and they have to be connected in the correct manner for the router to even initialize (see paper for details). 

You can process packets streams from dump files, devices, among others, as well as output them in the same formats. It actually is a powerful tool, but it has a bit of a learning curve, so bear with it.

If you wonder why Click was chosen instead of other options, please refer to the appropriate documentation file.

INSTALLATION
=======

Now when installing, you might be tempted to just click on the download link on the UCLA page up there. Don't. Not only will you get an outdated version, you will most certainly be missing subelements that you need in order for the buffer flusher element to work at all.

The best way to get the most recent version of the Click software is to head to its creator's github page (https://github.com/kohler/click). That is the repository you should download, with git if at all possible. 

After donwloading it, just navigate to the click folder with your terminal and run 
.../click$ sudo ./configure
.../click$ sudo make install

Now if you only want the userlevel version or any other kinds of fancy installation tricks, please see the INSTALL file in your click folder.

To check if everything has installed correctly, run the test router configuration file ".../click/conf/test.click", on either level (see "RUNNING YOUR CONFIG FILE" below). If running at the userlevel, the terminal should print a series of numbers, the kernel thread will print them in the log file, which you can access simply by entering the following command:

$ dmesg

Note that there are many elements that are exclusive to either the user or the kernel level. Whether these distinctions are actually enforced is variable, but a good rule of thumb is elements under the .../click/elements/userlevel/ folder are exclusively userlevel, while those under .../click/elements/linuxmodule/ are mostly exclusive to the kernel level. Check the proper documentation for more details.

LEARNING CLICK
=======

The first thing to do is look at the small tutorial in the Click website (http://read.cs.ucla.edu/click/tutorial1). It's made for people that already have some experience with packet manipulation. If you have no previous experience, it's still very useful for catching up to syntax and the underlying structure of it all. Note that you can see the answers (http://read.cs.ucla.edu/click/tutorial1solutions) too (I recommend comparing them side by side).

The example configurations can also give some good insight into how Click actually manages packets. You can find example configurations in the click folder, under:
.../click/conf
There's also a small explanation for each online (http://read.cs.ucla.edu/click/examples).

Finally, the University of Antwerp has some good presentations explaining Click at a more fundamental level. These are really useful especially for writing your own elements (https://www.pats.ua.ac.be/software). 

Speaking of creating your own elements, take your cues from the elements already given. They work. They are not amazingly documented, but the Doxygen documentation may help a lot (http://read.cs.ucla.edu/click/doxygen/) - remember to use the search function to find what you need.

There's also some old mailing lists still floating around the internet that maaaay have answers for your problems (https://pdos.csail.mit.edu/pipermail/click/). Remember to use google or something to trawl through it, its a bunch of text. 


RUNNING YOUR CONFIG FILE
=======

Before you do anything, have you changed anything in your custom elements? If so, please run:

.../click$ sudo make elemlist
.../click$ sudo make

This will tell the program that there are new elements that should be added to the existing list of elements.

Now, sometimes Click forgets that you've done this already (don't ask me why, it just does), so don't despair immediately if your router won't start. Try the elemlist trick again.

Running at the userlevel
-----------

For the userlevel, enter the following:

.../click$ userlevel/click path_to_router_config/router_config.click

You may or may not need to use sudo here, depending on where you're running it from. This should start the router config, which will run until it shuts itself down, crashes or you interrupt it willingly (Control + C). Sometimes crashes will make the terminal hang, but you can just kill the process like you would normally.

Running at the Kernel Thread level
-----------

I hope I don't need to stress that the Kernel Thread option, despite being more powerful, is quite a bit of a pain in the neck. If you crash hard, you're crashing the kernel, so be careful about what you do. Don't play too much with memory unless you know what you're doing and have a backup of your files. I fortunately didn't manage to brick any computers, but that's probably because of lack of imagination/time.

In any case, you have to "install" and "uninstall" every new router configuration files you want to use. In my experience, Linux will often be smart enough to cut off any dumb stuff your elements are doing, but you can't really kill a kernel thread cleanly when it's already running, so a reboot is necessary when your code is buggy. The following commands are the ones you need:

.../click$ sudo click-install path_to_router_config/router_config.click

And to unmount simply:

.../click$ sudo click-uninstall

Remember about some elements being exclusive for one level or the other!

If you want to check what kernel threads are running, remember to either look for the router initialization message using 

$ dmesg

or by listing all current kernel threads. The following command is one of many that work (on Ubuntu at least):

$ps -ef | grep "\[" 

Look for the one with the name "kclick".
