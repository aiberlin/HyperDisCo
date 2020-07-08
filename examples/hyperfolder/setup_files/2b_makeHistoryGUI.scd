
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

// make a window for history, with special buttons
defer ({ WinBounds.showOrMake('sharedHistory') }, 0.1);

Butz.add('PRIVATE', MFdef('PRIVATE'));

Butz.add('PUBLIC', MFdef('PUBLIC'));


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
