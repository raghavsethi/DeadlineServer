Deadline Server
===============

Server for the Deadline course notification system. Built by Raghav Sethi, Mayank Pundir and Naved Alam at IIIT-D.

API Notes
----------
1. POST /api/subscribe - id, [regId]
2. POST /api/unsubscribe - id, [regId]
3. GET  /api/deadlines - [regId]

regId is used by mobile users only

API Results
-----------
For /api/deadlines returned JSON is of this format:

{
	'subscriptions' : [
		{'hci' : 'Human Computer Interaction'},
		{'aa' : 'Advanced Algorithms'}
	]

	'deadlines' : [
		{'date':1234671294, 'title':'ABC', 'description':'Very important deadline', 'course':'hci'},
		{'date':1234671294, 'title':'DEF', 'description':'Another important deadline', 'course':'aa'},
	]
}