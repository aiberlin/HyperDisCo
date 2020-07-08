//// load all files for the hyperdisco setup.

q = q ? ();
q.hyperfolder = q.hyperfolder ?? { thisProcess.nowExecutingPath.dirname };

(q.hyperfolder +/+ "libs/_SynthLib.scd").loadPaths;
(q.hyperfolder +/+ "libs/_FXLib.scd").loadPaths;
(q.hyperfolder +/+ "setup_files/2_makeHistory.scd").loadPaths;

if (Platform.hasQt) {
	(q.hyperfolder +/+ "setup_files/1a_Butz.scd").loadPaths;
	(q.hyperfolder +/+ "setup_files/1b_winbounds.scd").loadPaths;
	(q.hyperfolder +/+ "setup_files/2b_makeHistoryGUI.scd").loadPaths;
};

// this may be too harsh - comment out if not needed!
Server.killAll;

Task {
	try { (q.hyperfolder +/+ "setup_files/1_logMeIn.scd").loadPaths } {
		"*** setup_files/1_logMeIn.scd failed!".postln;
	};
	1.wait;

	(q.hyperfolder +/+ "setup_files/3_runCode*.scd").loadPaths;

	// this could be problematic,
	if (Platform.hasQt) {
		// maybe we need a non-doc- SyncText version?
		(q.hyperfolder +/+ "setup_files/4_makeSyncedEditor.scd").loadPaths;
		// sent drawing code will just be ignored ...
		/// would be nice if it did get shown!
		(q.hyperfolder +/+ "setup_files/5_drawer.scd").loadPaths;
	};

	s.options.memSize = (2 ** 18).asInteger;
	s.waitForBoot {
		s.sync;
		(q.hyperfolder +/+ "setup_files/6_HyperMasterFX.scd").loadPaths;
	};

}.play(AppClock);
