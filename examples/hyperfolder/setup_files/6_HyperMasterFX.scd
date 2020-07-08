(
// define which FX are going to be used.
// As MasterFX is based on ProxyChain, these FX are the same as in ProxyChain.

ProxyChain.add3('dualMax', \filter -> { |in,
	limit = 1.0, gain = 1,
	eqTilt = 0.0, limTilt = -0.5, xfreq = 300|

	var loGain, hiGain, loSig, hiSig;
	var loLim, hiLim;
	var loMax = 0, hiMax = 0;
	var loCtl, hiCtl, loOut, hiOut, sumOut;

	limit = limit.lag(0.1);
	gain = gain.lag(0.1);
	xfreq = xfreq.lag(0.1);

	loGain = eqTilt.lag(0.1).linlin(-1, 1, 1.8, 0.2);
	hiGain = 2 - loGain;
	loLim = limTilt.lag(0.1).linlin(-1, 1, 0.9, 0.1);
	hiLim = (1 - loLim);
	// adjust for equal power, and scale to limit:
	loLim = (loLim.sqrt * limit);
	hiLim = (hiLim.sqrt * limit);

	loSig = RLPF.ar(in, xfreq.lag(0.1), 0.7);
	hiSig = (in - loSig);
	loSig = loSig * (loGain * gain); //.postln.poll(2, "logain");
	hiSig = hiSig * (hiGain * gain); // .poll(2, "higain");

	// get level control signals from channels
	loCtl = PeakFollower.ar(loSig, 0.999).postln; // .poll(2, "loCtl"); // estimate pretty fast response, adjust!
	hiCtl = PeakFollower.ar(hiSig, 0.999);

	// // link channels: take peaks of loudest chan as control signals:
	// loCtl.do { |ch| loMax = max(loMax, loCtl) };
	// hiCtl.do { |ch| hiMax = max(hiMax, hiCtl) };
	// loCtl = loMax;
	// hiCtl = hiMax;

	// tweak these: slopeAbove is 0.0, i.e. hard limit
	// clampTime is as fast as possible with 0.002,
	// relaxtime is normal with 0.1.
	loOut = Compander.ar(loSig, loSig, loLim, 1, 0.0, 0.0, 0.1);
	hiOut = Compander.ar(hiSig, hiSig, hiLim, 1, 0.0, 0.0, 0.1);

	sumOut = loOut + hiOut;
	// hard clip for peaks that escape equal-power-bandsplit
	SendReply.ar(sumOut.abs > 1.0, "/clipped", (0..sumOut.lastIndex));
	sumOut.clip2(limit);

}, 1, (
	limit: [0.1, 1, \exp],
	gain: [0.5, 8, \exp],
	eqTilt: \pan,
	limTilt: \pan,
	xfreq: [100, 900, \exp],
));

// The order in slotNames determines order of execution of the efx.

MasterFX(server: s,
    numChannels: 2,
    slotNames: ['dualMax'],
    busIndex: 0
);

MasterFX(s).add(\dualMax, 1);
)
