///// sketch for shared visuals:
// usually visuals are done by a single person,
// running one program that renders everything to one screen.

// here, we try a structure that lets multiple people
// add their parts to a shared lisst of functions,
// where each of the functions draws some graphical elements,
// and they all get shown on every frame.


/**************   ATTENTION: ************
The steps are for tutorial explanation only - eventually just use

Butz.run('DRAW'); // to get the official DRAW window, and:
Butz.run('drawFunc'); // to get the gui for turning the funcs on and off!

************/

(
// make a dict, q.draw, and put all shared data and objects here:
q.draw = q.draw ? ();
// make a window ...
q.draw.demoWin = Window("test_draw", Rect(0,0,400, 400)).front;
// make the window slightly transparent
q.draw.demoWin.alpha_(0.997);
// and put a userview on it, on which we can we draw:
q.draw.demoUV = UserView(q.draw.demoWin, Rect(0,0,400,400)).front;
q.draw.demoUV.background = Color.black;
q.draw.demoUV.resize_(5);
// tell it to always render 30 frames per second
q.draw.demoUV.frameRate = 30;
// now run
q.draw.demoUV.animate = true;
// the time step equivalent to framerate if we need it
q.draw.dt = { 1/q.draw.demoUV.frameRate };
)
// now tell it what to draw:

q.draw.demoUV.drawFunc = { |uv|
	Pen.stringCenteredIn(
		"q.draw.demoUV.drawFunc runs",
		uv.bounds,
		Font("Futura", 24),
		Color.white
	);
};

// make sure history has a line
History.enter("// this is a historic line");

// and show the last entered code line on the demo userview:
q.draw.demoUV.drawFunc = { |uv|
	Pen.stringCenteredIn(
		History.lines[0][2],
		uv.bounds,
		Font("Monaco", 24),
		Color.white
	);
};
// different font
q.draw.demoUV.drawFunc = { |uv|
	Pen.stringCenteredIn(
		History.lines[0][2],
		uv.bounds,
		Font("Futura", 24),
		Color.grey(0.7)
	);
};


////// now make that super-flexible:
// instead of a single function,
// we use an MFdef, which can contain
q.draw.demoUV.drawFunc = MFdef(\demoDraw);


// ... and add the code drawing above
// as a named function to MFdef(\demoDraw):
MFdef(\demoDraw).add(\line0, { |uv|
	Pen.stringCenteredIn(
		// ask interpreter for current line of code
		thisProcess.interpreter.cmdLine,
		uv.bounds,
		Font("Monaco", 24),
		Color.grey(0.7)
	);
});

// overwrite with a variant:
MFdef(\demoDraw).add(\line0, { |uv|
	Pen.stringCenteredIn(
		// ask history for latest line of code
		History.lines[0][2],
		uv.bounds,
		Font("Monaco", 24),
		Color.grey(0.7)
	);
});

// addFirst: generally useful things for all drawing funcs you may write:
MFdef(\demoDraw).addFirst(\prep, { |uv|
	q.draw.bounds = uv.bounds;
	q.draw.extent = uv.bounds.extent;
	q.draw.counter = q.draw.counter ? 0 + 1;
});

MFdef(\demoDraw).orderedNames;

///// more drawing examples - see also Pen.help

// draw silly fast random rectangles
MFdef(\demoDraw).add(\randRects, { |uv|
	Pen.color = Color.rand;
	// Pen.fillRect(Rect(10,10,200, 200));
	2.do {
		Pen.fillRect(
			Rect(q.draw.extent.x * 0.5.rand,
				q.draw.extent.y * 0.5.rand,
				q.draw.extent.x * 0.5.rand,
				q.draw.extent.y * 0.5.rand
			);
		);
	}
});

// draw silly fast random rectangles
// but only every now and then:
MFdef(\demoDraw).add(\randRects, { |uv|
	// only 1/10 of the frames have randrects
	if (0.1.coin) {
		Pen.color = Color.rand;
		// Pen.fillRect(Rect(10,10,200, 200));
		2.do {
			Pen.fillRect(
				Rect(q.draw.extent.x * 0.5.rand,
					q.draw.extent.y * 0.5.rand,
					q.draw.extent.x * 0.5.rand,
					q.draw.extent.y * 0.5.rand
				);
			);
		}
	};
});

// draw silly fast random ovals too
MFdef(\demoDraw).add(\randOvals, { |uv|
	Pen.color = Color.rand(0.05, 0.95);
	// Pen.fillRect(Rect(10,10,200, 200));
	2.do {
		Pen.fillOval(
			Rect(q.draw.extent.x * 0.5.rand,
				q.draw.extent.y * 0.5.rand,
				q.draw.extent.x * 0.5.rand,
				q.draw.extent.y * 0.5.rand
			);
		);
	}
});

MFdef(\demoDraw).orderedNames;
// ->  List[ prep, line0, randRects, randOvals ]

/// use counter and sin func for continuous motion
MFdef(\demoDraw).add(\breatheOvals, { |uv|
	var count = q.draw.counter * 0.1;
	Pen.color = Color.red(1, 0.7);
	3.do { |i|
		Pen.fillOval(
			Rect(q.draw.extent.x * 0.5 * (count * 0.1 * (i + 3)).sin.abs,
				q.draw.extent.y * 0.5 * (count * 0.12 * (i + 3)).sin.abs,
				q.draw.extent.x * 0.5 * (count * 0.13 * (i + 3)).sin.abs,
				q.draw.extent.y * 0.5 * (count * 0.145 * (i + 3)).sin.abs
			);
		);
	}
});

// and a faster blue variant
MFdef(\demoDraw).add(\breatheOvals2, { |uv|
	var count = q.draw.counter * 0.162;
	Pen.color = Color.blue(1.0, 0.5);
	3.do { |i|
		Pen.fillOval(
			Rect(q.draw.extent.x * 0.5 * (count * 0.1 * (i + 3)).sin.abs,
				q.draw.extent.y * 0.5 * (count * 0.12 * (i + 3)).sin.abs,
				q.draw.extent.x * 0.5 * (count * 0.13 * (i + 3)).sin.abs,
				q.draw.extent.y * 0.5 * (count * 0.145 * (i + 3)).sin.abs
			);
		);
	}
});


// all function names in order:
MFdef(\demoDraw).orderedNames.cs;
MFdef(\demoDraw).activeNames.cs;

// turn some on,
MFdef(\demoDraw).disable(\randOvals);
MFdef(\demoDraw).enable(\randOvals);

MFdef(\demoDraw).disable(\randRects);
MFdef(\demoDraw).enable(\randRects);

//// grab more ideas from here:
Pen.help;



// now change the first function so it produces an error:
MFdef(\demoDraw).add(\line0, { |uv|
	var center = uv.bounds.center;
	123.wrongMessage;
});
// -> stops drawing all others too!!!

// MFdef can handle this:  wrap every function in case it fails:
MFdef(\demoDraw).useTry = true;

// and posts which line fails
MFdef(\demoDraw).disable(\line0);

// enable it again
MFdef(\demoDraw).enable(\line0);


// fix the code, and put it there again with same name:
MFdef(\demoDraw).add(\line0, { |uv|
	var center = uv.bounds.center;
	Pen.rotate(q.draw.counter * 0.01, center.x, center.y);
	Pen.stringCenteredIn(
		History.lines[0][2],
		uv.bounds,
		Font("Monaco", 24),
		Color.grey(0.7)
	);
})

//// Now, open the official DRAW window (button on Butz window)
Butz.run(\DRAW);
//// and see which entries are currently in that MFdef:
Butz.run(\drawFunc);

/// add one of the above exmples to MFdef(\draw):
MFdef('draw').add(\breatheOvals2, { |uv|
	var count = q.draw.counter * 0.162;
	Pen.color = Color.blue(1.0, 0.5);
	3.do { |i|
		Pen.fillOval(
			Rect(q.draw.extent.x * 0.5 * (count * 0.1 * (i + 3)).sin.abs,
				q.draw.extent.y * 0.5 * (count * 0.12 * (i + 3)).sin.abs,
				q.draw.extent.x * 0.5 * (count * 0.13 * (i + 3)).sin.abs,
				q.draw.extent.y * 0.5 * (count * 0.145 * (i + 3)).sin.abs
			);
		);
	}
});


(

MFdef('draw').add(\grad, { |uv|
	var count = q.draw.counter * 0.0162;
	// thisThread.randSeed_(1);
	1.do { |ii|
		var cols = 2.collect{|i| Color.hsv( (ii/4) +  (i/ 2) + count % 1, 1,1, 0.8)};
		Pen.addRect( Rect.newSides(0,0, q.draw.extent.x, q.draw.extent.y) );

		Pen.fillAxialGradient(0@0, q.draw.extent.x @ (q.draw.extent.y * count.sin.abs), cols[0], cols[1]);

	}
});
);

q.draw.uv.animate = true;
q.draw.uv.animate = false;
