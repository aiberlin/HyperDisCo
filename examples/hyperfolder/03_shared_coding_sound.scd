/*********** 03_shared_coding **************/

// - Go to the text document called SyncedEditor:
// - as one person types, the characters appear in everyone's SyncedEditor!
// - As preview of coding dojo,
// - we can take turns writing code together:
// - one little step at a time,
// - then pass to the next person


// performance prep:
// how to tell everyone something urgent while playing?
// evaluate a line that begins with "//!!":
//!! wello hurled !!\\
// -> it appears blinking on everyone's screen !


// shared coding of music:
// music very often consists of multiple layers,
// several instruments playing at the same time.
// by writing code that is always accessible again,
// we can have "shared state" - e.g. always using
// Tdefs, Ndefs, Pdefs, we can all see what is currently running,
// and write code that changes what is already there.

//////  if you start a sound like this:
// { Saw.ar([20, 30]) * 0.1 }.play;
/// nobody can access it with code,
/// and it can only be stopped with stop shortcut: Cmd-. period

/// So for sound processes, always put { }.play examples
/// in somthing like this:
Ndef(\saw, { Saw.ar([20, 30]) * 0.1 }).play;
Ndef(\saw).stop;
// modify it while running:
Ndef(\saw, { Saw.ar([50, 60]) * 0.1 }).play;

Ndef(\saw).stop;

////// All Ndefs show up on the NdefMixer:
/// NdefMixer(s);
//// or use the Butz widnow shortcut:
Butz.run('ndefmix');

// Tdef.all.do(_.stop);

///// all Task {  }.play should go into a Tdef, like:

// TdefAllGui.new;
//// or use Butz window shortcut:
Butz.run('Tdef.all');


Tdef(\tink);
// -> shows up on gui!

Tdef(\tink, {
	loop {
		(instrument: \glisson).play;
		1.wait;
	};
});

//////// better than loop { ... }:
//////// a fixed number of repeats, so the thing stops by itself:
Tdef(\tink, {
	42.do {
		(instrument: \glisson).play;
		1.wait;
	};
});


// -> on gui, src turns green
Tdef(\tink).play;
Tdef(\tink).stop;

// -> on gui, playbutton turns green

Tdef(\tink).set(\freq, 400);
// -> on gui, env button turns green

// click on env button:
// -> document 'edit me' shows envir settings
// alt-click on env button:
// -> TdefGui tink opens and shows settings

// use freq parameter inside the Tdefs environment:

Tdef(\tink).set(\freq, 4000);

Tdef(\tink, { |envir|
	42.do {
		(instrument: \glisson,
			freq: envir.freq ).play;
		1.wait;
	};
});

// set a range for random freq values:
Tdef(\tink).set(\minfreq, 400);
Tdef(\tink).set(\maxfreq, 4000);

Tdef(\tink, { |envir|
	32.do {
		var freq = exprand(envir.minfreq, envir.maxfreq);
		(instrument: \glisson, freq: freq ).play;
		1.wait;
	};
});

////// use the random range for freq (start freq) and freq2 (end freq):
Tdef(\tink, { |envir|
	42.do {
		var freq = exprand(envir.minfreq, envir.maxfreq);
		var freq2 = exprand(envir.minfreq, envir.maxfreq);
		(instrument: \glisson,
			freq: freq,
			freq2: freq2
		).play;
		1.wait;
	};
}).play;


Tdef(\tink).set(\sustain, 0.1);
Tdef(\tink).set(\maxfreq, 4000);

Tdef(\tink, { |envir|
	13.do {
		21.do {
			var freq = exprand(envir.minfreq, envir.maxfreq);
			var freq2 = exprand(envir.minfreq, envir.maxfreq);
			(instrument: \glisson,
				freq: freq,
				freq2: freq2,
				sustain: envir.sustain
			).play;
			// 1.wait;
			envir.sustain.wait;
		};
		1.wait;
	}
});

////// set ranges for parameters:
Tdef(\tink).addSpec(\sustain, [0.01, 1, \exp]);
Tdef(\tink).addSpec(\minfreq, \freq);
Tdef(\tink).addSpec(\maxfreq, \freq);

// get rid of unused \freq
Tdef(\tink).set(\freq, nil);

/// patterns go into Pdefs to be globally accessible!
Pdef(\test,
	Pbind(
		\note, Pbrown(0, 12, 2),
		\dur, 1/6
	)
).play;

// PdefAllGui.new;
//// or use Butz window shortcut:
Butz.run('Pdef.all');


/////////////////////// 