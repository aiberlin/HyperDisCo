HyperDisCo {
	var <groupName;
	var <groupPassword;
	var <userName;
	var <userPassword;
	var <serverHost;
	var <serverPort;

	var <client;
	var <syncText;


	*new {|groupName, groupPassword="oscrouter", userName, userPassword="hello", serverHost="bgo.la", serverPort=55555|
		if(userName.isNil, {
			userName = "User%".format(1000.rand);
			"No username provided, using out auto-generated name %".format(userName).postln;
		});

		if(groupName.isNil, {
			groupName = "Group%".format(10000.rand);
			"No group name provided, using auto-generated group name %".format(groupName).postln;
		});

		"Share the following command to let other users join your session\n#####\nHyperDisCo(groupName: \"%\", groupPassword: \"%\", serverHost: \"%\", serverPort: %)\n#####".format(groupName, groupPassword, serverHost, serverPort).postln;

		^super.newCopyArgs(
			groupName,
			groupPassword,
			userName,
			userPassword,
			serverHost,
			serverPort,
		).init;
	}

	init {
		client = OSCRouterClient(
			userName: userName.asSymbol,
			groupName: groupName.asSymbol,
			userPassword: userPassword.asSymbol,
			groupPassword: groupPassword.asSymbol,
			serverAddr: serverHost,
			serverPort: serverPort,
		).join;

		syncText = SyncText(
			textID: groupName.asSymbol,
			userID: client.userName,
			relayAddr: client
		).showDoc;
	}

	close {
		// todo
	}


}