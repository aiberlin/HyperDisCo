// a large collection of synthdefs to use from PB_UP / Republic 111

// select all and evaluate!
// most SynthDefs have a line of test code to hear it

// TODO: tests of all params for every snthdef, in event style.


q = q ? ();

///////// alle synthdefs ab hier....  meist mit testzeile im kommentar


(
SynthDef(\outlet1, { |out, amp=0.1, sustain=5, freq=5000|
	var energy = EnvGen.kr(Env.perc(Rand(0.01, 0.02), sustain), doneAction:2);
	var son;
	son = Resonz.ar(WhiteNoise.ar(0.5.dup), energy.linlin(1, 0, freq, freq * 0.2), 0.4);
	Out.ar(out, son * energy)

}).add
);
/*
(instrument: \outlet1, server: ~s.choose).play;
(instrument: \outlet1, sustain: 3, freq: 2000, amp: 0.3).play;
*/
(
SynthDef(\press2, { |out, amp = 0.1, p0 = 1, p1 = 0, sustain = 10, freq = 4000, ratio = 2|
	var pressure, son, map, n = 4;
	pressure = EnvGen.ar(Env.new([p0, p1.max(0.0001)], [sustain], [\exp]), doneAction: 2);
	map = { |i|
		var a = rrand(0.0, 1.0);
		InRange.ar(pressure, a, a + 0.1) * SinOsc.ar(rand(9000, 12000), 0, 0.1)
	} ! n;
	son = Crackle.ar(pressure.linlin(1, 0, 1.32, 1.99) + [0, Rand(0, 0.001)]);
	freq = pressure.linlin(1, 0, freq * ratio, freq) * LFNoise1.kr(80,  1-pressure * 0.1, 1);
	son = Ringz.ar(son, freq, 0.01);
	son = son + map.sum;
	Out.ar(out, son * pressure * (amp * 5))
}).add;
);
/*
(instrument: \press2).play;
(instrument: \press2, sustain: 0.1, amp: 0.2).play;
(instrument: \press2, sustain: 3, freq: 2000, amp: 0.3).play;
(instrument: \press2, sustain: 3, freq: 2000, amp: 0.3, ratio: 4).play;
*/

(
SynthDef(\filling, {|out, amp = 0.1, p0 = 0, p1 = 1, sustain = 10,
	freq = 300, div = 0.7, decay = 0.3|
	var son, n = 6, freqs;
	var exc = WhiteNoise.ar(0.1.dup);
	var pressure = EnvGen.kr(Env.new([p0, p1, p1], [sustain * div, sustain * (1 - div)], [\lin]));
	amp = EnvGen.kr(
		Env.new([0.001, amp, amp, 0.001], [0.01, sustain, decay], [\exp]), doneAction: 2);
	freqs = {|i| (pressure * 0.2 + 1) ** i * freq } ! n;
	son = DynKlank.ar(`[freqs, 1/n, [2 - pressure]], exc);
	// son = son * ToggleFF.kr(Dust.kr(20), 0.3, 0.5);
	Out.ar(out, son * amp);

}).add
);

/*
(instrument: \filling).play;
(instrument: \filling, sustain: 0.1, amp: 0.2).play;
(instrument: \filling, sustain: 3, freq: 500, amp: 0.3).play;
(instrument: \filling, sustain: 3, freq: 1000, amp: 0.1, div: 0.5).play;
*/


(
SynthDef('dirac', { arg out=0, amp=1.0, pan=0;
	var trig;
	trig = Impulse.ar(1);
	FreeSelf.kr(trig);
	OffsetOut.ar(out, Pan2.ar(trig * amp, pan))
}, [\ir, \ir, \ir]).add;
);


(

//	main grain, classic gabor.

SynthDef('grain',
	{ arg out = 0, freq=800, sustain=0.01, amp=0.5, pan = 0;
		var window;
		window = Env.sine(sustain, amp);
		Out.ar(out,
			Pan2.ar(
				SinOsc.ar(freq),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
	}
).add;

/*****
s.sendMsg('/s_new', 'grain', -1, 0, 0, \freq, 2000, \sustain, 0.1, \out, 0, \amp, 0.5, \pan, 0);
******/

SynthDef('grainSine',
	{ arg out = 0, freq=800, sustain=0.01, amp=0.5, pan = 0;
		var window;
		window = Env.sine(sustain, amp);
		Out.ar(out,
			Pan2.ar(
				SinOsc.ar(freq),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;

/*****
s.sendMsg('/s_new', 'grainSine', -1, 0, 0, \freq, 2000, \sustain, 0.01, \out, 0, \pan, -1);
******/


SynthDef('grainLine',
	{ arg out = 0, freq=800, sustain=0.01, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ amp, 0 ], [ sustain ]);
		Out.ar(out,
			Pan2.ar(
				SinOsc.ar(freq),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;

/******
s.sendMsg('/s_new', 'grainLine', -1, 0, 0, \freq, 2000, \sustain, 0.1, \out, 0, \pan, 1);
******/


SynthDef('grainXLine',
	{ arg out = 0, freq=800, sustain=0.01, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ amp, 0.001 ], [ sustain ], 'exponential');
		Out.ar(out,
			Pan2.ar(
				(SinOsc.ar(freq) * EnvGen.ar(window, doneAction:2)).clip2(1),
				pan
			)
		)
}).add;

/*****
s.sendMsg('/s_new', 'grainXLine', -1, 0, 0, 	\freq, 2000, \sustain, 1, \out, 0);
*****/

SynthDef('grainXLRev',
	{ arg out = 0, freq=800, sustain=0.01, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ amp, 0.01, amp*0.5, 0.0001 ], [ sustain/4, sustain*3/8, sustain*3/8 ], 'exponential');
		Out.ar(out,
			Pan2.ar(
				SinOsc.ar(freq),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;

/*****
s.sendMsg('/s_new', 'grainXLRev', -1, 0, 0, 	\freq, 2000, \sustain, 1, \out, 0, \pan, 1);
*****/

SynthDef('glisson',
	{ arg out = 0, freq=800, freq2=1200, sustain=0.01, amp=0.5, pan = 0.0;
		var window, freqEnv;
		window = Env.sine(sustain, amp);
		freqEnv = Env([ freq, freq2 ], [ sustain ]);
		Out.ar(out,
			Pan2.ar(
				SinOsc.ar(EnvGen.ar(freqEnv)),
				pan
			)
			* EnvGen.ar(window, doneAction:2)
		)
}).add;

/*****
s.sendMsg('/s_new', 'glisson', -1, 0, 0, 	\freq2, rrand(2000, 12000), \sustain, 0.1, \out, 1, \pan, 0.5);
*****/

// grain, each Server randomizes freq
SynthDef('grain_interpret',
	{ arg out = 0, freq=800, sustain=0.01, amp=0.5;
		var window, pitch;
		window = Env.sine(sustain, amp);
		pitch = (Rand(4) + 1 * freq);

		Out.ar(out,
			SinOsc.ar(pitch)
			* EnvGen.ar(window, doneAction:2)
		)
}).add;

/*****
s.sendMsg('/s_new', 'grain_interpret', -1, 0, 0, 	\freq2, rrand(2000, 12000), \sustain, 0.1, \out, 1);
*****/

SynthDef('hatXLine',
	{ arg out = 0, freq=8000, sustain=0.01, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ amp, 0.001 ], [ sustain ], 'exponential');
		Out.ar(out,
			Pan2.ar(
				BPF.ar(ClipNoise.ar, freq, 0.1),
				pan,
				3
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;
/*****
s.sendMsg('/s_new', 'hatXLine', -1, 0, 0, \freq, rrand(2000, 12000), \sustain, 0.1, \out, 1);
*****/

SynthDef('hatXLRev',
	{ arg out = 0, freq=8000, sustain=0.01, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ 0.001, amp ], [ sustain ], 'exponential');
		Out.ar(out,
			Pan2.ar(
				BPF.ar(ClipNoise.ar, freq, 0.1),
				pan,
				3
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;
/*****
s.sendMsg('/s_new', 'hatXLRev', -1, 0, 0, \freq, rrand(2000, 12000), \sustain, 0.1, \out, 1);
*****/

/*/ a bunch of  feedback  DEFs/ */

SynthDef('feedScaleFreqs',{ arg amp=0.2, freq = 1000, freq2 = 5000, sustain= 2.0, out=0;
	var follower, pitch, env;
	var audioin = SoundIn.ar([0,1]);
	env = Env.sine;
	follower = Amplitude.kr(audioin.mean);

	Out.ar(out,
		audioin * Pulse.ar(freq2 - freq * follower + freq)
		* amp
		* EnvGen.ar(env, levelScale: 4, timeScale: sustain, doneAction: 2);
	)
}).add;
/*****
s.sendMsg('/s_new', 'feedScaleFreqs',  -1, 0, 0, \freq, 100, \freq2, 500, \sustain, 12);
*****/

SynthDef('feedDriftComb',{ arg freq = 3500, sustain= 2.0, amp = 3, out=0;
	var follower, env;
	var audioin = SoundIn.ar([0,1]);
	env = Env.sine;
	follower = Amplitude.kr(audioin.mean);
	Out.ar(out,
		CombN.ar(
			audioin,
			0.1,
			LFNoise1.kr(20).range(freq.reciprocal * 0.5, freq.reciprocal * 1.5)
			// 0.0001	// dlytime, dcytime
		)
		*  EnvGen.kr(env, levelScale: amp, timeScale: sustain, doneAction: 2);
	);
}).add;
/*****
s.sendMsg('/s_new', 'feedDriftComb',  -1, 0, 0, \freq, 50, \sustain, 10, \out, 1);
*****/

SynthDef('feedDriftComb2',{ arg freq = 3500, sustain= 2.0, amp = 1, driftFreq=2, decay=1, out=0;
	var follower, env;
	var audioin = SoundIn.ar([0,1]);
	env = Env.sine;
	follower = Amplitude.kr(audioin.mean);
	Out.ar(out,
		DelayN.ar(
			LeakDC.ar(
				CombL.ar(
					LPF.ar(audioin, freq * 0.5) ,
					0.1,
					LFNoise1.kr(driftFreq, follower * freq.reciprocal, freq.reciprocal),
					freq.reciprocal * decay
			), 0.2)
		)
		*  EnvGen.kr(env, levelScale: amp, timeScale: sustain, doneAction: 2);
	);
}).add;

/*****
s.sendMsg('/s_new', 'feedDriftComb2', -1, 0, 0, \freq, rrand(20, 50), \driftFreq, 1, \sustain, 12);
*****/

SynthDef('feedDriftComb3',{ arg freq = 3500, sustain= 2.0, amp = 3, out=0;
	var follower, env;
	var audioin = SoundIn.ar([0,1]);
	env = Env.sine;
	follower = Amplitude.kr(audioin.mean);
	Out.ar(out,
		CombN.ar(
			audioin,
			0.1,
			LFNoise1.kr(20).range(freq.reciprocal * 0.5, freq.reciprocal * 1.5) * follower,
			follower	// dlytime, dcytime
		)
		*  EnvGen.kr(env, levelScale: amp, timeScale: sustain, doneAction: 2);
	);
}).add;
/*****
s.sendMsg('/s_new', 'feedDriftComb3', -1, 0, 0, \freq, rrand(20, 50), \driftFreq, 1, \sustain, 12);
*****/

(
SynthDef('delta_demand2', { arg out=0, start=0.05, grow=0.93, num=20, freq=1000, dcy=0.01, amp=0.5;
	var channel;
	OffsetOut.ar(out,
		Ringz.ar(
			TDuty.ar(Dgeom(start, grow, num), 0, 0.5, 2),
			freq,
			dcy, amp
		)
	)
}).add;
);

(
SynthDef('klankinger', { arg out=0, i_freq=200, trig=1, att=0.2, dcy=2, ffreq=2000, ampl=0.4, sustain=1;
	var klank, n, harm, ring, env, amp;
	n = 9;
	harm = Control.names([\harm]).ir(Array.series(4,1,1));
	amp =  Control.names([\amp]).ir(Array.fill(4,0.05));
	ring = Control.names([\ring]).ir(Array.fill(4,1));
	klank = Klank.ar(`[harm,amp,ring], {ClipNoise.ar(0.003)}.dup, i_freq);
	klank = LPF.ar(klank, ffreq + SinOsc.kr([3,4],0, 300, 1000));
	env = EnvGen.kr( Env.new([0,1,1,0],[att, sustain, dcy]), trig, doneAction:2);
	Out.ar(out, klank * env * ampl);
}).add
);


(
// AMACHERl 3 //
SynthDef( 'amacherFlimmern', { |freq = 440, sustain = 1, amp = 0.1, gate=1, panWidth=10, out=0, seed=1974, id=0, pan=0 |

	var noise, sig, arr, hop, hash, freq2, pw;
	var env = EnvGen.kr(Env.new([0,1,1,0], [1,sustain,1]), doneAction:2 );

	arr = [1, 1.5, 5/4, 2, 3, 0.5, 4/3, 3/4, 4/5, 7/3, 3/7, 7/8, 8/7, 7/2, 2/7].scramble;
	hash = Hasher.kr(
		LFTri.kr(
			Rand(0.15, 0.5),
			Rand(0,3), 1,
			Rand(0,10)
		).round(0.1)
	).mod(1);
	hop = Index.kr(
		LocalBuf.newFrom(arr),
		(hash.madd( arr.size ) + MouseX.kr(0, 5).round) % (arr.size-1);
	);
	freq2 = freq * hop;
	pw = SinOsc.kr(1/8, Rand(0, 2pi)).range(Rand(0.1, 0.4),  Rand(0.15, 0.9));

	sig = Pulse.ar(freq2.clip(1, 20000), pw, amp/3);
	sig = LPF.ar(sig, (freq * 1.5).clip(20, 20000));
	sig = sig + PinkNoise.ar(hash<0.125*0.01 * SinOsc.ar(freq/128));
	Out.ar(out, Pan2.ar(env * sig, pan));
}).add
);

/*
(instrument: \amacherFlimmern, dur: 10, degree: 3.rand2 * 2+ 6, where: \all).play;
(instrument: \amacherFlimmern, dur: 10, degree: 5.rand2 * 2+ 8, where: \all, amp: 1).play;
(instrument: \amacherFlimmern, dur: 10, degree: {5.rand2}.dup(5) * 2+ 8, where: (0..4)+10.rand, amp: 1).play;
(instrument: \amacherFlimmern, dur: 10, degree: 3.rand2 * 2+ 6, where: 0, amp: 1).play;
*/


/*
Synth('rain');
*/




SynthDef('ur2', { |out, amp=0.2, pan, sustain=0.3,
	fundA=110, fundZ=160, f1a=600, f1z=900, f2a=2500, f2z=1500, rq=0.1|

	var formz = XLine.kr([f1a, f2a], [f1z, f2z], sustain);
	OffsetOut.ar(out,
		Pan2.ar(
			Formant.ar(
				XLine.kr(fundA, fundZ, sustain),
				formz,
				formz * rq,
				AmpComp.kr(formz, exp: 0.5)
			),
			pan
		) * EnvGen.ar(Env.linen(*(sustain * [0.05, 0.8, 0.15] ++ amp)), doneAction: 2)
	);
}).add;

SynthDef('ur3', { |out, amp=0.2, pan, sustain=0.3,
	fundA=110, fundZ=160, f1a=600, f1z=900, f2a=2500, f2z=1500, rq=0.1,
	fmod = 0.01, fmodrate = 8|

	var formz = XLine.kr([f1a, f2a], [f1z, f2z], sustain);
	OffsetOut.ar(out,
		Pan2.ar(
			Formant.ar(
				XLine.kr(fundA, fundZ, sustain) * LFDNoise3.kr(fmodrate, fmod, 1);
				formz,
				formz * rq,
				AmpComp.kr(formz, exp: 0.5)
			),
			pan
		) * EnvGen.ar(Env.linen(*(sustain * [0.05, 0.8, 0.15] ++ amp)), doneAction: 2)
	);
}).add;







//////////////// renate's ////////////////
(
SynthDef('music2', { arg out, sustain=3, freq=440, start=1, end=10, dur=3;
	var env;
	env = EnvGen.kr(Env.perc(0.03, sustain), 1, doneAction:2);
	Out.ar(out, Pan2.ar(Blip.ar(freq, Line.kr(1, 100, 3), 0.2)) * env) };
).add;
);
/*
Synth('music');
*/
SynthDef('music', { arg out, sustain=3, freq=440, start=1, end=10, dur=3;
	var env;
	env = EnvGen.kr(Env.perc(0.03, sustain), 1, doneAction:2);
	Out.ar(out, Pan2.ar(Blip.ar(freq, Line.kr(1, 100, 3), 0.2)) * env) };
).add;

(
SynthDef('rain',
	{|out=0, freq=440, sustain=0.1, amp=0.1, pan=0|
		var env, son;
		env = EnvGen.kr(Env.new([0, 0.1, 0.04, 0.6, 0],
			[1, 1, 2, 2]*sustain,
			'sine'), doneAction:2);
		son = SinOsc.ar(freq*Saw.ar(freq),0,env * (amp*20));
		Out.ar(out, Pan2.ar(LeakDC.ar(son) , pan)
		)
	}
).add
);
/*
Synth('rain');
*/

(
SynthDef('wirk', {|out, freq=440, pan, sustain=0.1, amp=0.1, shape=0.5|
	var v, env, attack;
	attack = sustain * (1 - shape);
	sustain = sustain * shape;
	amp = AmpCompA.kr(freq) * amp;
	env = EnvGen.kr(Env.perc(attack, sustain, 2, -4), doneAction:2);
	e = Line.kr(3, 2, sustain * 0.5);
	v = SinOsc.ar(freq * e, 0.5pi);
	Out.ar(out, Pan2.ar(v * amp * env, pan));
}).add
);
/*
Synth('wirk');wii
*/
(
SynthDef('flop',
	{ arg out = 0, freq=800, sustain=0.002, amp=0.5, pan = 0, ffreq = 1000;
		var window;
		window = Env.perc(0.001, sustain, amp);
		Out.ar(out,
			Pan2.ar(
				RLPF.ar( LFNoise0.ar(XLine.kr(freq, freq*10, sustain)), ffreq, 0.1),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
	}
).add
);
/*
Synth('flop');
*/
(
SynthDef('dessur',{|out, freq=440, amp=0.1, sustain=1, shape=0.5, thex=800|
	var u, env, filterfreq,  attack;
	attack = sustain * (1 - shape);
	sustain = sustain * shape;
	amp = AmpCompA.kr(freq) * amp;
	env = EnvGen.kr(Env.perc(attack, sustain, amp * 2),doneAction:2);
	filterfreq = Decay.ar(Impulse.ar(thex), 0.01) * 80 + 500;
	u = RLPF.ar(Saw.ar(freq), filterfreq, 0.2);
	Out.ar(out, u * env)
}).add
);
/*
Synth('dessur');
*/
(
SynthDef('dessous',{|out, freq=440, amp=0.1, sustain=1, pan|
	var u, env, filterfreq;
	env = EnvGen.kr(Env.sine(sustain,amp),doneAction:2);
	filterfreq = Decay.ar(Impulse.ar(800), 0.01) * 80 + 500;
	u = RLPF.ar(Saw.ar(freq), filterfreq, 0.2);
	Out.ar(out, Pan2.ar(u * env, pan))
}).add
);
/*
Synth('dessous');
*/
(
SynthDef('basedrum', { arg out, freq=88, sustain=0.3, amp=0.1, pan;
	var env, e;
	env = Env.perc(0.02, sustain, amp);
	freq = freq * (XLine.ar(5, 1, 0.02));
	Out.ar(out,
		Pan2.ar(
			SinOsc.ar(freq, SinOsc.ar(freq, 0, 0.5, pi/2), EnvGen.kr(env, doneAction:2),
				pan))
	)
}).add
);
/*
Synth('basedrum');
*/
(
SynthDef('pfeifchen', { |out, freq=440, sustain=0.2, amp=0.1, pan|
	var u;
	u = Formlet.ar(
		Impulse.ar(Line.kr(freq*3, freq, sustain)),
		Line.kr(1200, freq*2, sustain * Rand(0.01, 0.1)) * SinOsc.kr(Rand(4,9), 0, 0.03, 1),
		0.1
	)  * EnvGen.kr(Env.perc(0.03, sustain, amp * AmpCompA.kr(freq)), doneAction:2);
	Out.ar(out, Pan2.ar(u, pan));
}).add
);
/*
Synth('pfeifchen', [\amp, 1]);
*/
//////// end renate ////////


(
SynthDef('basedrum_holz', { arg out, freq=88, sustain=0.3, pan, amp=0.1;
	var env, e;
	env = Env.perc(0.02, sustain, amp);
	freq = freq * (XLine.ar(5, 1, 0.02));
	Out.ar(out,
		Pan2.ar(
			SinOsc.ar(freq, SinOsc.ar(freq, 0, 0.5, pi/2), EnvGen.kr(env, doneAction:2)),
			pan
		)
	)
}).add;
);


(
SynthDef(\fifty, {|out, detune=1, sustain=3, pan|
	Out.ar(out,
		Pan2.ar(
			EnvGen.kr(Env.linen(1, sustain, 0.01), doneAction:2) *
			LPF.ar(Pulse.ar(50 + detune), 2200),
			pan
		)
	)
}).add;
);

////  FX /////// replacedfwith _FXLib.scd!
//(
// q.nonFXNames = SynthDescLib.global.synthDescs.keys;
// q=q?();
// q.numChans = q.numChans ? 2;
//
// // canonized FX //
// SynthDef(\comb2, { |sustain=2, dt=0.07, dcy=1, inbus=0, wobble=0.1, gate=1, wet=0.75|
// 	var in = In.ar(inbus, q.numChans);
// 	var ddtt = dt * [1, -2.midiratio]
// 	* (1-LFDNoise3.kr(wobble.sqrt ! q.numChans, wobble.clip(0,1)).abs);
// 	var mod = HPF.ar(CombL.ar(in, dt, ddtt, dcy, wet, in), 50);
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.5, 0.4], \sin), gate, 1,0, sustain, 2);
// 	XOut.ar(inbus, env, mod);
// }).add;
//
// SynthDef(\comb, { |sustain=2, dt=0.07, dcy=1, inbus=0, wobble=0.1, gate=1, wet=0.75|
// 	var in = In.ar(inbus, q.numChans);
// 	var ddtt = dt * [1, -2.midiratio]
// 	* (1-LFDNoise3.kr(wobble.sqrt ! q.numChans, wobble.clip(0,1)).abs);
// 	var mod = HPF.ar(CombL.ar(in, dt, ddtt, dcy, wet), 50);
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.5, 0.4], \sin), gate, 1,0, sustain, 2);
// 	Out.ar(inbus, mod*env);
// }).add;
//
// SynthDef(\gainLim, { |inbus=0, sustain=2, gate=1, gain=1.5|
// 	var in = In.ar(inbus, q.numChans);
// 	var mod = in.madd(gain).softclip;
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), gate, 1,0, sustain, 2);
// 	XOut.ar(inbus, env, mod);
// }).add.addTag(\fx);
//
//
// SynthDef('MUTE', { |inbus=0, sustain = 0.3, gate=1|
// 	var in = In.ar(inbus, q.numChans);
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), gate, 1,0, sustain, 2);
// 	XOut.ar(inbus, env, Silent.ar(q.numChans));
// }).add;
//
// SynthDef(\xf_dropTape, { |dt=2, inbus=0|
// 	var in = In.ar(inbus, q.numChans);
// 	var del = DelayL.ar(in, dt,
// 		Line.kr(0,  dt.sqrt, dt, doneAction: 2).squared
// 	);
// 	ReplaceOut.ar(inbus, del);
// }).add;
// // e =  Env([0,1,0], [0.5, 0.5] * 1, [\sin, \sin]); e.plot;
// // Time. is. relative.
// SynthDef(\xf_dropTape2, { |dt=2, inbus=0, sustain=4, gate=1|
// 	var in = In.ar(inbus, q.numChans);
// 	var curv = EnvGen.ar(Env([0,dt,0], [0.75, 0.25] * sustain, [\sqr, \sin]), gate, doneAction: 2);
// 	var del = DelayL.ar(in, dt, curv);
// 	ReplaceOut.ar(inbus, del);
// }).add;
//
// SynthDef(\ringmod, { |sustain=2, freq= 300, mod=0.1, gate=1, inbus=0|
// 	var in = In.ar(inbus, q.numChans);
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.2, 0.6, 0.2], \sin), gate, 1,0, sustain, 2);
// 	in = SinOsc.ar(freq  * [1, 0.91], 0, in);
// 	XOut.ar(inbus, env, in);
// }).add;
//
// SynthDef(\distort, { |sustain=2, gain=3, inbus=0, gate=1|
// 	var in = In.ar(inbus, q.numChans);
// 	var mod = in.madd(gain).clip2;
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.2, 0.6, 0.2], \sin), gate, 1,0, sustain, 2);
// 	XOut.ar(inbus, env, mod);
// }).add;
//
// SynthDef('strobe', { |inbus=0, sustain=8, lofreq=4, width=0.5, gate=1, phase = 0|
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), gate, 1,0, sustain, 2);
// 	var out = In.ar(inbus, q.numChans) * LFPulse.kr(lofreq, 0, width);
// 	XOut.ar(inbus, env, out);
// }).add;
// SynthDef('strobeAr', { |inbus=0, sustain=8, lofreq=4, width=0.5, gate=1, phase = 0|
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), gate, 1,0, sustain, 2);
// 	var out = In.ar(inbus, q.numChans) * LFPulse.ar(lofreq, 0, width);
// 	XOut.ar(inbus, env, out);
// }).add;
//
// SynthDef(\wah, { |rate = 2, depth = 0.5, ring=0.003, sustain=8, gain = 2|
// 	ReplaceOut.ar(0,
// 		(Ringz.ar(
// 			In.ar(0, q.numChans) * Line.kr(1, 1, sustain, doneAction: 2),
// 			VarSaw.kr(rate, 0, 0.1, depth).lag(0.1).exprange(200, 5000),
// 			ring
// 		) * gain).tanh.lag(0.0003) / gain.sqrt
// 	);
// }).add;
//
// SynthDef(\rev, { |revTime = 3, drift = 0.5, gate=1, sustain = 10, rate = 0.5, wet = 0.15|
// 	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.6, 0.3], \sin), gate, 1,0, sustain);
// 	var envOut = EnvGen.kr(Env([0,1,1,0], [0.01, 0.69, 0.3], \sin), gate, 1,0, sustain + revTime, 2);
// 	var in = In.ar(0, q.numChans);
// 	var rev = AdCVerb.ar(LeakDC.ar(in) * wet * env,
// 		revTime,
// 		combScale: LFDNoise3.kr(rate, drift.clip2(0.9), 1)
// 	);
// 	Out.ar(0, rev * envOut);
// }).add;
//
// SynthDef(\krush, { |bits = 8, downsamp = 8, sustain = 10|
// 	var down;
// 	var env = Line.kr(1, 1, sustain, doneAction: 2);
// 	var in = In.ar(0, q.numChans);
// 	in = in.round(0.5 ** bits);
// 	down = Latch.ar(in, Impulse.ar(SampleRate.ir / downsamp.max(2)));
//
// 	ReplaceOut.ar(0, down);
// }).add;
//
// // only works the first time ... sorry
// q.fxNames = q.fxNames ?? { SynthDescLib.global.synthDescs.keys.removeAll(q.nonFXNames) };
//
// /*
// (instrument: 'wah', addAction: 1, sustain: 3, rate: exprand(0.3, 3), gain: 1.5).play;
// (instrument: 'krush', addAction: 1, sustain: 3, bits: 5).play;
// (instrument: 'rev', addAction: 1, sustain: 8).play;
//
// (instrument: 'ringmod', addAction: 1, freq: exprand(15, 9000), sustain: 3).play;
// (instrument: 'comb2', dt: 1/rrand(170, 1300), dcy: 0.75, addAction: 1, sustain: 3, wobble: 0.2).play;
// (instrument: 'comb', dt: 1/rrand(170, 1300), dcy: 0.75, addAction: 1, sustain: 3, wobble: 0.2).play;
// (instrument: \gainLim, gain: 1.2, addAction: 1, sustain: 4).play;
// (instrument: \gainLim, gain: 0.8, addAction: 1, sustain: 4).play;
// (instrument: 'distort', addAction: 1, gain: 0.8, sustain: 3).play;
// (instrument: 'distort', addAction: 1, gain: 2, sustain: 3).play;
// (instrument: \MUTE, addAction: 1, sustain: 0.4).play;
// (instrument: 'xf_dropTape', addAction: 1, dt: 1.5, sustain: 3).play;
// (instrument: 'xf_dropTape2', addAction: 1, dt: 0.1, sustain: 1).play;
// (instrument: 'strobe', addAction: 1, lofreq: exprand(1.5, 30), width: rrand(0.1, 0.5), sustain: 10).play;
// (instrument: 'strobeAr', addAction: 1, lofreq: exprand(1.5, 30), width: 0.66, sustain: 3).play;
// */
// );

"\n\n post an alle geschickt...\n\n".post;
);