// one single SyncText per textID:
q.syncText = SyncText(\syncText, q.myID, q.oscRouter);

MFdef(\SyncText).add(\show, {
	if (q.syncText.currText.isNil) {
		q.syncText.requestText
	};
	"q.syncText.showDoc".postln;
	defer { q.syncText.showDoc };
});

