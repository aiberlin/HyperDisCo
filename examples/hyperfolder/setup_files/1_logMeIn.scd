
if (q.myID == '???') {
	"*** cannot log in as  '???'!"
	"\n*** STOPPING HERE!"
	"\nplease set q.myID to your nameID first.".postln;
	this.halt
} {
	"logging in now as % \n".postf( q.myID.cs);

	// make a new OscRouterClient,
	// and log in with name and pw,
	// to default group "gencomp"
	q.oscRouter = OSCRouterClient.new(
		q.myID, q.mygroup,
		serverAddr: q.myoscserver,
		userPassword: q.mypassword,
		groupPassword: q.mygroupPassword
	);

	q.oscRouter.join({ "*** Connected to %!\n".postf(q.myoscserver) });
};
