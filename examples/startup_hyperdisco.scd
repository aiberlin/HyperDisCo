/*** EXAMPLE STARTUP FILE for a HyperDisCo workshop setup

/////////// PART A --  startup file:

// RECOMMENDED: using StartupFILE quark
1. open StartupFile directory:
StartupFile.openDir;
2. Save a personal copy of this example file there
3. Personalize it:
-- change q.myID to your preferred ID name!
-- use groupName and password for the group you want to join
-- change q.hyperFolder to where you have it.

StartupFile.choose;
// -> and choose the personal copy of this file you just made
-- recompile...
-- DONE Part A - should startup with this startup file.
-- Now do setup of the hyperfolder, see below

////////
For Plain Vanilla SC
- 1 Go to Language Menu -> Open startup file
- 2 Copy the text in this entire file to the new startup file
- 3 Save the new startup file
// it will be where SuperCollider finds it:
Platform.userAppSupportDir +/+ "startup.scd";

- 4 Personalize it:
-- change q.myID to your preferred ID name!
-- use groupName and password for the group you want to join
-- change q.hyperFolder to where you have it ?

******/

"*** Welcome to Hyper/Dis/Connectivity!"
"*** loading startup file.".postln;

// connecting to OSCgroup automaticall loads
/// make a dictionary for everything useful
q = q ? ();

/// ENTER YOUR Preferred nametag/ID:
q.myID = '???';
/// and oscgroup password here
/// fine to leave this as "hyperdisco" for now
q.mypassword = 'hyperdisco';

/// change these for your group:
q.mygroup = '???';
q.mygroupPassword = '???';
// bruno gola's server - ask him first if very may users!
q.myoscserver = "bgo.la";

if (q.myID == '???') {
	"*** please enter your nametag in your startup file!"
	"\n... stopping here.".postln;
	this.halt;
};

"***  q.myID = %; // <- My valid nameID \n\n".postf(q.myID);


/////////// PART B -- Set up the hyperfolder: ////////////////
// 1. copy the workshop setup folder "hyperfolder"
//    to where you want it
// 2. tell SC where it is (drag and drop into this text file):

q.hyperfolder = "~/where/your/copy/is/hyperfolder/";

q.hyperfolder = "~/Desktop/hyperfolder/"s;

///// e.g. on my desktop: "~/Desktop/hyperfolder/";

if (q.myID == '???') {
	"*** please enter your nametag in your startup file!"
	"\n... stopping here.".postln;
	this.halt;
};
// posts my valid name
"***  q.myID = %; // <- My valid nameID \n\n".postf(q.myID);

if (File.exists(q.hyperfolder).not) {
	"cannot find q.hyperfolder at % - "
	"\n please move it there!".postf(q.hyperfolder);
	this.halt;
};


(q.hyperfolder +/+ "setup_files/00_loadMe.scd").loadPaths;
