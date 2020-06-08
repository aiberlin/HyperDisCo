// Sound Library - synthetic sounds
/*
a percussion SynthDef Library by The Society For Nontrivial Pursuits
with generous contributions by Jan Kees van Kampen

to be expanded ...

unified parameter interface:
- out
- amp
- pan
- dur
- attack
- decay
- ..?..
- freq for tonal sounds

*/
q = q ? ();
q.origSynthDefs = q.origSynthDefs ?? { SynthDescLib.global.synthDescs.keys };

// load other synthdef libs explicitly in startup, e.g.
// "allesAnAlle.scd", "_FXLib.scd";
// (~libsPath +/+ "allesAnAlle.scd").loadPaths;
("allesAnAlle.scd").loadRelative; // load here, so all SDs count into q.synthDefs


// 	AnalogDrums215 by_otophilia
//	http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=125
(
SynthDef("ana_kick", { arg out=0, pan=0, amp=0.1;
	var env, env2, env3, pch, osc, noise, outS;
	env = EnvGen.kr(Env.perc(0, 0.20, 1, -4), doneAction:2);
	env2 = EnvGen.kr(Env.new([60,3,0],[0.08,0.16],[-18,-5]));
	env3 = EnvGen.kr(Env.new([0.8,0],[0.10],[-10]));
	pch = (32+env2).midicps;

	osc = SinOsc.ar(pch, 0, env);
	noise = BPF.ar(WhiteNoise.ar(env3), 200, 2);
	outS = osc+noise;
	OffsetOut.ar(out, Pan2.ar(outS, pan, amp));
}).add;

SynthDef("ana_snare", { arg out, pan=0, amp=0.1;
	var env, env2, env3, pch, osc, noise, outS;
	env = EnvGen.kr(Env.perc(0, 0.05, 1, -5));
	env2 = EnvGen.kr(Env.new([56,3,0],[0.08,0.1],[-20,-5]));
	env3 = EnvGen.kr(Env.new([0.5,0,0.5,0],[0.001,0.001,0.16],[0,-3,-8]), doneAction:2);
	pch = (49+env2).midicps;

	osc = SinOsc.ar(pch, 0, env);
	noise = BPF.ar(WhiteNoise.ar(env3), 9000, 2);
	outS = osc+noise;
	OffsetOut.ar(out, Pan2.ar(outS, pan, amp));
}).add;

SynthDef("ana_hat", { arg out=0, pan=0, decay=0.05, amp=0.1;
	var env, pch, osc, noise, outS;
	env = EnvGen.kr(Env.perc(0, decay, 1, -6), doneAction:2);
	pch = (SinOsc.ar(320, 0, 2000, 9000));
	osc = SinOsc.ar(pch, 0, 0.5);
	noise = WhiteNoise.ar;
	outS = osc + noise;
	outS = BPF.ar(outS, 12000, 0.3, env);
	OffsetOut.ar(out, Pan2.ar(outS, pan, amp));
}).add;

SynthDef("kick_electro1", {
	arg freq=60, amp=1, pan=0, out=0;
	var x, env1, env2, env3, mod, noise;
	env1 = Env.perc(0.001,0.15,1,-4);
	env2 = Env.perc(0.001,0.01,1,-4);
	env3 = Env.perc(0.0001,0.01,0.2,-10);
	mod = EnvGen.ar(env2, 1) * 100;
	noise = EnvGen.ar(env3, 1);
	x = SinOsc.ar(freq + mod);
	x = EnvGen.ar(env1, 1, doneAction: 2) * x - noise;
	OffsetOut.ar(out, Pan2.ar(x,pan, amp));
}).add;

);
/****** test:
(instrument: \ana_kick).play;
(instrument: \ana_snare).play;
(instrument: \ana_hat).play;
(instrument: \kick_electro1).play;
******/

SynthDef(\pandeiro1, { |out, amp = 0.1, pan, drumfreq = 100, drumres = 10, decay = 0.2, beldec = 0.02, belamp = 0.5|
	var snd = GrayNoise.ar();
	var filtFreq = amp.linlin(0.025, 0.1, 6000, 12000);
	var env = EnvGen.ar(Env.perc(0.01, decay, amp));
	var env2 = EnvGen.ar(Env.perc(0.05, decay + 0.1, amp), doneAction: 2);
	var filtered = RHPF.ar(snd, drumfreq, 0.3/drumres);
	var bellz = Klank.ar(`[
		[3567, 4200, 4765, 5100, 5689],
		belamp,
		beldec,
	], Dust2.ar(4000) * env2).tanh;
	OffsetOut.ar(out, Pan2.ar(
		filtered * env + (bellz),
		pan));
}).add;


(
SynthDef( "Mridangam", { arg out, freq = 85, t_amp =0.4;
	var sig = Resonz.ar(
		WhiteNoise.ar([100,100]) * Decay2.kr( t_amp, 0.002, 0.1 ),
		freq,
		0.02,
		4
	).distort;

	DetectSilence.ar( sig,  doneAction: 2 );
	OffsetOut.ar( out, sig  );
}).add;


SynthDef("bass",
	{ arg out=0, freq=40, fratio=2, rq=0.8, decay=0.05, attack=0.05, envDepth=2, amp=1;
		var sound, env;
		env = EnvGen.kr(Env.perc(0.01, decay), doneAction:2);
		sound = RLPF.ar(
			Saw.ar([freq, freq+5], amp*4),
			freq * fratio * EnvGen.kr(Env.perc(attack, decay, envDepth), levelBias:1),
			rq,
			env
		).distort;

		OffsetOut.ar(out, sound);
}).add;
);

/*****
(instrument: \pandeiro1).play;
(instrument: \Mridangam, amp: 0.2).play;
(instrument: \bass, decay: 1, midinote: 40 + 10.rand, envDepth: 0).play;
******/


/*
Chinese Gongs
modelled after AudioSculpt analysis

q.spruchDesTages = "es wurde ein schminktaeschchen gefunden. Die verliererin kann es im wagen 563 abholen"
*/
(
q.gongSpecs = [
	[ [1970, -28], [1245, -44], [1400, -53], [1634, -44], [3480, -58], [4456, -55], [7000, -75]],

	[ [1639, -35], [1387, -45], [3880, -54], [4467, -67], [7055,-73]],

	[ [1492, -21], [1250, -34], [2844, -48], [3388, -50], [3503, -53], [5456, -63], [6843, -70]],

	[ [1240, -26], [528, -33], [3330, -50], [3400, -50], [3480, -43], [5460, -65] ],

	[ [972, -22], [810, -30], [1200, -46], [2025, -40], [2242, -48], [2320, -40], [3150, -48], [3679, -56], [4600, -72] ],

	[ [810, -22], [200, -45], [2020, -45], [242, -42], [2320, -40], [2602, -47], [3023, -53], [3680, -53], [4820, -63] ]

];
q.gongNames = q.gongSpecs.collect({ |spec, i| (\gong_ ++ i).asSymbol });

q.gongSpecs.collect({ |spec, i|
	(
		SynthDef( (\gong_ ++ i).asSymbol, {	arg out=0, dboffs = 22, decay = 2, amp= 0.1, pan=0, soft = 1;
			var sig, burst, specs, env, gate;
			specs = spec.flop;

			env = Env.new([0, 1, 0], [1, 1.5], \sin);
			burst = EnvGen.ar(env, 1,  levelScale: soft.reciprocal, timeScale: 0.012 * soft) * GrayNoise.ar(3) * WhiteNoise.ar(amp);
			burst = OnePole.ar(burst, 0.99, 15);

			sig = specs[0].collect({ arg f, i;
				Ringz.ar(burst, f , decay, (specs[1][i] + dboffs).dbamp )
			}).mean;
			sig = OnePole.ar(sig, 0.97);

			DetectSilence.ar(sig, 0.000001, doneAction:2);
			OffsetOut.ar(out, Pan2.ar(sig, pan))
		}).add
	);

})
);
/******
(instrument: ( \gong_ ++ q.gongSpecs.size.rand ).asSymbol).play;
******/

// snr
SynthDef("up-snare-1", {
	arg   amp=1, pan=0, out=0, freq=120, decay=0.01;
	var x, e;
	e = Env.perc(0.01, decay, 1,-3);
	x = WhiteNoise.ar(amp);
	x = OnePole.ar(x, -0.2);
	x = HPF.ar(x, freq);
	x = EnvGen.kr(e, 1, doneAction: 2) * x;
	OffsetOut.ar(out, Pan2.ar(x, pan));
}).add;

// kick
SynthDef("up-kick-2", { arg out=0, amp=0.1, decay=0.2,  pan=0, freq=60;
	var env1, env2, env3, mod1, mod2, x;
	env1 = Env.new([0.001,1,0.7,0.6,0], [0.001,0.003,0.1,0.1], -3);
	env2 = Env.perc(0, 0.01, 1, -3);
	env3 = Env.perc(0, 0.001, Rand(1, 0.5), -3);
	mod1 = EnvGen.ar(env2) * 500;
	mod2 = EnvGen.ar(env3) * 10;
	x = SinOsc.ar(freq + mod1, 0, 1, mod2) * amp;
	x = EnvGen.kr(env1, 1.0, decay * Rand(1, 0.9), doneAction:2) * x;
	OffsetOut.ar(out, Pan2.ar(x.distort.clip2(amp), pan));
}).add;
/*****
(\instrument: "up-snare-1", decay: 0.1).play;
(\instrument: "up-kick-2").play;
*****/


//-----------------------------------------------------------
// SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// should be simplified!


// SOSkick -------
// http://www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
// increase mod_freq and mod_index for interesting electronic percussion
(
SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, decay = 0.4, amp = 0.8, beater_noise_level = 0.025, pan=0;

		var pitch_contour, drum_osc, drum_lpf, drum_env;
		var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
		var kick_mix;
		pitch_contour = freq * Line.kr(2, 1, 0.02);
		drum_osc = PMOsc.ar(	pitch_contour,
			mod_freq,
			mod_index/1.3,
			mul: 1,
			add: 0);
		drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
		drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, decay), 1.0, doneAction: 2);

		beater_source = WhiteNoise.ar(beater_noise_level);
		beater_hpf = HPF.ar( beater_source, 500);
		lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
		beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
		beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);

		kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
		OffsetOut.ar(out, Pan2.ar(kick_mix, pan))
	}
).add
);
/*
Synth(\SOSkick);
*/


// SOSsnare -------
// http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp

(
SynthDef(\SOSsnare,
	{arg out = 0, decay = 0.1, drum_mode_level = 0.5,
		snare_level = 0.5, snare_tightness = 1000,
		freqSnr = 405, amp = 0.8, pan=0;

		var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
		var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
		var snare_env;
		var snare_drum_mix;
		var freq = freqSnr;

		drum_mode_env = EnvGen.ar(Env.perc(0.005, decay, 0.5), 1.0, doneAction: 2);
		drum_mode_sin_1 = SinOsc.ar(freq * 0.53, 0, drum_mode_env * 0.5);
		drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
		drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq * 0.85),
			184,
			0.5 / 1.3,
			mul: drum_mode_env * 5
		);
		drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) ;

		// choose either noise source below
		//	snare_noise = Crackle.ar(2.01, 1);
		snare_noise = LFNoise0.ar(20000, 0.1);
		snare_env = EnvGen.ar(Env.perc(0.001, decay, 80, 2), 1.0, doneAction: 2);
		snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
		snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, rq: 0.1);
		snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, rq: 0.1);
		snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, rq: 0.0001);
		snare_reson = Resonz.ar(snare_brf_4, snare_tightness, 1) * snare_env;
		snare_drum_mix =
		(drum_mode_mix * drum_mode_level)
		+
		(snare_reson * snare_level )
		* amp;
		OffsetOut.ar(out, Pan2.ar(snare_drum_mix, pan))
	}
).add
);
/*
Synth(\SOSsnare);
*/

// SOShats -------
// http://www.soundonsound.com/sos/Jun02/articles/synthsecrets0602.asp

(
SynthDef(\SOShats,
	{arg out = 0, freq = 6000, decay = 0.1, amp = 0.8;
		var root_cymbal, root_cymbal_square, root_cymbal_pmosc;
		var initial_bpf_contour, initial_bpf, initial_env;
		var body_hpf, body_env;
		var cymbal_mix;

		root_cymbal_square = Pulse.ar(freq, 0.5, mul: 1);
		root_cymbal_pmosc = PMOsc.ar(root_cymbal_square,
			freq * [1.34, 2.405, 3.09, 1.309],
			[310/1.3, 26/0.5, 11/3.4, 0.72772],
			mul: 1,
			add: 0);
		root_cymbal = Mix.new(root_cymbal_pmosc);
		initial_bpf_contour = Line.kr(15000, 9000, 0.1);
		initial_env = EnvGen.ar(Env.perc(0.005, 0.1), 1.0);
		initial_bpf = BPF.ar(root_cymbal, initial_bpf_contour, mul:initial_env);
		body_env = EnvGen.ar(Env.perc(0.005, decay, 1, -2), 1.0, doneAction: 2);
		body_hpf = HPF.ar(in: root_cymbal, freq: Line.kr(9000, 12000, decay),mul: body_env, add: 0);
		cymbal_mix = Mix.new([initial_bpf, body_hpf]) * amp;
		OffsetOut.ar(out, [cymbal_mix, cymbal_mix])
}).add
);

/*
Synth(\SOShats);
*/


// SOStom -------
// http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp

(
SynthDef(\SOStom,
	{arg out = 0, decay = 0.4, drum_mode_level = 0.25,
		freq = 90, drum_timbre = 1.0, amp = 0.8;
		var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
		var stick_noise, stick_env;
		var drum_reson, tom_mix;

		drum_mode_env = EnvGen.ar(Env.perc(0.005, decay), 1.0, doneAction: 2);
		drum_mode_sin_1 = SinOsc.ar(freq*0.8, 0, drum_mode_env * 0.5);
		drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
		drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.9),
			freq*0.85,
			drum_timbre/1.3,
			mul: drum_mode_env*5,
			add: 0);
		drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;
		stick_noise = Crackle.ar(2.01, 1);
		stick_env = EnvGen.ar(Env.perc(0.005, 0.01), 1.0) * 3;
		tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp;
		OffsetOut.ar(out, [tom_mix, tom_mix])
	}
).add
);

/*****
(instrument: \SOSkick).play;
(instrument: \SOSsnare).play;
(instrument: \SOShats).play;
(instrument: \SOStom).play;
*****/
//-e.o. SOS drums ---------------------------------------------------





SynthDef("pgrain",
	{ arg out = 0, freq=800, decay=0.01, amp=0.1, pan = 0, distortion = 0;
		var window, env, u, nu;
		window = Env.perc(freq.reciprocal * Rand(0.8, 4), decay);
		env = EnvGen.ar(window,  doneAction:2);
		amp = AmpCompA.ir(freq) * amp;
		freq = Vibrato.kr(freq, Rand(13,0), Rand(0.001, 0), depthVariation:0.001);
		freq = (freq * XLine.ar(4, 1, 0.0025)).minNyquist;
		u = SinOsc.ar(freq, 0.5pi);
		u = u + LFTri.ar(max(freq * 0.25, 30), 0.5, 0.2);
		u = u * env;
		distortion = distortion * (env.squared + 0.1);
		nu = distort(u * (distortion * 8 + 1));
		u = XFade2.ar(u, nu, distortion * 2 - 1);

		OffsetOut.ar(out,
			Pan2.ar(u, pan, amp * 4)
		)
	}
).add;
/*****
(instrument: \pgrain).play;
(instrument: \pgrain, \freq: 2000, \decay: 0.1).play;
******/

(
SynthDef("grainlet",
	{ arg out=0, freq=440, decay=0.05, pan=0, amp=0.2;
		var env = EnvGen.kr(Env.perc(0.01, decay, amp), doneAction:2);
		OffsetOut.ar(out, Pan2.ar(FSinOsc.ar(freq, 0, env), pan))
}).add;

SynthDef("grainFM_a",
	{ arg out = 0, freq=800, freqFM=800, fmi = 100.5, att=0.01, decay=0.001, amp = 0.5, pan = 0;
		var window, ratio=0.1;
		window = Env.perc(att, decay, amp);
		OffsetOut.ar(out,
			Pan2.ar(
				SinOsc.ar(
					SinOsc.ar(freqFM) * fmi
					+
					freq
				),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
	}
).add;

SynthDef("grainFM_b",
	{ arg out = 0, freq=800, freqFM=800, fmi = 100.5, att=0.01, decay=0.001, amp = 0.5, pan = 0;
		var window, ratio=0.1;
		window = Env.perc(att, decay, amp);
		OffsetOut.ar(out,
			Pan2.ar(
				SinOsc.ar(
					SinOsc.ar(freqFM * LFNoise1.kr(0.1).range(0.8, 1.2)) * fmi
					+
					freq
				),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
	}
).add;
);
/*****
(instrument: \grainlet, \freq: 2000, decay: 0.001).play;
(instrument: \grainFM_a, \freq: 2000, decay: 1).play;
(instrument: \grainFM_b, \freq: 2000, decay: 1).play;
******/



//////////////////////////////////////////////////////////////////////////
/// PB_UP classix Synth Defs //////////////////////////////////////////////////////////////////////////

SynthDef("hatXLine",
	{ arg out = 0, freq=8000, decay=0.0001, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ amp, 0.001 ], [ decay ], 'exponential');
		OffsetOut.ar(out,
			Pan2.ar(
				(
					BPF.ar(ClipNoise.ar, freq * XLine.kr(1.1, 1, decay) , 0.1)
					* 8).softclip
				+ HPF.ar(WhiteNoise.ar, 13000)
				, pan
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;
/*****
(instrument: \hatXLine, freq: rrand(2000, 12000), decay: 0.1).play;
*****/

SynthDef("hatXLRev",
	{ arg out = 0, freq=8000, decay=0.0001, amp=0.5, pan = 0.0;
		var window;
		window = Env.new([ 0.001, amp ], [ decay * 1.3 ], 'exponential');
		OffsetOut.ar(out,
			Pan2.ar(
				(
					BPF.ar(ClipNoise.ar, freq * XLine.kr(1.0, 1.2, decay) , 0.1)
					* 7).softclip
				+ HPF.ar(WhiteNoise.ar, 13000)
				, pan
			) * EnvGen.ar(window, doneAction:2)
		)
}).add;
/*****
(instrument: \hatXLRev, freq: rrand(2000, 12000), decay: 0.1).play;
*****/



(
// \f is a glitch factor
SynthDef(\hhat, {|out=0, decay=0.2, freq=9000, amp=0.1|
	var o, u;
	o = Pan2.ar(Decay.kr(Trig1.kr(Impulse.kr(1/1000), 0.01), decay ).clip2(1) * BPF.ar(WhiteNoise.ar, freq, 0.2, 6), Rand(-1, 1.0));
	Line.kr(1, 0, decay*1, doneAction:2);
	OffsetOut.ar(out, o*amp);
}).add;

SynthDef(\resobas, {|out=0, decay=2, freq=50, amp=1, pan=0|
	var o = Limiter.ar(
		Ringz.ar(
			Trig1.ar(Impulse.kr(0), 0.01)*BrownNoise.ar(0.125),
			freq,
			decay, 0.15 * amp
		)
	);
	Line.kr(1, 0, decay, doneAction:2 );
	OffsetOut.ar(out, Pan2.ar(o, pan));
}).add;
);
/*****
(instrument: \hhat, freq: 9000).play;
(instrument: \resobas).play;
******/
/*
a percussion SynthDef Library by Jan Kees van Kampen

modified by HH so all Synths free themselves after playing

todo: better amp scaling in synthdef, so amp arg is normalized amongst synthdefs

Synth(\bssine,[\freq, 4000, \decay, 2])
Synth(\bspulse,[\freq, 1000, \width, 0.02, \decay, 2])
Synth(\bspulse,[\freq, 250, \width, 0.1, \decay, 2])
Synth(\bsfm,[\freq, 1250, \modfreq, 1.5, \modindex, 5, \decay, 2, \amp, 0.4])
Synth(\bsfm,[\freq, 150, \modfreq, 200.5, \modindex, 10, \decay, 2, \amp, 0.3])
Synth(\bsfnoise, [\freq, 2000, \rq,0.001, \decay, 0.9, \amp, 1]);
Synth(\bsfnoise2, [\freq, 4000, \rq,0.1, \decay, 0.1, \fdecay, 0.03, \amp, 3]);
Synth(\honky, [\freq, 500, \decay, 0.3, \amp, 0.3]);
Synth(\drum1, [\freq, 1500, \freqMul, 10, \decay, 0.6, \fdecay, 0.3, \amp, 3]);

Synth(\ana1,[\freq, 250, \decay, 2, \amp, 0.4])
Synth(\ana2,[\freq, 250, \decay, 2, \amp, 0.4])
Synth(\fm1,[\freq, 150, \decay, 2, \amp, 0.4])
Synth(\fm2,[\freq, 150, \decay, 2, \amp, 0.4])
*/

SynthDef(\bssine,{ |out=0, t_trig=1, freq=440, decay=0.2, amp=0.9|
	var env, snd;
	env = EnvGen.ar(Env.perc(1e-3,decay), t_trig, doneAction:2);
	snd = SinOsc.ar(freq*[1,1.01]);
	OffsetOut.ar(out, snd * env * amp);
}).add;

SynthDef(\bspulse,{ |out=0, t_trig=1, pan=0, freq=200, width=0.5, decay=0.1, amp=0.6|
	var env, snd;
	env = EnvGen.ar(Env.perc(1e-2,decay), t_trig, doneAction:2);
	snd = Pulse.ar(freq, width);
	OffsetOut.ar(out, Pan2.ar(snd * env * amp * 0.5));
}).add;

SynthDef(\bsfm, {| out=0, t_trig=1, freq=1000, modfreq=100, modindex=1, decay=0.2, amp=0.3|
	var snd, env = EnvGen.ar(Env.perc(0.01, decay ), t_trig, doneAction:2);
	snd = PMOsc.ar(freq, modfreq, modindex,SinOsc.kr(0.3,[0, 1],pi));
	OffsetOut.ar(out, snd * env * amp);
}).add;

SynthDef(\bsfnoise, {| out=0, t_trig=1, freq=1000, rq=0.1, pan=0, decay=0.2, amp=0.3|
	var snd, env = EnvGen.ar(Env.perc(0.001, decay ), t_trig, doneAction:2);
	snd = BPF.ar(WhiteNoise.ar(4), freq, rq); // freq is filter cutoff frequency here, rq is the reciprocal of q (bandwith of filter)
	OffsetOut.ar(out, Pan2.ar(snd * env * amp, pan));
}).add;

SynthDef(\bsfnoise2, {| out=0, t_trig=1, freq=1000, rq=0.1, decay=0.2, fdecay=0.04, amp=0.3, pan=0|
	var snd, fenv, env = EnvGen.ar(Env.perc(0.001, decay ), t_trig, doneAction:2);
	fenv = EnvGen.ar(Env.perc(1e-5, fdecay, curve:-4), t_trig, doneAction:0);
	snd = BPF.ar(WhiteNoise.ar(4), freq*(1+fenv), rq); // freq is filter cutoff frequency here, rq is the reciprocal of q (bandwith of filter)
	OffsetOut.ar(out, Pan2.ar(snd * env * amp, pan));
}).add;

SynthDef(\honky,{ |out=0, t_trig=1, freq, decay=0.1, amp=0.9, pan=0|
	var snd = SinOsc.ar(freq).cubed.cubed;
	var env = EnvGen.ar(Env.perc(1e-3,decay), t_trig, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd * amp * env, pan));
}).add;

SynthDef(\drum1, {|out=0, t_trig=1, freq, freqMul=4, decay=0.1, fdecay=0.02, rq=0.2, amp=0.7, pan=0|
	var snd, fenv, env = EnvGen.ar(Env.perc(1e-5, decay, curve:-8), t_trig, doneAction:2);
	fenv = EnvGen.ar(Env.perc(1e-5, fdecay, curve:-4), t_trig, doneAction:0);
	snd = BPF.ar( WhiteNoise.ar(10), freq * freqMul * fenv + 100, rq);
	OffsetOut.ar(out, Pan2.ar(snd.softclip * amp * env, pan));
}).add;

SynthDef(\drum2, {|out=0, t_trig=1,freq, freqMul=4, decay=0.1, ffreq=1000, rq=0.3, amp=0.4, pan=0|
	var snd, env = EnvGen.ar(Env.perc(1e-9, decay, curve:-8), t_trig, doneAction:2);
	snd = BPF.ar( WhiteNoise.ar(10), freq * freqMul + 100, rq)
	+ SinOsc.ar(freq/2)!2;
	OffsetOut.ar(out, Pan2.ar(LPF.ar(snd, ffreq, amp * env * 0.5), pan));
}).add;


SynthDef(\ana1, {|out=0, t_trig=1, freq=100, sfreq=100, pfreq, pwidth=0.2, decay=0.3, pdecay=0.07,
	ffreq=700, rq=0.3, amp=0.3|
	var aenv, penv, osc1, osc2, filtd;
	aenv = EnvGen.ar(Env.perc(0.01, rrand(decay/2,decay*2)), t_trig, doneAction: 2);
	penv = 1 + EnvGen.ar( Env.perc(0.01, pdecay), t_trig, timeScale:0.2, levelScale:-0.1, doneAction: 0);
	pwidth = pwidth * SinOsc.kr(0.1, [0, pi], 0.24, 0.25);
	sfreq = freq;
	pfreq = freq * SinOsc.kr([0.5, 1.333],0,0.01,1);
	osc1 = VarSaw.ar(sfreq*penv,0,pwidth);
	osc2 = LFPulse.ar((pfreq?sfreq)*penv,0,pwidth);
	filtd = RLPF.ar(Mix([osc1, osc2]), ffreq, rq);
	OffsetOut.ar(out, filtd * aenv * amp * 0.7)
}).add;

SynthDef(\ana2, {|out=0, t_trig=1, freq=100, sfreq=100, pfreq, pwidth=0.2, decay=0.3,
	pdecay=0.07, ffreq=700, rq=0.3, amp=0.4|
	var aenv, penv, osc1, osc2, filtd;
	aenv = EnvGen.ar(Env.perc(0.01, rrand(0.02,decay)), t_trig, doneAction:  2);
	penv = 1 + EnvGen.ar(Env.perc(0.01, pdecay), t_trig, timeScale:0.2, levelScale:-0.1, doneAction: 0);
	pwidth = pwidth * SinOsc.kr(0.1, [0, pi], 0.24, 0.25);
	sfreq = freq  * TChoose.kr(t_trig, [1.5, 1.0, 0.5, 2]);
	pfreq = freq * SinOsc.kr([0.5, 1.333],0,0.01,1) * TChoose.kr(t_trig, [1.5, 1.0, 0.5, 2]);
	osc1 = VarSaw.ar(sfreq*penv,0,pwidth);
	osc2 = LFPulse.ar((pfreq?sfreq)*penv,0,pwidth);
	filtd = RLPF.ar(Mix([osc1, osc2]), ffreq, rq);
	OffsetOut.ar(out, filtd * aenv * amp * 0.5)
}).add;


SynthDef(\fm1, {| out=0, t_trig=1, freq=1040, decay=0.3, amp=0.2|
	var snd, env = EnvGen.ar(Env.perc(0.01, freq.reciprocal * 200 * decay ), t_trig, doneAction: 2);
	snd = PMOsc.ar(freq, freq*0.5, 2*TExpRand.kr(0.5, 4, t_trig),SinOsc.kr(0.3,[0,1],pi));
	OffsetOut.ar(out, snd * env * amp);
}).add;


SynthDef(\fm2, {| out=0, t_trig=1, freq=1040, decay=0.09, amp=0.6|
	var snd, env = EnvGen.ar(Env.perc(0.01,decay*LFNoise2.kr(0.1,0.1,1)), t_trig, doneAction: 2);
	snd = RLPF.ar(
		PMOsc.ar(freq, freq * IRand(2,4)/2, TRand.kr(0.5, 3, t_trig),0),
		SinOsc.kr([0.1, 0.11]).range(400, 1900),
		0.4
	);
	OffsetOut.ar(out, snd * env * amp);
}).add;

SynthDef(\sine, { arg out, freq, attack=0.01, decay=1, amp=1, pan;
	var snd, env, u=1;
	env = EnvGen.kr(Env.perc(attack, decay), 1, doneAction:2);
	snd = SinOsc.ar(freq, 0, amp * env);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\pmosc, { arg out, freq, decay=1, amp=1, pan;
	var env, u=1;
	env = EnvGen.kr(Env.perc(0.01, decay), 1, doneAction:2);
	5.do { var d; d = exprand(0.01, 1); u = SinOsc.ar(d * 300, u, rrand(0.1,1.2) * d, 1) };
	OffsetOut.ar(out, Pan2.ar(SinOsc.ar(u + 1 * freq, 0, amp * env), pan));
}).add;

SynthDef(\saw,{ arg out, freq, attack=0.01, decay=1, ffMul=0, amp=1, pan;
	var snd, env, u=1;
	env = EnvGen.kr(Env.perc(attack, decay), 1, doneAction:2);
	snd = LPF.ar(LFSaw.ar(freq, 0, amp * env), freq*(ffMul+1));
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\drum3, { |out=0, t_trig=1, freq, freqMul=4, decay=0.1, fdecay=0.02, rq=0.2, amp=0.7|
	var snd, fenv, env = EnvGen.ar(Env.perc(1e-5, decay, curve:-8), t_trig);
	fenv = EnvGen.ar(Env.perc(1e-5, fdecay, curve:-4), t_trig, doneAction:2);
	snd = BPF.ar( GrayNoise.ar(10) ! 2, freq * freqMul * fenv + 100, rq);
	snd = snd + SinOsc.ar(Rand(300,10080),0,fenv);
	OffsetOut.ar(out, snd.softclip * amp * env);
}).add;

//////////////////////// E.o. JKvK lib /////////////////////////////////


SynthDef("fbBass",
	{ arg out = 0, freq=50, sustain=0.01, amp=0.5, fb=1, pan = 0;
		var window;
		var fbl = Line.kr(0.1, fb, sustain);
		window = Env.perc(0.001, sustain, amp, -2);
		OffsetOut.ar(out,
			Pan2.ar(
				SinOscFB.ar(freq, fbl),
				pan
			) * EnvGen.ar(window, doneAction:2)
		)
	}
).add;

SynthDef(\fooA, {|freq = 440, dur = 1, amp = 0.1|
	Out.ar(0, SinOsc.ar(freq, 0, amp) * Env.perc(0.001, dur).kr(2));
}).add;


// compare new against old SynthDef lib.
// Flaw: can execute only once! Next time, difference will be 0
q.synthDefs = (SynthDescLib.global.synthDescs.keys - q.origSynthDefs).asArray.reject {|it| it.asString.beginsWith("syst") }.sort;

q.paramNames = ();

SynthDescLib.global.synthDescs.keysValuesDo { |key, desc|
	var dict = ();
	desc.controls.do { |cont|
		if (cont.name != \out) {
			dict.put(cont.name, cont.defaultValue);
		}
	};
	q.paramNames.put(key, dict);
};

q.tonalDefs = q.paramNames.select{|v| v.keys.includes(\freq) }.keys(SortedList);

// q.synthDefs.printcsAll;

postf("\n*** SynthDef Library loaded with % Synths *** access them with \nq.synthDefs;\n\n", q.synthDefs.size);
postf("\n*** % SynthDefs have a freq input: *** access them with \nq.tonalDefs;\n\n", q.tonalDefs.size);
'';
