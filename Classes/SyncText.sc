SyncText {
	classvar <defaultText = "/* sync text via network */\n";
	classvar <all;
	classvar <logDir;

	var <textID, <relayAddr, <userID, <docLocalID;
	var <currText, <lastSent, <lastReceived, <incomingVersions;
	var <recvFunc, <requestFunc;
	var <textDoc, <>synced = false, <keyDownSyncFunc, <locked = false;

	*initClass {
		all = ();
		logDir = Platform.userAppSupportDir +/+ "SyncText_logs/";
		if (logDir.pathMatch.isEmpty) { File.mkdir(logDir) };
	}

	*new { |textID = \syncText, userID, relayAddr|
		var id = (userID ?? { "whoami".unixCmdGetStdOut.drop(-1) }).asSymbol;
		var foundByName = all.detect { |st| st.textID == textID };
		var docLocalID = textID;
		if (foundByName.notNil) {
			^foundByName
		};
		// try with localID added:
		if (userID.notNil) {
			docLocalID = (textID ++ '_' ++ userID).asSymbol;
			if (all[docLocalID].notNil) {
				^all[docLocalID]
			}
		};
		// "// making new SyncText".postln;
		^super.newCopyArgs(textID, relayAddr, userID, docLocalID).init
	}

	storeArgs { ^[textID] }
	printOn { |stream| ^this.storeOn(stream) }

	init {
		incomingVersions = ();
		// put them in twice?
		all.put(textID, this);
		all.put(docLocalID, this);
		this.makeKeyDownFunc;

		if (relayAddr.isNil) {
			"%: no relayAddr given?".postf(this);
			" - cannot sync.".postln;
		} {
			this.makeOSCFuncs;
			this.requestText;
		};
	}

	enableSend { keyDownSyncFunc.enable(\sendSync) }
	disableSend { keyDownSyncFunc.disable(\sendSync) }
	sendEnabled { ^keyDownSyncFunc.activeNames.includes(\sendSync) }

	enableRecv { recvFunc.enable }
	disableRecv { recvFunc.disable(\sendSync) }
	recvEnabled { ^recvFunc.enabled }

	lock { locked = true; textDoc !? { textDoc.editable = locked.not } }
	unlock { locked = false; textDoc !? { textDoc.editable = locked.not } }

	setCurr { |newText|
		currText = newText;
		textDoc !? { this.setDocText };
	}

	setDocText {
		textDoc.text = currText;
		// other sync stuff to do here
		// - keep and restore current cursor pos?
		// - what else?
	}

	makeOSCFuncs {

		recvFunc = OSCFunc({ |msg|
			var inTextID = msg[1];
			var senderID = msg[2];
			var newText = msg[3].asString;
			lastReceived = newText;
			if (textID == inTextID and: { senderID != relayAddr.userName }) {
				"% : sync from %\n".postf(this.userID, senderID.cs);
				incomingVersions.put(senderID, newText);
				if (synced) {
					this.setCurr(newText);
				};
			};
		}, \syncText, recvPort: relayAddr.tcpRecvPort);

		// requestedText comes private only to avoid flooding elsewhere
		relayAddr.addPrivateResp(\syncText, { |senderID, msg|
			var inTextID = msg[1];
			var newText = msg[3].asString;
			"% : received private sync msg %\n".postf(this, msg.cs);
			lastReceived = newText;
			incomingVersions.put(senderID, newText);
		});

		requestFunc = OSCFunc({ |msg|
			var inTextID = msg[1];
			var senderID = msg[2];
			if (inTextID == textID) {
				case { synced.not } {
					"%: not sending text % when not synced.\n".postf(this, textID.cs);
				} { currText.isNil } {
					"%: not sending text % when currText is nil.\n".postf(this, textID.cs);
				} {
					"%: sending text % requested by %\n".postf(this, textID.cs, senderID.cs);
					// send only to requesting name?
					this.sendSyncText(senderID);
				};
			};
		}, \syncTextRequest, recvPort: relayAddr.tcpRecvPort);

		requestFunc.permanent_(true);
		recvFunc.permanent_(true);

	}

	sendSyncText { |otherName|
		if (relayAddr.isNil) {
			"*** SyncEditor: cannot send with no relayAddr.".postln;
			^false
		};
		// how to send only to single receiver only?
		if (otherName.notNil) {
			relayAddr.sendPrivate(otherName, \syncText, textID, userID, currText);
		} {
			// if no name given, send to everyone:
			relayAddr.sendMsg(\syncText, textID, userID, currText);
		}
	}
	//
	requestText {
		"% : sending requestText with: msg [ 'syncTextRequest', textID: %, userID: % ]\n"
		.postf(this, textID.cs, userID.cs);
		relayAddr.sendMsg(\syncTextRequest, textID, userID);
		synced = false;

		keyDownSyncFunc.disable(\sendSync);
		// keep all incoming versions,
		// after 1 second (?), pick the longest one (?),
		// make that currText, and consider oneself synced.
		// or just keep the latest?
		defer ({
			var longest, longID;
			incomingVersions.keysValuesDo { |senderID, textversion, i|
				if (textversion.size > longest.size) {
					longest = textversion;
					longID = senderID;
				};
			};
			if (currText.size >= longest.size) {
				longest = currText;
				longID = userID;
			};
			"% : keeping text from %.\n".postf(this, longID.cs);

			this.setCurr(longest ? defaultText);
			synced = true;
			this.enableSend;

		}, 1);
	}

	makeKeyDownFunc {
		keyDownSyncFunc = MFunc().add(\sendSync, { |doc, char|
			// filter other chars as well?
			// how to trigger sync when pasting?
			if (char.ascii > 0) {
				if (this.synced) {
					currText = doc.text;
					this.sendSyncText;
				}
			};
		});
		keyDownSyncFunc.disable(\sendSync);
	}

	showDoc { |force = false|
		var doctext = currText ??  "// waiting for sync...";
		if (force) { textDoc = nil };
		// textDoc !? { textDoc.close };

		if (synced.not) {  };

		if (textDoc.notNil and: { Document.findByQUuid(textDoc.quuid).notNil }) {
			// found one, turn it off, maybe even close it?
			textDoc.keyDownAction = nil;
		} {
			// "// SyncText:showDoc: no valid textDoc found, so make one.".postln;
			if (currText.isNil) { this.requestText };

			textDoc = Document(docLocalID.asString, doctext);
			textDoc.onClose_({ "textDoc closing.".postln; textDoc = nil });
			textDoc.keyDownAction = keyDownSyncFunc;

		};
		AppClock.sched(0.1, { textDoc.front });
	}

	closeDoc {
		if (textDoc.notNil and: { Document.findByQUuid(textDoc.quuid).notNil }) {
			textDoc.close;
		}
	}
}