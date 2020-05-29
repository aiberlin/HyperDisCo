
OSCRouterClient {

	classvar <all;
	classvar <groups, <groupNamesByPort;

	var <serverAddr, <userName, <userPassword, <onJoined, <groupName, <groupPassword, <serverport;
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
			"% new group: % recvPort: %.\n".postf(name.cs, recvPort, serverAddr);
			groups.put(name, (name: name, serverAddr: serverAddr))
		};
	}

	// if there is already a client with these specs,
	// use that to avoid doubled login failure and confusion.
	*new { arg serverAddr, userName, userPassword, onJoined,
		groupName, groupPassword, serverport = 55555;

		var found;
		groupName = groupName ? 'oscrouter';
		groupPassword = groupPassword ? 'oscrouter';
		found = this.findBy(userName, groupName, serverAddr, serverport);

		case { found.size > 1 } {
			"*** OSCRouterClient:new - multiple matching clients found, please be more specific!".postln;
			found.do(_.dump);
			^found
		} { found.size == 1 } {
			"OSCRouterClient:new - using existing client with these params.".postln;
			^found.unbubble
		};
		///// none found, so create it now:
		^super.newCopyArgs(serverAddr, userName, userPassword, onJoined, groupName, groupPassword, serverport).init;
	}

	match { |userName, groupName, serverAddr, serverport|
		userName !? { if (this.userName != userName) { ^false } };
		groupName !? { if (this.groupName != groupName) { ^false } };
		serverAddr !? { if (this.serverAddr != serverAddr) { ^false } };
		serverport !? { if (this.serverport != serverport) { ^false } };
		^true
	}

	///// not finished yet
	*findBy {  |userName, groupName, serverAddr, serverport|
		^all.select { |router|
			router.match(userName, groupName, serverAddr, serverport)
		}.asArray
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
			// "OSCRouterClient: already connected. To reconnect, call .close first.".postln;
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
			("Can't connect or auth with " ++ serverAddr).postln;
			thisProcess.removeOSCRecvFunc(portResponder);
		});

		thisProcess.addOSCRecvFunc(portResponder);
		netAddr = NetAddr(serverAddr, serverport);
		netAddr.tryConnectTCP({
			this.isConnected.if({
				netAddr.sendMsg('/oscrouter/register', userName, userPassword, groupName, groupPassword, randomId);
				registerChecker.play;
				//// move to after hasJoined, onJoined,value
				// onSuccess.notNil.if({onSuccess.value});
			});
		}, {
			("Failed to connect to " ++ serverAddr).postln;
			onFailure.value;
		});
	}

	tryToReconnect { arg msg;
		var joined = false;
		"Trying to reconnect...".postln;
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

						"Reconnect success! resending message...".postln;
						netAddr.sendMsg(*msg);

					}, {
						"Failed to reconnect, giving up...".postln;
					});
				});
				5.wait;
				retries = retries - 1;
			};
			joined.not.if { "5 attempts to reconnect failed, giving up!" };
		};
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

		("Connected to " ++ serverAddr).postln;
		("    receiving on port " ++ tcpRecvPort).postln;
		hasJoined = true;
		CmdPeriod.add(this);
		this.enablePing;
	}

	close {
		var keys;
		hasJoined = false;
		"closing".postln;
		peers.remove(userName);
		netAddr.isConnected.if({netAddr.tryDisconnectTCP});
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
			"sendMsgToUser: unknown user %\n".postf(userName.cs);
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
