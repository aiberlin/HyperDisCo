//////// Buttons for useful functions like this:

Butz.clear;
Butz.numButz = 26;
Butz.style.font_(Butz.style.font.size_(14));
try { Butz.w.close };
Butz.makeWin;
Butz.w.layout.margins = [4, 4, 4, 4];
Butz.w.layout.spacing_(2);

///// make all button names here first, in the desired order.
///// put simple actions in directly;
///// put more complex actions in as MFdef(name) or WinBounds.showOrMake(name);
///// and fill those functions later.

// utility buttons for osc router visuals in system browser:
Butz.add('StartupFile', { StartupFile.choose });
Butz.add('hyperfolder', { q.hyperfolder.openOS });

Butz.add(\postPeers, {
	var peers = q.oscRouter.peers;
	"*** q.oscRouter has % peers: \n%\n".postf(peers.size, peers.sort)
});

Butz.add('loadSynthLib', { (q.hyperfolder +/+ "libs/_SynthLib.scd").load });
Butz.add('loadSampLib', { (q.hyperfolder +/+ "libs/_SampleLib.scd").load });
Butz.add('loadFXLib', { (q.hyperfolder +/+ "libs/_FXLib.scd").load });

Butz.add('CodingDojo', MFdef('CodingDojo'));

Butz.add( \History, { WinBounds.showOrMake(\History) });
Butz.add( \SyncText, MFdef(\SyncText) );

Butz.add('PRIVATE', MFdef('PRIVATE'));
Butz.add('PUBLIC', MFdef('PUBLIC'));

Butz.add('ndefmix', { WinBounds.showOrMake(\ndefmix) });
Butz.add('Tdef.all', { WinBounds.showOrMake('Tdef.all') });
Butz.add('Pdef.all', { WinBounds.showOrMake('Pdef.all') });

Butz.add(\DRAW, { WinBounds.showOrMake(\DRAW) });
Butz.add('MFdef_draw', { WinBounds.showOrMake('MFdef_draw') });

Butz.add('scope', { WinBounds.showOrMake(\scope) });

Butz.add(\meter, { WinBounds.showOrMake(\meter) });
Butz.add('recSetup', MFdef('recSetup'));
Butz.add('record', { s.record });
Butz.add('stopRec', { s.stopRecording });

Butz.add(\MasterFX, { WinBounds.showOrMake(\MasterFX) });
WinBounds.addMake(\MasterFX, { MasterFX(s).gui.parent.name_(\MasterFX) });

Butz.add(\load_JaMoP, MFdef(\load_JaMoP));


// make all the simple ones here:
WinBounds.addMake('Tdef.all', { TdefAllGui(24).parent });
WinBounds.addMake('Pdef.all', { PdefAllGui(24).parent });

WinBounds.addMake(\ndefmix, {
	q.mixer = NdefMixer(s, 24);
	q.mixer.parent.name_(\ndefmix);
	ProxyMeter.addMixer(q.mixer);
	q.mixer.parent;
});

MFdef('recSetup').add(\makeDoc, {
	Document("myRecSetup", [
		"/**** ",
		"for sharing recordings, convert to mp3 files (192 kbps),",
		"and upload them to HyperDisCo_shared!",
		"****/",
		"",
		"// my recording setup - recordings go here:",
		"Platform.recordingsDir = %;".format(Platform.recordingsDir.cs),
		"Platform.recordingsDir.openOS;",
		"",
		"// other record settings:",
		"s.recChannels_(%);".format(s.recChannels.cs),
		"/// one of: 'wav', 'aiff', (on macOS also:), 'caf'",
		"s.recHeaderFormat_(%);".format(s.recHeaderFormat.cs),
		"/// one of: 'int16', 'int24', , 'float'",
		"s.recSampleFormat_(%);".format(s.recSampleFormat.cs),
	].join("\n")
	);
	nil;
});

WinBounds.addMake(\scope, {
	var w = s.scope.window;
	w.name_(\scope);
});

WinBounds.addMake(\meter, {
	var w = s.meter.window;
	w.name_(\meter);
	w;
});

MFdef(\CodingDojo).add(\startDoc, {
	var text;
	var founddoc = Document.allDocuments. detect { |d| d.title == "Dojo_start" };
	if (founddoc.notNil) {
		founddoc.front
	} {
		text =
		"// Join the CodingDojo with:\n"
		"~dojo = CodingDojo(q.myID.postcs, 'udkDojo', q.myoscserver, userPassword: q.mypassword);\n\n"
		"// add ordered list of participants:\n"
		"~dojo.startSession();\n"
		"// switch to next triple:\n"
		"~dojo.rotate;\n"
		"\n// reopen timer window if needed: \n"
		"~dojo.showTimer;\n"
		"\n// leave dojo:\n"
		"~dojo.leave;\n"
		"\n// rejoin dojo:\n"
		"~dojo.leave;\n"
		"~dojo.join;\n";

		defer ({ Document("Dojo_start", text).front }, 0.1)
	}
});
