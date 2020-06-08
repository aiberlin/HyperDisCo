// FX synthdefs
// channel-independent
// should all have a sustain arg !

/*
Ndef(\xf_tstSnd, { VarSaw.ar(LFNoise0.kr([8, 12]).exprange(200, 2000)) * LFDNoise3.kr(1, 0.1, 0.2) }).play;

// crackly cable
(instrument: \kabelScahden, freq: [50, 50], sustain: 10, amp: 0.5).play;

// fx starting here - always with <server?>   addAction: 1, group: 1 !
(instrument: \xf_strobe, sustain: 10, server: s, addAction: 1, group: 1).play;
(instrument: \xf_strobe, lofreq: 12, width: 0.8, sustain: 10, addAction: 1, group: 1).play;

// play it on all servers, with different values
~servReg.do { |sv|
(instrument: \xf_strobe, lofreq: exprand(5.0, 21.0), phase: 1.0.rand, sustain: 5,
addAction: 1, group: 1, server: sv).play;
};

// harsher strobe, clicky
(instrument: \xf_strobeAr, freq: 20, sustain: 10, addAction: 1, group: 1, server: s).play;

// temporary silence
(instrument: \xf_MUTE", sustain: 2, addAction: 1, group: 1, server: s).play;

// ( physical modeling ;-) slow down the "tape"
(instrument: \xf_dropTape, dt: rrand(5, 15), server: s, addAction: 1, group: 1).play;
(instrument: \xf_dropTape, dt: 0.5, server: s, addAction: 1, group: 1).play;


// wahwah pedal with distortion
(instrument: \xf_wah, addAction: 1, group: 1, dur: 6, server: s).play;

// hipass filter, removes lows
(instrument: \xf_hi, addAction: 1, freq: 4000, dur: 20, server: s).play;

// reverb with drift
(instrument: \xf_rev, dur: 30, revTime: 5, wet: 0.5, drift: 0.8, rate: 0.3,
addAction: 1, group: 1, server: s).play;

// bit crushing & downsampling
(instrument: \xf_krush, bits: 6, \xf_downsamp: 20, dur: 10, addAction: 1, group: 1, ).play;

// noisy analog line
(instrument: \xf_noizy, noizy: 0.6, dur: 10, addAction: 1, group: 1, server: s).play;

// irregular interference
(instrument: \xf_noizy2, rate: 5, dur: 10, addAction: 1, group: 1, server: s).play;

// tanh distortion
(instrument: \xf_tanh, gain: 5, dur: 10, addAction: 1, group: 1, server: s).play;

~servReg.do { |sv|
(instrument: \xf_tanh, addAction: 1, dur: 10, server: sv).play;
};

*/

(

q = q ? ();
q.numChans = q.numChans ? s.options.numOutputBusChannels;


// crackly cable simulator
SynthDef(\kabelScahden, { |out, freq=50, sustain=1, amp = 1|
	var  h, n, m, k, trig, hum;
	hum = {
		trig = Dust.kr( 7 ** LFNoise1.kr(0.3) );
		h = ToggleFF.kr(CoinGate.kr(0.4,trig)) *
		RLPF.ar(LFPulse.ar(freq, 0, 0.5, 1, LFNoise1.kr(2, 0.5, -0.5)), 6000, 0.15);
		n =  Trig.ar(trig, TRand.kr(0,0.01,CoinGate.kr(0.4,trig))) * WhiteNoise.ar;
		m =  Trig.ar(trig, TRand.kr(0,0.01,CoinGate.kr(0.4,trig))) * BrownNoise.ar;
		k = Trig.ar(trig, LFNoise1.kr([ 4, 4.2 ], 0.1, 0.11))
		*	LFClipNoise.ar(LFNoise0.kr(7, 30, 40));
		LeakDC.ar(h + n + k + m * 10).distort;
	} ! 2;
	Out.ar(out, hum * EnvGen.kr(Env([amp,amp,0] * 0.5,[sustain, 0]), doneAction: 2));
}).add;

// canonized FX //
SynthDef(\xf_comb2, { |out=0, sustain=2, dt=0.07, dcy=1, wobble=0.1,  wet=0.75|
	var in = In.ar(out, q.numChans);
	var ddtt = dt * [1, -2.midiratio]
	* (1-LFDNoise3.kr(wobble.sqrt ! q.numChans, wobble.clip(0,1)).abs);
	var mod = HPF.ar(CombL.ar(in, dt, ddtt, dcy, wet, in), 50);
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.5, 0.4], \sin), 1, 1,0, sustain, 2);
	XOut.ar(out, env, mod);
}).add;

SynthDef(\xf_comb, { |sustain=2, dt=0.07, dcy=1, out=0, wobble=0.1,  wet=0.75|
	var in = In.ar(out, q.numChans);
	var ddtt = dt * [1, -2.midiratio]
	* (1-LFDNoise3.kr(wobble.sqrt ! q.numChans, wobble.clip(0,1)).abs);
	var mod = HPF.ar(CombL.ar(in, dt, ddtt, dcy, wet), 50);
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.5, 0.4], \sin), 1, 1,0, sustain, 2);
	Out.ar(out, mod*env);
}).add;

SynthDef(\xf_gainLim, { |out=0, sustain=2,  gain=1|
	var in = In.ar(out, q.numChans);
	var mod = Limiter.ar(in.madd(gain));
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	XOut.ar(out, env, mod);
}).add;

SynthDef(\xf_onePole, { |out=0, sustain=2,  pole=0.95|
	var in = In.ar(out, q.numChans);
	var mod = OnePole.ar(in, pole);
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	XOut.ar(out, env, mod);
}).add;


SynthDef(\xf_MUTE, { |out=0, sustain = 0.3|
	var in = In.ar(out, q.numChans);
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	XOut.ar(out, env, Silent.ar(q.numChans));
}).add;

SynthDef(\xf_dropTape, { |dt=2, out=0|
	var in = In.ar(out, q.numChans);
	var del = DelayL.ar(in, dt,
		Line.kr(0,  dt.sqrt, dt, doneAction: 2).squared
	);
	ReplaceOut.ar(out, del);
}).add;
// e =  Env([0,1,0], [0.5, 0.5] * 1, [\sin, \sin]); e.plot;
// Time. is. relative.
SynthDef(\xf_dropTape2, { |dt=2, out=0, sustain=4|
	var in = In.ar(out, q.numChans);
	var curv = EnvGen.ar(Env([0,dt,0], [0.75, 0.25] * sustain, [\sqr, \sin]), 1, doneAction: 2);
	var del = DelayL.ar(in, dt, curv);
	ReplaceOut.ar(out, del);
}).add;

SynthDef(\xf_ringmod, { |sustain=2, freq= 300, mod=0.1,  out=0|
	var in = In.ar(out, q.numChans);
	var env = EnvGen.kr(Env([0,1,1,0], [0.2, 0.6, 0.2], \sin), 1, 1,0, sustain, 2);
	in = SinOsc.ar(freq  * [1, 0.91], 0, in);
	XOut.ar(out, env, in);
}).add;

SynthDef(\xf_distort, { |sustain=2, gain=3, out=0|
	var in = In.ar(out, q.numChans);
	var mod = in.madd(gain).clip2;
	var env = EnvGen.kr(Env([0,1,1,0], [0.2, 0.6, 0.2], \sin), 1, 1,0, sustain, 2);
	XOut.ar(out, env, mod);
}).add;

SynthDef(\xf_strobe, { |out=0, sustain=8, lofreq=4, width=0.5,  phase = 0|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var sig = In.ar(out, q.numChans) * LFPulse.kr(lofreq, 0, width);
	XOut.ar(out, env, sig);
}).add;
SynthDef(\xf_strobeAr, { |out=0, sustain=8, lofreq=4, width=0.5,  phase = 0|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var sig = In.ar(out, q.numChans) * LFPulse.ar(lofreq, 0, width);
	XOut.ar(out, env, sig);
}).add;

SynthDef(\xf_wah, { |out=0, rate = 2, depth = 0.5, ring=0.003, sustain=8, gain = 2|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var sig = (Ringz.ar(
		In.ar(out, q.numChans) * Line.kr(1, 1, sustain, doneAction: 2),
		VarSaw.kr(rate, 0, 0.1, depth).lag(0.1).exprange(200, 5000),
		ring
	) * gain).tanh.lag(0.0003) / gain.sqrt;
	XOut.ar(out, env, sig);
}).add;

SynthDef(\xf_noizy, { |out=0,  noizy = 0.5, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = In.ar(out, q.numChans);
	in = in * GrayNoise.ar(noizy, 1 - noizy);
	XOut.ar(out, env, in);
}).add;

SynthDef(\xf_noizy2, { |out=0,  rate = 0.5, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var noizy = LFNoise0.kr(rate).range(0, 1).squared;
	var in = In.ar(out, q.numChans);
	in = in * GrayNoise.ar(noizy, 1 - noizy);
	XOut.ar(out, env, in);
}).add;

SynthDef(\xf_rev, { |out=0, revTime = 3, drift = 0.5,  sustain = 10, rate = 0.5, wet = 0.15|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.6, 0.3], \sin), 1, 1,0, sustain);
	var envOut = EnvGen.kr(Env([0,1,1,0], [0.01, 0.69, 0.3], \sin), 1, 1,0, sustain + revTime, 2);
	var in = In.ar(out, q.numChans);
	var rev = AdCVerb.ar(LeakDC.ar(in) * wet * env,
		revTime,
		combScale: LFDNoise3.kr(rate, drift.clip2(0.9), 1)
	);
	Out.ar(out, rev * envOut);
}).add;

SynthDef(\xf_krush, { |out=0,  bits = 8, downsamp = 8, sustain = 10|
	var down;
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.6, 0.3], \sin), 1, 1,0, sustain);
	var in = In.ar(out, q.numChans);
	in = in.round(0.5 ** bits);
	down = Latch.ar(in, Impulse.ar(SampleRate.ir / downsamp.max(2)));
	XOut.ar(out, env, in);
}).add;

SynthDef(\xf_tanh, { |out=0,  gain = 10, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.6, 0.3], \sin), 1, 1,0, sustain);
	var in = In.ar(out, q.numChans);
	in = OnePole.ar((in * gain).tanh * 0.3, 0.5);
	XOut.ar(out, env, in);
}).add;

SynthDef(\xf_hi, { |out=0,  freq = 500, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.6, 0.3], \sin), 1, 1,0, sustain);
	var in = In.ar(out, q.numChans);
	in = HPF.ar(in * (freq / 500).sqrt, freq);
	XOut.ar(out, env, in);
}).add;

// ################
// from AVA:
(
SynthDef(\samp, {|out=0, buf=0, amp=0.3, rate=1|
	var snd = PlayBuf.ar(1, buf, rate, doneAction: 2);
	var env = EnvGen.kr(Env.linen(0.02, BufDur.ir(buf)/rate-0.04, 0.02));
	snd = HPF.ar(snd*amp, 106) * env;
	Out.ar(out, snd);
}).add;

SynthDef(\xf_rundfunk, {|out=0,  sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = InFeedback.ar(out, 1);
	var ring = { SinOsc.ar(LFNoise1.kr(ExpRand(0.02, 0.2)).exprange(2, 5000)).pow(0.75) }!3;
	var noise = PinkNoise.ar.sqrt;
	ring = [ring, noise, Rand(0.1, 0.3)].flat.product;
	// ReplaceOut.ar(out, in + ring);
	XOut.ar(out, env, in + ring);

}).add;

SynthDef(\xf_funkspruch, {|out=0, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = InFeedback.ar(out, 1);
	var ring = SinOsc.ar(ExpRand(2, 5000));
	ring = ring.max(0).madd(0.8, 0.2)
	+ ring.min(0).madd(1.2, 0.2);
	XOut.ar(out, env, ring.pow(0.7) * in * 2);

}).add;

SynthDef(\xf_bitcrush, {|out=0, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = InFeedback.ar(out, 1);
	var latx = Impulse.ar(ExpRand(1000, 10000));
	in = Latch.ar(in, latx);
	in = in.round((2 ** Rand(4, 16)).reciprocal);
	in = HPF.ar(in.softclip, 120);
	XOut.ar(out, env, in);
}).add;

SynthDef(\xf_dly, {|out=0, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = InFeedback.ar(out, 1);
	var dt = Rand(1/5, 1/2000);
	var dly = DelayN.ar(in, dt, LFNoise1.kr(0.1, 0.45, 0.55) * dt, Rand(0.4, 1.5)  );
	dly = OnePole.ar(dly, Rand(0.6, 0.98));
	XOut.ar(out, env, in + dly);

}).add;

SynthDef(\xf_flt, {|out=0, sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = InFeedback.ar(out, 1);
	in = in.asArray.collect({|chan|
		RLPF.ar(chan, {ExpRand(30, 13000)}.dup, {Rand(0.2, 1.8)}.dup ).madd([1, -1]).sum;
	});
	XOut.ar(out, env, in * 1.5);

}).add;

SynthDef(\xf_groupMaster, {|out=0,  sustain = 10|
	var env = EnvGen.kr(Env([0,1,1,0], [0.1, 0.8, 0.1], \sin), 1, 1,0, sustain, 2);
	var in = InFeedback.ar(out, 1);
	in = Limiter.ar(LeakDC.ar(in));
	XOut.ar(out, env, in);
}).add;


q.funkDefs = [\xf_funkspruch].flat;
q.funkDefs = [\xf_funkspruch, \xf_rundfunk, \xf_bitcrush, \xf_dly, \xf_dly, \xf_flt, \xf_wah].flat;
// e.o. AVA
// ################
);


/*
6.do{|i|(instrument: 'amacherFlimmern', server: ~servReg.values.wrapAt(i), sustain: 12, driftFreq: rrand(1400, 2000)).play;}

(instrument: \xf_wah, addAction: 1, sustain: 3, rate: exprand(0.3, 3), gain: 1.5).play;
(instrument: \xf_krush, addAction: 1, sustain: 3, bits: 5).play;
(instrument: \xf_rev, addAction: 1, sustain: 8).play;

(instrument: \xf_ringmod, addAction: 1, freq: exprand(15, 9000), sustain: 3).play;
(instrument: \xf_comb2, dt: 1/rrand(170, 1300), dcy: 0.75, addAction: 1, sustain: 3, wobble: 0.2).play;
(instrument: \xf_comb, dt: 1/rrand(170, 1300), dcy: 0.75, addAction: 1, sustain: 3, wobble: 0.2).play;
(instrument: \xf_gainLim, gain: 1.2, addAction: 1, sustain: 4).play;
(instrument: \xf_gainLim, gain: 0.8, addAction: 1, sustain: 4).play;
(instrument: \xf_distort, addAction: 1, gain: 0.8, sustain: 3).play;
(instrument: \xf_distort, addAction: 1, gain: 2, sustain: 3).play;
(instrument: \xf_MUTE, addAction: 1, sustain: 0.4).play;
(instrument: \xf_dropTape, addAction: 1, dt: 1.5, sustain: 3).play;
(instrument: \xf_dropTape2, addAction: 1, dt: 0.1, sustain: 1).play;
(instrument: \xf_strobe, addAction: 1, lofreq: exprand(1.5, 30), width: rrand(0.1, 0.5), sustain: 10).play;
(instrument: \xf_strobeAr, addAction: 1, lofreq: exprand(1.5, 30), width: 0.66, sustain: 3).play;
*/
);

q.fxDefs = (SynthDescLib.global.synthDescs.keys).asArray.select {|it| it.asString.beginsWith("xf_") }.sort;


">>> _FX Lib loaded".postln;