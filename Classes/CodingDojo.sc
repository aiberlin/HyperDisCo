CodingDojo {
	var <userName, <userPassword, <serverAddr, <serverPort;

	var <oscrouter, <syncText;
	var <>turnTime = 300, <remainTime, <timer;
	var <order, <pilot, <copilot, <nextCopilot, <myStatus;
	var <win, <uv;

	*new { arg userName, groupName = \codingDojo, serverAddr = "bgo.la",
		userPassword, groupPassword = \codingDojo, serverPort = 55555;

		^super.newCopyArgs(
			userName.asSymbol, userPassword.asSymbol,
			serverAddr.asString, serverPort
		)
		.init(groupName.asSymbol, groupPassword.asSymbol);
	}

	init { |groupName, groupPassword|
		this.initTimer;
		this.initRoles;

		oscrouter = OSCRouterClient(userName, groupName, serverAddr,
			userPassword, groupPassword, serverPort);
		this.join;
	}

	join { oscrouter.join({ this.initOnJoined }); }

	groupName { ^oscrouter.groupName }

	groupPassword { ^oscrouter.groupPassword }

	initRoles {
		pilot = '';
		copilot = '';
		nextCopilot = '';
		order = [''];
		myStatus = \audience;
	}

	initTimer {
		remainTime = turnTime; // Defaults to 5 minutes
		timer = SkipJack({
			remainTime = remainTime - 1;
		},
		1, { remainTime <= 0 }, 'CodingDojo').stop;
	}

	initOnJoined {
		defer {
			syncText = SyncText('CodingDojoSession', userName, oscrouter);
			syncText.showDoc(true);
			this.addOSCFuncs;
			this.enableCodeSending;
			this.showTimer;
		}
	}

	showTimer {
		if (win.notNil) { try { win.close } };
		win = Window.new("CodingDojo_" ++ userName, Rect(0,0, 200, 150), false, false);
		win.front;
		win.alwaysOnTop = true;
		win.alpha_(0.7);

		uv = UserView.new(win, Rect(0,0,200,150));
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
	}

	disableCodeSending {
		MFdef('historyForward').disable('run_code_dojo');
	}

	enableCodeSending {
		History.start;
		MFdef('historyForward').add('run_code_dojo', { |code, result|
			// Only send the code if we are currenlty in this CodingDojo document.
			(Document.current === syncText.textDoc
				and: {syncText.textDoc.quuid.notNil}
			).if {
				"send code to run everywhere ...".postln;
				oscrouter.sendMsg('/codingdojo/run_code', userName, code);
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
			var who = msg[1].asString;
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
		timer.play
	}

	stopTimer {
		timer.stop
	}

	resetTimer {
		remainTime = turnTime;
		this.startTimer;
	}

	rotate {
		var nextIdx = (order.find([nextCopilot]) + 1) % order.size;
		var next = order[nextIdx];
		this.startNewTurn(copilot, nextCopilot, next);

	}

	startSession { arg participants_order;
		order = participants_order ? oscrouter.peers;
		this.startNewTurn(order.wrapAt(0), order.wrapAt(1), order.wrapAt(2));
	}

	startNewTurn { arg pilot, copilot, next;
		oscrouter.sendMsg('/codingdojo/new_turn', pilot.asSymbol, copilot.asSymbol, next.asSymbol);
		this.newTurn(pilot, copilot, next);
	}

	newTurn { arg newPilot, newCopilot, newNext;
		pilot = newPilot;
		copilot = newCopilot;
		nextCopilot = newNext;
		this.updateTurn;
		this.resetTimer;
	}

	updateTurn {
		(pilot == userName).if {
			myStatus = \pilot;
		} {
			(copilot == userName).if {
				myStatus = \copilot;
			} {
				myStatus = \audience;
			}
		};

		((myStatus == \pilot) or: { myStatus == \copilot}).if {
			this.enableCodeSending;
			syncText.enableSend;
			syncText.unlock;
		} {
			this.disableCodeSending;
			syncText.disableSend;
			syncText.lock;
		}
	}

	leave {
		this.stopTimer;
		oscrouter.close;
		syncText.closeDoc;
		try { win.close };
	}

}
