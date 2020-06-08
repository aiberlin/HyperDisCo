q = q ? ();

(q.hyperfolder +/+ "setup_files/1a_Butz.scd").loadPaths;
(q.hyperfolder +/+ "libs/_SynthLib.scd").loadPaths;
(q.hyperfolder +/+ "setup_files/1b_winbounds.scd").loadPaths;
(q.hyperfolder +/+ "setup_files/2_makeHistory.scd").loadPaths;

Server.killAll;

Task {
	(q.hyperfolder +/+ "setup_files/1_logMeIn.scd").loadPaths;
	1.wait;

	s.options.memSize = (2 ** 18).asInteger;
	s.boot;
	(q.hyperfolder +/+ "setup_files/3_runCode*.scd").loadPaths;
	(q.hyperfolder +/+ "setup_files/4_makeSyncedEditor.scd").loadPaths;
	(q.hyperfolder +/+ "setup_files/5_drawer.scd").loadPaths;


}.play(AppClock);
