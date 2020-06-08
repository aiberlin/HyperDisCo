q = q ? ();
q.oscRouter = q.oscRouter ? ();

/*
NetAddr.localAddr.sendMsg(\do_it, \adc, "(1 + 2)".cs);
*/

MFdef('historyForward').add('do_it', { |code, result|
	"send code to run everywhere ...".postln;
	q.oscRouter.sendMsg(\do_it, q.myID, code);
});

MFdef('historyForward').disable('do_it');

History.forwardFunc = MFdef('historyForward');

/*
// now you can turn sharing to history on/off:
MFdef('historyForward').enable(\add2Hist);
MFdef('historyForward').disable(\add2Hist);

// and sending all others to run your code
MFdef('historyForward').enable(\do_it);
MFdef('historyForward').disable(\do_it);
*/


/*
MFdef(\do_it).(['/do_it', 'adc', '(1 + 2).postln']);
MFdef(\do_it).(['/do_it', 'adc', '(1 + 2.gargle).postln;']);
MFdef(\do_it).(['/do_it', 'adc', 'unixCmd(\"say what?\").postln;']);
*/

q.postRunCode = false;

MFdef(\do_it).add('runCode', { |msg|
	var who = msg.postcs[1].asString;
	var code = msg[2].asString;

	var isSafe = {
		// code from OpenObject avoidTheWorst method
		code.find("unixCmd").isNil
		and: { code.find("systemCmd").isNil }
		and: { code.find("File").isNil }
		and: { code.find("Pipe").isNil }
		and: { code.find("Public").isNil }
	}.value;

	isSafe.if {
		// defer it so GUI code also always runs
		defer {
			try {
				"do_it: interpreting code ...".postln;
				if (q.postRunCode) { code.postcs };
				code.interpret
			} {
				(
					"*** q.oscRouter do_it - code interpret failed:".postln;
					code.cs.keep(100).postln;
				).postln
			}
		}
	} {
		"*** q.oscRouter do_it unsafe code detected:".postln;
		code.postcs;
	}
});

MFdef(\do_it).enable('runCode');
MFdef(\do_it).disable('runCode');

//////// use this MFdef for the OSCFunc listener as well
q.oscRouter.addResp(\do_it, MFdef(\do_it));
