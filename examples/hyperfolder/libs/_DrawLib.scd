// draw text event - prep
(
d = d ? ();

d.fonts = Font.availableFonts;
Font(d.fonts.choose, rrand(12, 72));

d.w = Window("text").front.alwaysOnTop_(true);
d.u = UserView(d.w, Rect(0,0,400,400));
d.u.resize = 5;

d.w.background_(Color.clear);
d.u.addHalo(\ev, ());

d.u.drawFunc = { |u|
	var ev = u.getHalo(\ev);
	var scaleFactor = min(u.bounds.width / 400, u.bounds.height / 400);
	var font = ev.font ?? { Font("Baskerville", ev.fontSize ? 36) };

	u.background_(ev.bg ?? { Color.rand(0.80, 0.9).alpha_(0.5) });
	Pen.font_(font);

	Pen.translate(u.bounds.width / 2, u.bounds.height / 2);
	Pen.scale(scaleFactor, scaleFactor);
	ev.pos !? { Pen.translate(ev.pos.x, ev.pos.y) };

	Pen.rotate(ev.rot ? 0);

	Pen.stringCenteredIn(ev.text,
		Rect.aboutPoint(ev.center ? 0@0, 200, 400));
};

Event.addEventType(\draw, {
	~uv = ~uv ? d.u;
	~uv.addHalo(\ev, currentEnvironment);
	~clearOnRefresh !? { ~uv.clearOnRefresh = ~clearOnRefresh };
	defer { ~uv.refresh };
});
);

// change these for fun
d.u.clearOnRefresh_(false);
d.u.clearOnRefresh_(true);

// text drawing events
/*
(type: \draw, text: "I am a draw event.", uv: d.u).play;
(type: \draw, text: "I am a draw event.".scramble, uv: d.u).play;

(type: \draw, text: "YOLO".scramble, bg: Color(*[1,0,0].scramble), uv: d.u).play;
(type: \draw, text: "YOLO", bg: Color.rand(0.05, 0.95)).play;
(type: \draw, text: "YOLO".scramble, fontSize: 48 + 20.rand2).play;
(type: \draw, text: "YOLO".scramble, rot: 2pi.rand, fontSize: 48).play;
(type: \draw, text: "YALLA", pos: 0 @ 200.rand2, fontSize: 120.rand + 10).play;
(type: \draw, text: "YOLO", rot: 2pi.rand, pos: 100.rand2@(100.rand2)).play;
(type: \draw, text: "Palindrom\nMalayalam", rot: 2pi.rand, pos: 100.rand2@100.rand2).play;

(type: \draw, text: "Palindrom\nMalayalam", rot: 2pi.rand, pos: 100.rand2@100.rand2,
font: Font("Malayalam ML", 72), clearOnRefresh: false).play;

(type: \draw, text: "Palindrom\nMalayalam", rot: 2pi.rand, pos: 100.rand2@100.rand2,
font: Font("Malayalam ML", 72), clearOnRefresh: true).play;

r{ 30.do{|i|
	(type: \draw, text: "YALLA", pos: i.neg*2 @ (i * 10 - 200), fontSize: i+1 * 5).play;
	0.1.wait;
}
}.play(AppClock);
*/

