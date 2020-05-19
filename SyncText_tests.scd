// one single SyncText per textID:
q.dojo = SyncText(\CodingDojo, relayAddr: q.oscGroup);
n = NetAddr.localAddr;

// SyncEditor.all;
// x === SyncEditor(\syncText);

q.dojo.requestText;

n.sendMsg(\syncTextRequest, q.dojo.textID, \adc);
q.dojo .synced = true;
n.sendMsg(\syncTextRequest, q.dojo.textID, \adc);
q.dojo .setCurr("adc has some text now ...".postln);
n.sendMsg(\syncTextRequest, q.dojo.textID, \adc);

(
q.dojo.requestText;
q.dojo.makeDoc;

fork {
	0.1.wait;
	n.sendMsg(\syncText, q.dojo.textID, \hh, SyncText.defaultText ++ "hannes has this text");
	0.1.wait;
	n.sendMsg(\syncText, q.dojo.textID, \bg, SyncText.defaultText ++ "bruno has this one");
	0.1.wait;
	n.sendMsg(\syncText, q.dojo.textID, \vn, SyncText.defaultText ++ "victors text is different");
}
)
