// make a dict, q.draw, and put all shared data and objects here:
q.draw = q.draw ? ();

// make basic drawFunc first:
MFdef(\draw).addFirst(\prep, { |uv|
	// add generally useful things to q.draw envir,
	// so every added drawing func can use those:
	q.draw.bounds = uv.bounds;
	q.draw.extent = q.draw.bounds.extent;
	q.draw.center = q.draw.extent * 0.5;
	q.draw.counter = q.draw.counter ? 0 + 1;
	// "prep...".postln;
});

MFdef(\draw).add(\latestLine, { |uv|
	// rotate newest line of code history
	var center = q.draw.center;
	var lastEntry = History.lines[0];
	var lastLine = if (lastEntry.notNil) { lastEntry[2] };
	lastLine = lastLine ? "History has not begun yet ...";

	Pen.push;
	Pen.rotate(q.draw.counter ? 0 * 0.01, center.x, center.y);
	Pen.stringCenteredIn(
		lastLine,
		uv.bounds,
		Font("Monaco", 24),
		Color.grey(0.7)
	);
	Pen.pop;
});

// make draw window:
Butz.add(\DRAW, { WinBounds.showOrMake(\DRAW) });

WinBounds.addMake(\DRAW, {
	// make a window ...
	q.draw.win = Window("DRAW", WinBounds.stored[\DRAW] ? Rect(400,400,400,400)).front;
	q.draw.win.alpha_(0.7);
	// and put a userview on it, on which we can we draw:
	q.draw.uv = UserView(q.draw.win, q.draw.win.bounds.extent.asRect).front;
	q.draw.uv.background = Color.black;
	q.draw.uv.resize_(5);
	// make the window slightly transparent
	// tell it to always render 30 fraes per second
	q.draw.uv.frameRate = 20;
	// now run
	q.draw.uv.animate = true;
	// the time step equivalent to framerate if we need it
	q.draw.dt = { 1/q.draw.uv.frameRate };

	q.draw.uv.drawFunc = MFdef(\draw);

	// return window so WinBounds can move it
	q.draw.win;
});

MFdef(\drawToggle).add('tog', { |name, which|
	if (which == 0) {
		MFdef(\draw).disable(name)
	} {
		MFdef(\draw).enable(name)
	}
});
/*
MFdef(\drawToggle).(\prep, 1);
MFdef(\drawToggle).(\prep, 0);
MFdef(\draw).activeNames;
*/

// make drawFunc window:
Butz.add('MFdef_draw', { WinBounds.showOrMake('MFdef_draw') });

WinBounds.addMake('MFdef_draw', {
	// gui for drawFunc orderedNames on/off
	var w = Window("MFdef_draw", Rect(200, 10, 150, 20)).front;
	var buts = 24.collect { |i|
		Button(w).states_([["", nil, Color.grey(0.7) ], ["", nil, Color.green ]])
		.action_({ |but|
			MFdef(\drawToggle).value(but.states[0][0], but.value)
		})
	};
	w.layout = VLayout(*buts);

	q.skipDrawFunc.stop.free;
	q.skipDrawFunc = SkipJack({
		var activeNames = MFdef(\draw).activeNames;
		buts.do { |but, i|
			var name = MFdef(\draw).orderedNames[i];
			if (name.notNil) {
				but.visible_(true);
				but.states.do(_[0] = name);
				but.states_(but.states);
				but.value = activeNames.includes(name).binaryValue;
			} {
				but.visible_(false);
			};
		};
	}, 0.2, { w.isClosed });
	w;
});