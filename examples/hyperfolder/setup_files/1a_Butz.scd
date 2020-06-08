//////// Buttons for useful functions like this:

Butz.clear;
Butz.numButz = 24;
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
