// SpeechLib only applies to MAX OSX's "say" command.
/////// four kinds of events:
// speech, synthesis, sample, drawing


// speech events - prep:
(
~voiceInfo = unixCmdGetStdOut("say -v ?");
~voiceLines = ~voiceInfo.split($\n).drop(-1);
~voices = ~voiceLines.collect { |line| line.keep(line.indexOf($ )) };

Event.addEventType(\say, {
	var str = "say";
	~voice !? { str = str + "-v" + ~voice };
	~rate !? { str = str + "-r" + ~rate };
	str = str + ~text ? "";
	str.postcs;
	if (~wait == true) {
		unixCmdGetStdOut(str);
	} {
		unixCmd(str);
	};
});
);

/* // tests
(type: \say, text: "Yo.", voice: "Anna").play;
(type: \say, text: "Yo.", voice: ~voices.choose).play;
(type: \say, text: "Hi, I am Seeri.", voice: "Samantha", rate: 100).play;
(type: \say, text: "la-e-i-ooum.", voice: "Alex", rate: 200).play;
(type: \say, text: "la-e-i-ooum.", voice: "Anna", rate: 700).play;
(type: \say, text: "Yo.", voice: "Anna", rate: 0.1).play;
(type: \say, voice: "Anna", rate: 0.1).play;

30.do {
	(type: \say, text: "currentEnvironment.choose", voice: ~voices.choose).play;
};
*/

// filter the old and crappy, and silly fx voices
// this could be a method of Say.silliList
~fxvoices = [
	"Agnes", "Albert", "Bad", "Bahh", "Bells", "Boing",
	"Bubbles", "Bruce", "Cellos", "Deranged", "Fred",
	"Good", "Hysterical", "Junior", "Pipe",
	"Princess", "Ralph", "Trinoids", "Whisper", "Zarvox" ];

~okvoices = Say.voices.reject { |v|
	~fxvoices.includesEqual(v. name)
};
~okvoices.size; // adc: 51 remaining
~okvoices.collect(_.name).postln;

~voicesByLang = { |langSym|
	~okvoices.select { |dict| dict.langSymbol.asString
		.beginsWith(langSym.asString) };
};

~langKeys = ~okvoices.collectAs( { |v| v.langSymbol.asString.split($_).first.asSymbol
}, Set).asArray.sort.postln;

/*
~voicesByLang.value(\en).size;
~voicesByLang.value(\de);
~voicesByLang.value(\ar);
~voicesByLang.value(\pt).size;
~voicesByLang.value(\es).size;
~voicesByLang.value(\it).size;
~voicesByLang.value(\tr).size;
*/

"hello wuuuurld".say;