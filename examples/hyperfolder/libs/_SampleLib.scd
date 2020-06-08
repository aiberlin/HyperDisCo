/**** Tests for Samples:

// use like this - array:
////////// q.samba = q.loadSamples("BRAZILPERC");


q.samba.choose.postln.play;
(instrument: \simpsamp, buf: q.samba[12]).play;
(instrument: \simpsamp, buf: q.samba[12], amp: 1).play;
(instrument: \simpsamp, buf: q.samba[15], amp: 1).play;

(instrument: \simpsamp, buf: q.samba[15], amp: 1, rate: 1).play;
(instrument: \simpsamp, buf: q.samba[15], amp: 1, rate: 0.75).play;
(instrument: \simpsamp, buf: q.samba[15], amp: 1, rate: 0.5).play;
(instrument: \simpsamp, buf: q.samba[15], amp: 1, rate: 1.5).play;
(instrument: \simpsamp, buf: q.samba[15], amp: 1, rate: 0.15).play;

(instrument: \simpsamp, buf: q.samba.choose, amp: 1, rate: 0.5).play;

// test sampled sound on all servers:
~servReg.values.do { |srv|
(instrument: \simpsamp, buf: q.samba[15], amp: 10, rate: 1.5, server: srv).play;
};

s.scope;


// // as dict with full key names:
// q.sambaDict = q.sampDict(q.samba);
// q.sambaDict.keys.cs
// q.sambaDict['agogo_2'].play;
//
// // as family dict:
// q.sambaFamily = q.sampDictFamily(q.samba);
// q.sambaFamily.keys;
// q.sambaFamily[\cuica].keys;
// q.sambaFamily[\cuica].choose.play;
// fork { q.sambaFamily[\cuica].do { |buf| buf.play; 0.25.wait } };
//
// Tdef(\cuica, {
// q.sambaFamily[\cuica].do { |buf|
// buf.play; 0.25.wait
// }
// }).play;

// play all sounds once

// play all sounds once
Tdef(\sambAll, {
q.samba.do { |buf, i|
(instrument: \simpsamp, buf: buf, amp: 1).play;
0.25.wait;
}
}).play;

Tdef(\sambAll, {
inf.do {
q.samba.scramble.do { |buf, i|
var rate = [1, 1.25, 1.5, 0.75, 0.5].choose;
(instrument: \simpsamp, buf: buf, rate: rate, amp: 1).play;
(buf.duration / rate).wait;
} }
}).play;


// play every sound once, with overlap
Tdef(\sambAll).set(\overlap, 4);

Tdef(\sambAll, { |e|
inf.do {
q.samba.scramble.do { |buf, i|
var rate = [1, 1.25, 1.5, 0.75, 0.5].choose;
(instrument: \simpsamp, buf: buf, rate: rate, amp: 1).play;
(buf.duration / rate / e.overlap).wait;
} }
}).play;

// random order with steady rhythm
Tdef(\sambAll).set(\overlap, 4);

Tdef(\sambAll, { |e|
inf.do {
q.samba.scramble.do { |buf, i|
var rate = [1, 1.25, 1.5, 0.75, 0.5].choose;
(instrument: \simpsamp, buf: buf, rate: rate).play;
[0.5, 0.25, 0.25, 0.25, 0.25, 0.25, ].choose.wait;
} }
}).play;


// subset of all samples
Tdef(\sambAll).set(\snds, q.samba.keep(3));

Tdef(\sambAll).set(\snds, q.samba.scramble.keep(1));

Tdef(\sambAll, { |e|
inf.do {
e.snds.do { |buf, i|
var rate = [1, 1.25, 1.5, 0.75, 0.5].choose;
(instrument: \simpsamp, buf: buf, rate: rate).play;
[0.5, 0.25, 0.25, 0.25, 0.25, 0.25, ].choose.wait;
} }
}).play;

Tdef(\sambAll).set(\snds, q.samba.scramble.keep(1));
Tdef(\sambAll).set(\snds, q.samba.scramble.keep(3));
Tdef(\sambAll).set(\snds, q.samba.scramble.keep(8));

// just the first sound
Tdef(\sambAll).set(\snds, q.samba [ [0] ]);
// specific 3 sounds
Tdef(\sambAll).set(\snds, q.samba [ [0, 3, 7] ]);


// polyphonic:

q.samba[15].play;
q.samba[12].play;


// event polyphony:
(instrument: \simpsamp, buf: [ q.samba[12], q.samba[15]], amp: 0.1, rate: [2, 0.75]).play;

// written out:
(instrument: \simpsamp, buf: q.samba[12], amp: 0.1, rate: 2).play;
(instrument: \simpsamp, buf: q.samba[15], amp: 0.1, rate: 0.75).play;


Tdef(\samb2).set(\snds, q.samba.scramble.keep(3)); // 1 will cause crash !!

Tdef(\samb2, { |e|
inf.do {
e.snds.do { |buf, i|
var rate = [1, 1.25, 1.5, 0.75, 0.5].choose;
(instrument: \simpsamp, buf: buf, rate: rate).play;
if (i.odd) {
[0.5, 0.25, 0.25, 0.25, 0.25, 0.25, ].choose.wait;
};
} }
}).play;


****/
q=q?();


// Sample Players SynthDefs

//  -----------------------------------------------------------
//  -----------------------------------------------------------
//  -----------------------------------------------------------
// MONO SynthDefs //-------------------------------------

// synthdef to play a buffer. start: in seconds.
SynthDef(\simpsamp, { |out, buf, amp=0.1, rate = 1, pan=0, start|
	var snd = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction:2
	);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;
(
SynthDef(\sampGrain, { |out, buf, amp=0.1, rate = 1, stretch=1, pan=0, ovlp = 6, trigrate=33, jitter=0.01|
	var bdur = BufDur.ir(buf);
	var trig = Dust.ar(trigrate);
	var pos  = Line.ar(0, bdur, bdur * stretch, doneAction: 2) + TRand.ar(jitter.neg, jitter, trig).madd(bdur);
	var snd  = TGrains.ar(2, trig, buf, rate, pos, trigrate.reciprocal*ovlp, pan, amp );
	OffsetOut.ar(out, snd);
}).add;
);
/*
(instrument: \sampGrain, buf: 134, amp: 1, rate: 1/1.2, stretch: 1.0, ovlp: 8).play; // grainy stretchhhhhh
*/
SynthDef(\simpsampGlitch, { |out, buf, amp=0.1, rate = 1, pan=0, start|
	var snd, blendMess = Line.kr(-2,2, BufDur.ir(buf)).clip(0, 1);

	rate = rate * blend(1, LFNoise1.kr(Rand(2, 30), 5, 1).clip2(1), blendMess);
	snd = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction:2
	);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// synthdef to play a section from a buffer. start/end in seconds
SynthDef(\sampEnv, { |out, buf, amp=0.1, rate = 1, pan, start, sustain=0.8, fade=0.01|
	var fadeTime = min(fade, BufDur.ir(buf)/3);
	var snd = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2
	);
	var env = EnvGen.ar(Env.linen(fadeTime, sustain, fadeTime), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan, amp))
}).add;

// Stereo SynthDefs //--------------------------------------
SynthDef(\simpsamp_st, { |out, buf, amp=0.1, rate = 1, start|
	var snd = PlayBuf.ar(2,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction:2
	);
	OffsetOut.ar(out, snd * amp);
}).add;

SynthDef(\sampEnv_st, { |out, buf, amp=0.1, rate = 1, start, sustain=0.8, fade=0.01|
	var fadeTime = min(fade, BufDur.ir(buf)/3);
	var snd = PlayBuf.ar(2,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2
	);
	var env = EnvGen.ar(Env.linen(fadeTime, sustain, fadeTime), doneAction: 2);
	OffsetOut.ar(out, snd * env * amp)
}).add;

q.bufDefs = [\simpsamp, \sampGrain, \simpsampGlitch, \sampEnv];

/// e.o. SynthDefs -----------------------------------------------------------
//  -----------------------------------------------------------
//  -----------------------------------------------------------
//  -----------------------------------------------------------

// sound file load mechanism
// have all the samples stored in this Dir !!
q.mainSampDir = (thisProcess.nowExecutingPath.dirname +/+ "Samples").pathMatch.first.postcln;


// single function to load folders of sounds into Buffer Arrays;

/////======== 2020 better Test:

q.loadSamples = { |q, dir, mainDir|

	var myDir = if(dir.contains("/") and: {mainDir.isNil} ){dir} { (mainDir ? q.mainSampDir) +/+ dir};
	var myPaths = (myDir +/+ "*").postcln.pathMatch;
	var mySFs = myPaths.collect{|p|
		var sf = SoundFile.openRead(p); // test if SoundFile Class can handle it - regardless of file name ext !
		if(sf.notNil){
			// load'em!
			var pa = sf.path;
			sf.close;
			pa
		};
	}.select( _.notNil );

	var returnArray = [];
	postf("\n\n>>>>> about to load the following % files: \n\n", mySFs.size);
	mySFs.collect{|f|f.basename}.printAll;

	if(s.serverRunning){
		if(mySFs.notEmpty){
			returnArray = mySFs.collect{|p|
				Buffer.readChannel(s, p, channels: [0], action: {|buf|
					buf.normalize;
					//.add(buf)
				});
			};
		}{
			"sorry, no sound files in folder \"%\"!".format(myDir).warn;
		};

	}{ "\n\noy, Server not running! please run s.boot; first!\n".warn;  };
	// "\n\n".postln;
	returnArray
};

/////========

q.sampDict = { |q, sampArray|
	var dict = ();
	sampArray.do { |buf|
	//	var key = buf.path.basename.splitext[0].toLower.asSymbol.postcs;
		var key = PathName(buf.path).fileNameWithoutExtension.toLower.asSymbol.postcs;
		dict.put(key, buf);
	};
	dict;
};

q.sampDictFamily = { |q, buffers|
	var topdict = ();
	buffers.do { |buf|
		var fullkey = buf.path.basename.splitext[0].toLower;
		var keylist = fullkey.split($_);
		var famkey = keylist[0].asSymbol;
		var lowkey = keylist[1].asSymbol;
		var famdict = topdict[famkey] ?? { () };
		famdict.put(lowkey, buf);
		topdict.put(famkey, famdict);
	};
	topdict;
};

// load default sample set:
// q.samba = q.loadSamples("BRAZILPERC");