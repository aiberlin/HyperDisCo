/*** HyperDisCo Quark - EXAMPLE STARTUP FILE:

- RECOMMENDED: USE THE  StartupFile Quark!
- 0. install it:
Quarks.fetchDirectory;
Quarks.install("StartupFile");

// 1. copy this file to
StartupFile.openDir;
// 2. rename it to "hyperdisco.scd"; // or a name you like
// 3. open the copied file from there
// 4. Personalize the copied file as described below,
// 5. then Do
StartupFile.choose;
// 6. and select your newly made startup file "hyperdisco.scd";
// 7. Recompile -> setup should load now!

- To use without StartupFile:
// 1. Go to Language Menu -> Open startup file
// *** if that file has text in it:
******* SAVE A BACKUP COPY OF IT somewhere, by save or file rename!
// 2. Copy the text in this entire file to the new startup file
// 3. Save the new startup file
// it will be where SuperCollider finds it:
Platform.userAppSupportDir +/+ "startup.scd";
- 4 Recompile -> setup should load now!



- ///////////// Personalize the new startup file:
-- change q.myID to your preferred ID name!                 // VERY IMPORTANT !!
-- change q.hyperFolder to where you have your hyperfolder. // VERY IMPORTANT !!

/////// ok to leave at default when testing HyperDisCo:
-- change q.mypassword to your preferred personal password
-- change mygroup name to the group you want to connect to
-- change q.myoscserver to the TCPOSCServer you want to connect to //
-- change mygroupPassword to that group's agreed password

******/


"*** Welcome to CodeExp 2020 - Hyper/Dis/Connectivity!"
"*** loading startup file.".postln;

/// make a dictionary for keeping things around by name:
q = q ? ();

///////////////// PERSONALIZE HERE : ////////////////////
/// ENTER YOUR Preferred nametag/ID:
q.myID = '???';
/// a personal password for yourself - don't use an important one!
q.mypassword = 'hyperdisco';

// next, we tell the setup where the HyperDisco folder is,
/// e.g., on macOS, you may want to put it here:
q.hyperfolder = "~/Desktop/hyperfolder/".standardizePath;
////// NOTE: you can get the path to a file or folder in SC easily
/// by dropping it into a text document like this one;
/// it will turn into a String like "/Users/adc/Desktop/hyperfolder"


///////////// Maybe personalize these too //////////////
// this is the server adress which connects the group:
// "gencomp..." is the UdK Berlin server, which is fine to use for tests.
// use your own server if you have one!
q.myoscserver = "gencomp.medienhaus.udk-berlin.de";

/// change group name and password for your group:
// this is the default group for hyperdisco tests:
q.mygroup = 'hyperdisco';
q.mygroupPassword = 'hyperdisco';



///////////////// END of PERSONALIZATION !////////////////////

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

//////////////// DONT CHANGE ANYTHING BELOW HERE!!! //////////
if (q.myID == '???') {
	"*** please enter your nametag in your startup file!"
	"\n... stopping here.".postln;
	this.halt;
};

"***  q.myID = %; // <- My valid nameID \n\n".postf(q.myID);

if (File.exists(q.hyperfolder).not) {
	"cannot find q.hyperfolder at % - "
	"\n please move it there!".postf(q.hyperfolder);
	this.halt;
};
// found it:
"***  q.hyperfolder = %; ".postf(q.hyperfolder);

if ((Quarks.installed.any { |quark| quark.name == "HyperDisCo" })) {
	// just continue
	(q.hyperfolder +/+ "setup_files/00_loadMe.scd").loadPaths;
} {
	// if missing, add quark folder, and recompile by Hand:
	Quarks.fetchDirectory;
	Quarks.install("HyperDisCo");
	Quarks.install("StartupFile");
	LanguageConfig.store;
	"*** Please recompile now! with:".postln;
	"thisProcess.recompile;".postln;
};
