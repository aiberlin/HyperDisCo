OSCRouterClient {

	classvar <all;
	classvar <groups, <groupNamesByPort;
	classvar <verbosity = 1;

	var <userName, <groupName, <serverAddr, <userPassword, <groupPassword, <serverPort, <onJoined;
	var <tcpRecvPort, <netAddr;
	var <responders, <responderFuncs, <privateResponderFuncs, <privateMsgReceiver;
	var <peerWatcher, <peers, <hasJoined = false;

	*initClass {
		groups = ();
		groupNamesByPort = ();
		all = Set[];
	}

	*addGroup { |name, recvPort, serverAddr|
		groupNamesByPort.put(recvPort, name);

		if (groups[name].isNil) {
			groups.put(name, (name: name, serverAddr: serverAddr));
			this.postAt(1, "% new group: % recvPort: %.\n".format(serverAddr, name.cs, recvPort));
		};
	}
	///// not finished yet
	*findBy {  |userName, groupName, serverAddr, serverPort|
		^all.select { |router|
			router.match(userName, groupName, serverAddr, serverPort)
		}.asArray
	}

	// if there is already a client with these specs,
	// use that to avoid doubled login failure and confusion.
	*new { |userName, groupName = 'oscrouter', serverAddr = "bgo.la",
		userPassword, groupPassword = 'oscrouter',
		serverPort = 55555, onJoined, dummy, extra, silly, argssss|
		var found;

		userName =  userName.asSymbol;
		groupName = groupName.asSymbol;
		userPassword = userPassword.asSymbol;
		groupPassword = groupPassword.asSymbol;
		serverAddr = serverAddr.asString;

		found = this.findBy(userName, groupName, serverAddr, serverPort);

		case { found.size > 1 } {
			"*** OSCRouterClient:new - multiple matching clients found, please be more specific!".postln;
			found.do(_.dump);
			"\n\n".postln;
			^found
		} { found.size == 1 } {
			this.postAt(1, "new - using existing client.");
			^found.unbubble
		};

		///// none found, so create it now.
		///// newCopyArgs scrambles args for some reason,
		///// so do it explicitly in init:
		this.postAt(1, "new : creating new instance.");

		^super.newCopyArgs(userName, groupName, serverAddr,
			userPassword, groupPassword,
			serverPort, onJoined).init
	}

	// post OSCRouterClient with name and group
	storeArgs { ^[userName, groupName] }
	printOn { |stream| ^this.storeOn(stream) }

	// post at debug levels:
	// 0 is quiet, 1 is normal, 2 is detailed debug
	*postAt { |level = 1, string|
		if (verbosity >= level) {
			"% : %\n".postf(this,  string);
		}
	}
	postAt { |level = 1, string|
		if (verbosity >= level) {
			"% : %\n".postf(this,  string);
		}
	}

	match { |userName, groupName, serverAddr, serverPort|
		userName !? { if (this.userName != userName) { ^false } };
		groupName !? { if (this.groupName != groupName) { ^false } };
		serverAddr !? { if (this.serverAddr != serverAddr) { ^false } };
		serverPort !? { if (this.serverPort != serverPort) { ^false } };
		^true
	}

	init {
		responders = ();
		responderFuncs = ();
		privateResponderFuncs = ();
		peers = Set();
		hasJoined = false;
		ShutDown.add({this.close});
		all.add(this);
	}

	isConnected { ^netAddr.notNil and: { netAddr.isConnected } }

	join { arg onSuccess, onFailure;
		var portResponder, randomId, registerChecker;
		randomId = 999999.rand;

		if (this.isConnected) {
			this.postAt(1,
				"--- OSCRouterClient:join - already connected."
				" To reconnect, call .close first.");
			onSuccess.value;
			^this
		};

		portResponder = {|...msg|
			if (msg[0][0].asString == ('/oscrouter/register/' ++ userName ++ '/' ++ randomId).asString, {
				tcpRecvPort = msg.last;
				this.confirmJoin;
				registerChecker.stop;
				thisProcess.removeOSCRecvFunc(portResponder);

				this.class.addGroup(groupName, tcpRecvPort, this.serverAddr);

				// make existing funcs into OSCFuncs first,
				responderFuncs.keysValuesDo ({ |id, func| this.prMakeResp(id, func)});
				// then do onJoined
				onJoined.value(this);
				// then what the join method passed in
				onSuccess.value;
			});
		};

		registerChecker = Task({
			3.wait;
			this.postAt(0, "could not connect or auth with " ++ serverAddr);
			thisProcess.removeOSCRecvFunc(portResponder);
		});

		thisProcess.addOSCRecvFunc(portResponder);
		netAddr = NetAddr(serverAddr, serverPort);
		netAddr.tryConnectTCP({
			this.isConnected.if({
				netAddr.sendMsg('/oscrouter/register', userName, userPassword, groupName, groupPassword, randomId);
				registerChecker.play;
			});
		}, {
			this.postAt(0, "Failed to connect to " ++ serverAddr);
			onFailure.value;
		});
	}

	tryToReconnect { arg msg;
		var joined = false;
		this.postAt(1, "Trying to reconnect...");
		this.close;
		fork {
			var retries = 5;
			{(joined.not).and(retries > 0)}.while {
				this.join({
					var counter=0;
					joined = true;
					// waits 3 seconds for the registering confirmed and then send again
					{(counter < 30).and(hasJoined.not)}.while({
						0.5.wait;
						counter = counter + 1;
					});

					hasJoined.if({
						// Recover all responder functions and add them again to the new
						// TCP receive port

						this.postAt(1, "Reconnect success! resending message...");
						netAddr.sendMsg(*msg);

					}, {
						this.postAt(1, "Failed to reconnect, giving up...");
					});
				});
				5.wait;
				retries = retries - 1;
			};
			joined.not.if {
				this.postAt(1, "5 attempts to reconnect failed, giving up!");
			};
		}
	}

	enablePing {
		SystemClock.sched(3.0, {
			hasJoined.if({
				this.sendMsg("/oscrouter/ping", userName);
				3.0;
			}, {
				nil;
			});
		});
	}

	cmdPeriod {
		this.enablePing;
	}

	confirmJoin {
		peerWatcher = OSCFunc({ |msg, time, senderAddr, recvPort|
			peers = msg[1..];
			groups[groupName].put(\peers, peers);
			// to move peerWatcher to class,
			// userlist message should be sending groupName, name1, name2 ...
		}, '/oscrouter/userlist', recvPort: this.tcpRecvPort);

		privateMsgReceiver = OSCFunc({ |msg|
			var sender = msg[1];
			var id = msg[2];
			this.privateResponderFuncs[id].notNil.if({
				this.privateResponderFuncs[id].value(msg[1], msg[2..])
			});
		}, '/oscrouter/private', recvPort: this.tcpRecvPort);

		this.postAt(0, "connected to % on port %".format(serverAddr, tcpRecvPort));
		hasJoined = true;
		CmdPeriod.add(this);
		this.enablePing;
	}

	close {
		var keys;
		hasJoined = false;
		this.postAt(1, "closing");
		peers.remove(userName);
		this.isConnected.if({netAddr.tryDisconnectTCP});
		keys = responders.keys;
		keys.do({arg id; this.removeResp(id)});
		responders = ();
		CmdPeriod.remove(this);
	}

	sendMsg { arg ... msg;
		// tries to send the message, if failed, tries to reconnect if for some reason
		// the connection is lost
		{netAddr.sendMsg(*msg)}.try({this.tryToReconnect(msg)})
	}

	sendPrivate { arg userName ... args;
		peers.find([userName]).notNil.if({
			this.sendMsg('/oscrouter/private', userName, *args);
		}, {
			this.postAt(1, "sendMsgToUser: unknown user %\n".format(userName.cs));
		});
	}

	sendMsgArray {arg symbol, array;
		netAddr.sendMsg(symbol, *array)
	}

	prMakeResp { |id, function|
		// prMethod, so we can assume we have joined
		this.removeResp(id);
		responders.add(id -> OSCFunc(function, id, netAddr, recvPort: tcpRecvPort).permanent_(true));
	}

	addResp { arg id, function;
		responderFuncs.put(id, function);
		if (this.hasJoined) {
			this.prMakeResp(id, function);
		}
	}

	addPrivateResp { arg id, function;
		privateResponderFuncs.add(id -> function);
	}

	removeResp {arg id;
		responders[id].free;
		responders[id] = nil;
	}

	removePrivateResp {arg id;
		responders[id] = nil;
	}
}
