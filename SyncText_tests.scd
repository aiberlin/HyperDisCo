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


// multiple syncText locally
(
fork {
	var o1, o2, st1, st2;
	var texID = \testSync ++ rrand(0,999);
	o1 = OSCRouterClient(\syncTextSyncTest1, \test);
	o2 = OSCRouterClient(\syncTextSyncTest1, \test);
	o1.join;
	o2.join;
	0.5.wait;
	st1 = SyncText(\testSync, relayAddr: o1);
	0.2.wait;
	st2 = SyncText(\testSync, relayAddr: o2);
	0.4.wait; // wait for sync
	(st1.currText == st2.currText).if {"Sync ok!".postln} {"Failed to sync!".postln};
	st1.setCurr("New text " ++ rrand(0,99999));
	0.5.wait; // wait for sync;
	(st1.currText == st2.currText).if {"Sync ok!".postln} {"Failed to sync!".postln};
	st2.setCurr("Another New text " ++ rrand(0,99999));
	0.5.wait; // wait for sync;
	(st1.currText == st2.currText).if {"Sync ok!".postln} {"Failed to sync!".postln};
	o1.close;
	o2.close;
};
)