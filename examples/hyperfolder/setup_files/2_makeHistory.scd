// start recording all code evaluations into History:

q.postHistory = false;

OSCdef(\history, { |msg ... args|
	var nameID = msg[1];
	var codeString = msg[2].asString;
	var shoutString;
	History.enter(codeString, nameID);
	if (q.postHistory) {
		"history message received from % \n".postf(nameID.cs);
		codeString.postcs;
	};
	//
	if (codeString.beginsWith(NMLShout.tag)) {
		shoutString = codeString.split("\n").first.drop(4);
		////// anonymity or better not?
		shoutString = "% : %".format(nameID, shoutString).postln;
		defer { NMLShout(codeString) };
	};
}, \history).permanent_(true);

// OSCdef(\history).enable at end of startup!
OSCdef(\history).disable;


// better History setup - only nonGUI functions here:

/// Use a Modal function, an MFdef for forwarding:
MFdef('historyForward').add('share', { |code, result|
	"send code to shared history ...".postln;
	q.oscRouter.sendMsg(\history, q.myID, code);
}, false);
MFdef('historyForward').add('do_it', { |code, result|
	"send code to run everywhere ...".postln;
	q.oscRouter.sendMsg(\do_it, q.myID, code);
}, false);

// add Shouting to History forwarding
// lines that begin with //!! get shouted - test:
//!! Hello World!
MFdef('historyForward').add(\shout, { |code, result|
	if (code.beginsWith(NMLShout.tag)) {
		NMLShout(q.myID.asString ++ ":" + code.drop(4).split("\n").first)
	}
});

History.forwardFunc = MFdef('historyForward');


MFdef(\setHistSend).add(\but, { |butOrValue = 1|
	if (butOrValue.value > 0) {
		"sharing code to history is ON now".postln;
		MFdef(\historyForward).enable(\share);
		if (History.started.not) { History.start };
	} {
		"sharing code to history is OFF now".postln;
		MFdef(\historyForward).disable(\share)
	};
});

MFdef(\setHistAccept).add(\but, { |butOrValue = 1|
	if (butOrValue.value > 0) {
		"accepting code for history is ON now".postln;
		OSCdef(\history).enable;
		if (History.started.not) { History.start };
	} {
		"accepting code for history is OFF now".postln;
		OSCdef(\history).disable
	}
});

MFdef(\setRunSend).add(\but, { |butOrValue = 1|
	if (butOrValue.value > 0) {
		"sending code to run is ON now".postln;
		MFdef(\historyForward).enable(\do_it);
		if (History.started.not) { History.start };
	} {
		"sending code to run is OFF now".postln;
		MFdef(\historyForward).disable(\do_it);
	}
});

MFdef(\setRunAccept).add(\but, { |butOrValue = 1|
	if (butOrValue.value > 0) {
		"accepting code to run is ON now".postln;
		MFdef(\do_it).enable('runCode');
		if (History.started.not) { History.start };
	} {
		"accepting code to run is OFF now".postln;
		MFdef(\do_it).disable('runCode');
	}
});

MFdef(\PRIVATE).add('set', {
	[
		MFdef(\setHistSend),
		MFdef(\setHistAccept),
		MFdef(\setRunSend),
		MFdef(\setRunAccept)
	].do(_.value(0));
});
MFdef('PUBLIC').add('set', {
	[
		MFdef(\setHistSend),
		MFdef(\setHistAccept),
		MFdef(\setRunSend),
		MFdef(\setRunAccept)
	].do(_.value(1));
});

s