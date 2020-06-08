
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
// orthodox OSC messaging style:
s.sendMsg('/s_new', 'grainXLine', -1, 0, 0, 	\freq, 2000, \sustain, 1, \out, 0);
// simpler:
(instrument: \grainXLine).play;
*****/


// single sound
(instrument: 'grainXLine', freq: 800, sustain: 10, amp: 0.2, pan: 0, ).play;

(
// timed texture
Tdef( 'disdronic' , {
	inf.do{
		16.do {
			(instrument: "grainXLine", freq: rrand(800, 4000), sustain: rrand(1, 5.0),
				amp: 0.1).play;
			([0, 0.001, 0.1, 0.3, 0.5].choose).wait;
		};
		5.wait;
	}
} ).play;
)
