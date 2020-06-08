SuperCollider - The Quick Guided Tour

SuperCollider is an Object Oriented Programming Language,
designed for realtime sound, graphics, interaction,
network connectivity.

Classic joke about an earlier MusicN language:
"It is a kitchen, not a restaurant"
i.e. you only eat well if you do the cooking
(or if you know someone who knows someone who cooks)


// A very friendly Music-centric tutorial:
"Getting-Started-With-SC".help;


Overview of some areas of working with code:

- Handling of the app itself
-- text editing, shortcuts, running and stopping code
-> See Language Menu:
	Evaluate selection
	Stop
	Help

- Writing code that does what you want
-- syntax, logic, testing,
	... this takes some time ...

- Combining stuff into setups
-- write or find generators for sound & graphics,
-- connect interfaces to control/influence the generators

- Playing with them!
-- Composing, improvising,
-- alone, with others

- inviting others to experience & play
-- playing partners, visitors, audience etc




// ******* Common useful Objects in SC: *********** //

// Numbers	(Integers = whole numbers, Float = fractions, ... others)
1
1.618034
pi
0.5pi

// question - add floats and integers?
1 + [ 2, 1.5 ];

// Numbers understand many math operations:
1 + 2; //
3 / 4; //
1 + 2 * 4; // evaluated left to right
1 + (2 * 4); // when in doubt, put thing in parens


Number can assume many meanings,
depending on what they are used for:
frequencies, colors, geometric shapes, anything.



// all the math operations here:
SimpleNumber.help

// Collections, Arrays, Lists, Dictionaries
[ 1, 2, 3 ];
[ 1, 2, 3 ].dump;

List[ 1, 2, 3 ];

(a: 1, b: 2, c: 3);

~list = [ 1, 2, 3, 5 ];
~list.dump;
~list.at(0);  // at index begins with 0
~list.last;
~list.scramble;
~list.size;
~list.do { |element| element.postln };
~list.collect { |element| element.squared };

~list + 100; // becomes a collect automagically

~list2 = ~list.collect { |element| element.squared };

~list
~list2

// what if we mistype, or give a command that does not exist?
~list.glitch;
///   DoesNotUnderstandError ...
// ERROR: Message 'glitch' not understood.
// RECEIVER:
// nil

Array.help;
List.help
Collection.help;
Dictionary.help;
Event.help;

Collections understand all the math that numbers understand:
[1, 2, 3] * 10;
[1, 2, 3] * [100, 200, 300];
[1, 2, 3] * [100, 200]; // expands to the longest list
[1, 2, 3] *.t [100, 200]; // expand to a matrix


// Characters, Strings, Symbols
$a.dump
"abcde".dump;
"abcde".at(3);
"abcde"[3]; // same as at
"abcde".scramble;
"abcde".reverse;

// symbols are like fixed strings ...
// two ways to write symbols
'abcde' == \abcde;
// they are used in many places for looking things up by name
~dict = ('a': "eiou", 'e': "aiou");
~dict['a'];


////////// how about remembering every bit of code we run?
History.start;
History.makeWin;
History.logFolder.openOS;

1 + 2 * 3;
"abcde".scramble;

//// ON TO SOUND!
//// For this, SuperCollider has a socalled "server",
//// a second program that does all the sound generating.
//// this is usually stored in the global variable s
s.dump;
s.boot; // tell the server to start

().play; // bad piano sound - it's a kitchen ...

"Pattern Guide".help;

Pbind(\note, Pseq((0..7)), \dur, 1/8).play;

Pbind(\degree, Pseq((0..7)), \dur, 1/8).play;

///// moment in the restaurant:
//// load a library with a lot of so-called synthdefs
"libs/_SynthLib.scd".resolveRelative.openOS;

"libs/_SynthLib.scd".loadRelative;


q.synthDefs.cs; // that many
q.tonalDefs.cs; // the ones with frequency input / pitch

(instrument: 'grainXLine').play;
(instrument: 'grainSine', amp: 0.5, sustain: 0.02).play;

// try one of them:
(
Pbind(
	\instrument, \Mridangam,
	\degree, Pseq((0..7)),
	\dur, 1/8
).play;
)

(\instrument: \Mridangam, degree: 12).play;


// crackly noise
x = { Dust2.ar([30, 30]) }.play;
x.free;

x = { SinOsc.ar([332, 334]) * 0.1 }.play;
x.free;

(
Ndef(\sins).fadeTime = 3;
Ndef(\sins, {
	Splay.ar(
		SinOsc.ar({ exprand(50, 2000) }!12)
	) * 0.1
}).play;
)

(
Tdef(\sins, {
	loop {
		Ndef(\sins).rebuild;
		exprand(5, 20).wait;
	}
}).play;
)

Tdef(\sins).stop;
Ndef(\sins).end;

// on macOS, the examples folder is in the same folder as the app:
Platform.resourceDir.dirname.dirname.dirname.openOS;

// these two files have a lot of simple-to-complex sound examples

[
"/Applications/SuperCollider/examples/demonstrations/SC2-examples_1.scd",
"/Applications/SuperCollider/examples/demonstrations/SC2-examples_2.scd"
].do(_.openOS);


/////////////////// GRAPHICS:

// make a userview to draw on
~win = Window("basic graphics", Rect(0,0,400,400)).front;
~uv = UserView.new(~win, Rect(0,0,400,400));
~uv.background = Color.white;

// tell it what to draw:
~uv.drawFunc = {
	Pen.strokeRect(Rect(10,10,380,380));
};
~uv.refresh; // now trigger drawing

// strings
~uv.drawFunc = {
	Pen.stringAtPoint("Can write STRINGS too", 10@200, Font("Futura", 24));
};
~uv.refresh;

(
// string, rect and ovals
~uv.drawFunc = {
	Pen.stringAtPoint("Can write STRINGS too", 10@200, Font("Futura", 24));
	Pen.strokeRect(Rect(10,10,380,380));
	Pen.color = Color.red;
	10.do {
		Pen.strokeOval( Rect(300.rand, 300.rand, 200.rand, 200.rand))
	};
};
~uv.refresh;
)

(
Tdef(\refresh, {
	loop {
		~uv.refresh;
		1.wait;
	};
}).play(AppClock);
)

// the Pen help file has a lot of examples!
Pen.help;


/////////////////////////////////////////
//////////// Connecting to the world:

///// 1 - Microphone - use headphones or get feedback!
{ SoundIn.ar * 0.2 }.play;

// or more flexible with JITLib-style object, Ndef
Ndef(\mic).clear;
Ndef(\mic, { SoundIn.ar * 0.2 ! 2 }).play;

Ndef(\mic).gui;

// comb filtering
Ndef(\mic, { CombL.ar(SoundIn.ar * 0.1, 0.1, [0.03, 0.02], 5) }).play;


// ring modulation
// { SoundIn.ar * SinOsc.ar([300, 800]) }.play;
Ndef(\mic, { SoundIn.ar * SinOsc.ar([300, 800]) });


// 2 - Interfaces - free graphical user interfaces for JITLib style objects!
Ndef(\mic).gui;

// 2 - Interfaces - the mouse
// mouse control of pitch:
{ SinOsc.ar(MouseX.kr(20, 2000, 1)) * 0.1 ! 2 }.play;

// mouse theremin - pitch and volume!
{ SinOsc.ar(MouseX.kr(20, 2000, 1)) * MouseY.kr(0, 0.7).squared ! 2 }.play;

// comb filtering adjustable with mouse
{ CombL.ar(SoundIn.ar, 0.1, [0.03, 0.02] * MouseX.kr(0.1, 2, \exponential), 5) }.play;

// ring modulation with mouse
{ SoundIn.ar * SinOsc.ar([MouseX.kr(50, 5000, 1), MouseY.kr(50, 5000, 1) ] ) }.play;


/////////// Extending SuperCollider with libraries - Quarks

Quarks.gui;
Quarks.directory.size; // 250+ known libraries!
Quarks.checkForUpdates;

// try installing the most popular quark:
Quarks.install("JITLibExtensions");


// this should post this info:
Installing JITLibExtensions
Adding path: /Users/adc/Library/Application Support/SuperCollider/downloaded-quarks/JITLibExtensions
JITLibExtensions installed
-> Quark: JITLibExtensions[0.1]

// And then you can reboot the interpreter
// - See Language Menu
// but also ask you to install xcode Tools first,
// or otherwise install a system program called git

// macOS: open the Terminal program
// and paste this line into it, and enter
xcode-select --install


*********** Networks of People and Machines: *************
OpenSoundControl is a common network protocol for controlling systems for music, lights, visuals, etc

// listen for a message called 'hello'
OSCdef(\hello, { |msg|
	"hello message received!".postln;
	msg.postcs;
}, \hello);

// now make an address I can send to - my own:
~myaddr = NetAddr.localAddr;
~myaddr.sendMsg(\hello);
~myaddr.sendMsg(\hello, "world", "i can send to myself ...");

~myaddr.dump;
// what else is coming in? lets trace:
OSCdef.trace;
// status messages from the server ...
// stop tracing

OSCdef.trace(false);

"