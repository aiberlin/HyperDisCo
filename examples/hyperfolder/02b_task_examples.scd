/// some examples for glisson:
(
Tdef(\slowPulse, {
	100.do({ arg i;
		(instrument: \glisson,

			\freq: i % 5 * 300 + 1000,
			\freq2: i % 7 * 200 + 2000,
			\amp: 0.5,
			\sustain: 0.05,
		).play;

		[1, 0.5, 0.5].choose.wait;
	});
}).play(quant: 0);
)

(
Tdef(\slow2, {
	100.do({ arg i;
		(instrument: \glisson,
			\freq: i % 5 * 100 + 200,
			\freq2: i % 7 * 200 + 500,
			\sustain: 0.01,
		).play;
		// (1 / (i % 12 + 10)).wait;
		[1, 0.5, 0.5].choose.wait;
	});
}).play(quant: 0);
)

(
// tief, 3:2
Tdef(\low3_2, {
	100.do({ arg i;
		(instrument: \glisson,
			\freq: i % 5 * 200 + 500,
			\freq2: i % 7 * 300 + 2500,
			\sustain: 0.01,
			).play;
		// (1 / (i % 12 + 10)).wait;
		0.75.wait;
	});
}).play(quant: 0);
)

(
// hochTicks
Tdef(\highTick, {
	100.do({ arg i;
		(instrument: [ \grainXLine, \grainXLRev ].choose,
			\freq: i % 20 * 200 + 4000 + 200.rand,
			\sustain: 0.005,
			\amp: 0.2,
		).play;
		 [2, 1.5, 1.25, 0.75].choose.wait;
	});
}).play(quant: 0);
)

