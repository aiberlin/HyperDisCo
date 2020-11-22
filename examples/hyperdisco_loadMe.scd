/*** HyperDisCo Quark - EXAMPLE LOADME FILE:

- ///////////// Personalize this file as follows:
-- change q.myID to your preferred ID name!                 // VERY IMPORTANT !!
-- change q.hyperFolder to where you have your hyperfolder. // VERY IMPORTANT !!

/////// ok to leave at default when testing HyperDisCo:
-- change q.mypassword to your preferred personal password
-- change mygroup name to the group you want to connect to
-- change q.myoscserver to the TCPOSCServer you want to connect to //
-- change mygroupPassword to that group's agreed password

******/

"*** Welcome to CodeExp 2020 - Hyper/Dis/Connectivity!"
"*** loadme file.".postln;

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
/////// check that username was given:
if (q.myID == '???') {
	"*** please enter your nametag in your startup file!"
	"\n... stopping here.".postln;
	this.halt;
};

"***  q.myID = %; // <- My valid nameID \n\n".postf(q.myID);

/////// check that q.hyperfolder is where it should be:
if (File.exists(q.hyperfolder).not) {
	"cannot find q.hyperfolder at % - "
	"\n please move it there!".postf(q.hyperfolder);
	this.halt;
};
// found it:
"***  q.hyperfolder = %; ".postf(q.hyperfolder);

/// check that HyperDisCo quark is installed
if ((Quarks.installed.any { |quark| quark.name == "HyperDisCo" })) {
	// just continue
	(q.hyperfolder +/+ "setup_files/00_loadMe.scd").loadPaths;
} {
	// if missing, add quark folder, and recompile by Hand:
	Quarks.fetchDirectory;
	Quarks.install("HyperDisCo");
	LanguageConfig.store;
	"*** Please recompile now! with:".postln;
	"thisProcess.recompile;".postln;
};
