SyncText {
	classvar <defaultText = "/* sync text via network */\n";
	classvar <all;
	classvar <logDir;

	var <textID, <relayAddr, <userID, <docLocalID;
	var <currText, <lastSent, <lastReceived, <incomingVersions;
	var <textDoc, <>synced = false, <keyDownSyncFunc, <locked = false;
	var <prevText;

	// while Document has no full unicode support,
	/// replace all non-ascii chars in place here:
	*fixString { |string, replaceChar = $_|
		var badCount = 0;
		// fix in-place:
		string.do { |char, i|
			if (char.ascii < 0) {
				string[i] = replaceChar;
				badCount = badCount + 1;
			}
		};
		// return flag if any chars were changed
		^badCount > 0;
	}

	*initClass {
		all = ();
		logDir = Platform.userAppSupportDir +/+ "SyncText_logs/";
		if (logDir.pathMatch.isEmpty) { File.mkdir(logDir) };
	}

	*new { |textID = \syncText, userID, relayAddr|
		var userName = try { relayAddr.userName };
		var id = (userName ?? userID ?? { "whoami".unixCmdGetStdOut.drop(-1) }).asSymbol;
		var docLocalID = textID;
		if (id.notNil) {
			docLocalID = (textID ++ '_' ++ id).asSymbol;
			if (all[docLocalID].notNil) {
				^all[docLocalID]
			}
		};
		// "// making new SyncText".postln;
		^super.newCopyArgs(textID, relayAddr, id, docLocalID).init
	}

	storeArgs { ^[textID] }
	printOn { |stream| ^this.storeOn(stream) }

	init {
		incomingVersions = ();
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

	lock { locked = true; textDoc !? { textDoc.editable = locked.not } }
	unlock { locked = false; textDoc !? { textDoc.editable = locked.not } }

	syncTo { |name|
		var newText = incomingVersions[name];
		if (newText.isNil) {
			"SyncText: no incoming text for %!\n".postf(name.cs);
		} {
			this.setCurr(newText)
		}
	}

	setCurr { |newText|
		textDoc !? { this.setDocText(newText) };
		currText = newText;
	}

	setDocText { |newText|
		thisMethod.postln;
		textDoc.text = newText;

		if (currText.notNil) {
			// get current text selectedRange,
			var currStart = textDoc.selectionStart;
			var currSelSize = textDoc.selectionSize;
			var sizeDiff = newText.size - currText.size;
			// find out whether change was before or after local selectionStart:
			var currTextStart = currText.copyFromStart(currStart - 1);
			var newTextStart  =  newText.copyFromStart(currStart - 1);
			// if after, just reset, if before, shift by length change
			if (currTextStart == newTextStart) {
				// change is after selectionStart, selection can stay
			} {
				// shift by tex length difference
				currStart = currStart + sizeDiff;
			};

			// and restore it after text update
			textDoc.selectRange(currStart, currSelSize);
		}
	}

	makeOSCFuncs {

		relayAddr.addResp(\syncText, { |msg|
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
		});

		// requestedText comes private only to avoid flooding elsewhere
		relayAddr.addPrivateResp(\syncText, { |senderID, msg|
			var inTextID = msg[1];
			var newText = msg[3].asString;
			"% : received private sync msg %\n".postf(this, msg.cs);
			lastReceived = newText;
			incomingVersions.put(senderID, newText);
		});


		relayAddr.addResp(\syncTextRequest, {|msg|
			var inTextID = msg[1];
			var senderID = msg[2];
			if (inTextID == textID) {
				case { synced.not } {
					"%: not sending text % when not synced.\n".postf(this, textID.cs);
				} { currText.isNil } {
					"%: not sending text % when currText is nil.\n".postf(this, textID.cs);
				} {
					"%: sending requested text % only to %\n".postf(this, textID.cs, senderID.cs);
					this.sendSyncText(senderID);
				};
			};
		});
	}

	sendSyncText { |otherName|
		var textSize = currText.size;
		if (textSize > 65000) {
			"% : currText size % too big for sending!\n".postf(this, textSize);
			^false
		};
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
		keyDownSyncFunc = keyDownSyncFunc ?? { MFunc() };

		keyDownSyncFunc.add(\sendSync, { |doc, char, mods, unicode, keycode, key|
			var newText = doc.string;
			var textChanged = (newText == prevText).not;
			var wasFixed;

			// [doc, char, mods, unicode, keycode, key].postcs;

			if (textChanged) {
				// "textChanged".postln;
				// while Document has no full unicode support, replace non-asciis:
				wasFixed = SyncText.fixString(newText);
				if (wasFixed) {
					"fixed text, resetting textDoc.".postln;
					doc.text = newText;
				};
				if (this.synced) {
					currText = newText;
					//	"send newText".postln;
					this.sendSyncText;
				};
				prevText = newText;
			};
		});

		keyDownSyncFunc.disable(\sendSync);
	}

	showDoc { |force = false|
		var doctext = currText ??  "// waiting for sync...";
		if (force) { textDoc = nil };


		if (synced.not) {  };

		if (textDoc.notNil and: { Document.findByQUuid(textDoc.quuid).notNil }) {
			// found one, turn it off, maybe even close it?
			textDoc.keyDownAction = nil;
		} {
			// "// SyncText:showDoc: no valid textDoc found, so make one.".postln;
			if (currText.isNil) { this.requestText };

			textDoc = Document(docLocalID.asString, doctext);
			textDoc.onClose_({ |doc|
				"textDoc closing.".postln;
				if (doc === textDoc) { textDoc = nil } });
			textDoc.keyDownAction = keyDownSyncFunc;

		};
		AppClock.sched(0.1, {
			textDoc.front;
			this.saveAndCloseOldDocs;
		});
	}

	*writeLog { |doc, id, ext = ".scd"|
		var filename = Date.getDate.stamp;
		var doctitle = doc.title;
		if (id.notNil) { filename = filename ++ "_%_".format(id) };
		if (doctitle.endsWith(ext).not) { doctitle = doctitle ++ ext };
		filename = filename ++ doctitle;
		File.use(logDir +/+ filename, "w", { |f| f.write(doc.text).close });
	}

	saveAndCloseOldDocs {
		var oldDocs = Document.allDocuments.select { |doc|
			doc != textDoc and: { doc.title.contains(docLocalID.asString) }
		};
		oldDocs.do { |doc, i|
			var id;
			if (oldDocs.size > 1) { id = i + 1 };
			try {
				SyncText.writeLog(doc, id);
				doc.close
			}
		}
	}

	closeDoc {
		if (textDoc.notNil and: { Document.findByQUuid(textDoc.quuid).notNil }) {
			textDoc.close;
		}
	}
}
