HyperDisCo {
	var <userName;
	var <groupName;
	var <groupPassword;
	var <userPassword;
	var <serverHost;
	var <serverPort;

	var <>client;
	var <>syncText;
	var <>document;


	*new {|userName, groupName, groupPassword="oscrouter", userPassword="hello", serverHost="bgo.la", serverPort=55555|
		^super.newCopyArgs(
			userName,
			groupName,
			groupPassword,
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

	}


}