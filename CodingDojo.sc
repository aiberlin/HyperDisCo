CodingDojo {
	var username, password, serveraddress, serverport;
	var <oscrouter, <syncText, <>turnTime = 300, <remainTime, timerTask, <pilot;
	var <copilot, <nextCopilot, <myStatus, <order;
	var <win, <uv;

	*new {arg username, password, serveraddress = "bgo.la", serverport = 55555;
		^super.newCopyArgs(username.asSymbol, password.asSymbol, serveraddress.asString, serverport).init;
	}

	init {
		oscrouter = OSCRouterClient(serveraddress, username, password,
			serverport: serverport, onJoined: {|oscrouter|
				syncText = SyncText('CodingDojoSession', username, oscrouter);
				syncText.showDoc;

				remainTime = turnTime; // Defaults to 5 minutes
				timerTask = Task({
					{ remainTime > 0 }.while {
						remainTime = remainTime - 1;
						1.wait;
					};
				});

				this.addOSCFuncs;
				this.enableCodeSending;
				pilot = '';
				copilot = '';
				nextCopilot = '';
				order = [];
				AppClock.sched(0, {this.setupUserView});
		});
		myStatus = \audience;
		oscrouter.join;
	}

	setupUserView {
		win = Window.new("CodingDojo_" ++ username, Rect(0,0, 200, 150), false, false);
		uv = UserView.new(win, Rect(0,0,200,150));
		win.alwaysOnTop = true;
		win.alpha_(0.7);
		uv.background = Color.red;
		uv.animate = true;
		uv.drawFunc = { |uv|
			var timerColor;
			Pen.stringLeftJustIn(
				" " ++ pilot ++ "\n " ++ copilot ++ "\n " ++ nextCopilot,
				uv.bounds,
				Font("Futura", 18),
				Color.black
			);
			(remainTime < 20).if {
				(remainTime % 2 == 0).if {
					timerColor = Color.white;
				} {
					timerColor = Color.black;
				};
			};
			Pen.stringRightJustIn(
				remainTime.asTimeString.drop(3).drop(-4),
				uv.bounds,
				Font("Futura", 36),
				timerColor
			);
		};
		win.front;
		uv.front;
	}

	disableCodeSending {
		MFdef('historyForward').disable('run_code_dojo');
	}

	enableCodeSending {
		History.start;
		MFdef('historyForward').add('run_code_dojo', { |code, result|
			// Only send the code if we are currenlty in this CodingDojo document.
			(Document.current.quuid == syncText.textDoc.quuid
				and: {syncText.textDoc.quuid.notNil}
			).if {
				"send code to run everywhere ...".postln;
				oscrouter.sendMsg('/codingdojo/run_code', username, code);
			};
		});

		MFdef('historyForward').enable('run_code_dojo');

		History.forwardFunc = MFdef('historyForward');
	}

	removeOSCFuncs {
		oscrouter.removeResp('/codingdojo/run_code');
		oscrouter.removeResp('/codingdojo/change_turn');
	}

	addOSCFuncs {
		// receive and evaluate code
		oscrouter.addResp('/codingdojo/run_code', { |msg|
			var who = msg.postcs[1].asString;
			var code = msg[2].asString;

			var isSafe = {
				// code from OpenObject avoidTheWorst method
				code.find("unixCmd").isNil
				and: { code.find("systemCmd").isNil }
				and: { code.find("File").isNil }
				and: { code.find("Pipe").isNil }
				and: { code.find("Public").isNil }
			}.value;

			isSafe.if {
				// defer it so GUI code also always runs
				defer {
					try {
						"coding dojo: interpreting code ...".postln;
						code.interpret
					} {
						(
							"*** coding dojo - code interpret failed:".postln;
							code.cs.keep(100).postln;
						).postln
					}
				}
			} {
				"*** coding dojo: unsafe code detected:".postln;
				code.postcs;
			}
		});

		oscrouter.addResp('/codingdojo/new_turn', { |msg|
			this.newTurn(msg[1].asSymbol, msg[2].asSymbol, msg[3].asSymbol);
		});
	}

	startTimer {
		timerTask.play(doReset: true);
	}

	rotate {
		var nextIdx = (order.find([nextCopilot]) + 1) % order.size;
		var next = order[nextIdx];
		this.startNewTurn(copilot, nextCopilot, next);

	}

	startSession {
		arg participants_order;
		order = participants_order;
		this.startNewTurn(order.wrapAt(0), order.wrapAt(1), order.wrapAt(2));
	}

	startNewTurn {
		arg pilot, copilot, next;
		oscrouter.sendMsg('/codingdojo/new_turn', pilot.asSymbol, copilot.asSymbol, next.asSymbol);
		this.newTurn(pilot, copilot, next);
	}

	newTurn {
		arg newPilot, newCopilot, newNext;
		pilot = newPilot;
		copilot = newCopilot;
		nextCopilot = newNext;
		this.updateTurn;
		this.resetTimer;
	}

	resetTimer {
		remainTime = 5*60;
		this.startTimer;

	}

	updateTurn {
		(pilot == username).if {
			myStatus = \pilot;
		} {
			(copilot == username).if {
				myStatus = \copilot;
			} {
				myStatus = \audience;
			}
		};

		((myStatus == \pilot) or: { myStatus == \copilot}).if {
			syncText.enableSend;
			syncText.unlock;
		} {
			syncText.disableSend;
			syncText.lock;
		}
	}

}