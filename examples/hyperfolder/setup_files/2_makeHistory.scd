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
		// shoutString = "% : %".format(nameID, shoutString);
		defer { NMLShout(codeString) };
	};
}, \history).permanent_(true);

// OSCdef(\history).enable at end of startup!
OSCdef(\history).disable;


/////////////// really basic History setup:
/*
// make a history GUI window
History.makeWin;
};


// tell the Histoy class to share code via oscgroup:
History.forwardFunc = { |code, result|
"send code to shared history ...".postln;
q.oscRouter.sendMsg(\history, q.myID, code);
};
*/

// better History setup:

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
		NMLShout(code.split("\n").first)
	}
});

History.forwardFunc = MFdef('historyForward');

// make a window for history, with special buttons
defer ({ WinBounds.showOrMake('sharedHistory') }, 0.1);

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


Butz.add('PRIVATE', MFdef('PRIVATE'));
MFdef(\PRIVATE).add('set', {
	[
		MFdef(\setHistSend),
		MFdef(\setHistAccept),
		MFdef(\setRunSend),
		MFdef(\setRunAccept)
	].do(_.value(0));
});

Butz.add('PUBLIC', MFdef('PUBLIC'));
MFdef('PUBLIC').add('set', {
	[
		MFdef(\setHistSend),
		MFdef(\setHistAccept),
		MFdef(\setRunSend),
		MFdef(\setRunAccept)
	].do(_.value(1));
});


MFdef(\updateShareButs).add(\buts, {
	var funcvals = [
		MFdef(\historyForward).activeNames.includes(\share),
		OSCdef(\history).enabled,
		MFdef(\historyForward).activeNames.includes(\do_it),
		MFdef(\do_it).activeNames.includes('runCode')
	].collect(_.binaryValue);
	defer {
		q.sharebuts.do { |but, i|
			if (but.value != funcvals[i]) {
				but.value = funcvals[i]
			};
		}
	};
});

// MFdef(\updateShareButs).value;

Butz.add('History', { WinBounds.showOrMake('sharedHistory') });

WinBounds.addMake('sharedHistory', {
	var g = History.makeWin;
	g.parent.name = 'sharedHistory';
	g.zone.bounds = g.zone.bounds.moveBy(0, 60);
	g.listV.bounds = g.listV.bounds.height_(g.listV.bounds.height - 60);
	g.parent.view.decorator.reset;

	q.histgui = g;
	q.sharebuts = [
		[
			["send code 2 history OFF"],
			["send code 2 history ON"],
			MFdef(\setHistSend)
		],
		[
			["accept code 4 hist OFF"],
			["accept code 4 hist ON"],
			MFdef(\setHistAccept),
		],
		[
			["send code 2 run OFF"],
			["send code 2 run ON"],
			MFdef(\setRunSend),
		],
		[
			["accept code 2 run OFF"],
			["accept code 2 run ON"],
			MFdef(\setRunAccept),
		]
	].collect { |list, i|
		Button(g.parent,
			Rect(0,0,150,25))
		.states_([
			list[0] ++ [ nil, Color.grey (0.9) ],
			list[1] ++ [ nil, Color.green(0.9) ]
		])
		.action_(list[2])
	};

	// watch for state changes
	q.histSkip.stop.free;
	q.histSkip = SkipJack(MFdef(\updateShareButs), 0.2, { g.parent.isClosed });
	q.histSkip.start;

	// return the parent window
	g.parent;
});

