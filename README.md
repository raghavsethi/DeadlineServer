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
	"subscriptions" : [
		{"id":"hci", "name":"Human Computer Interaction"},
		{"id":"aa", "name":"Advanced Algorithms"}
	]

	"deadlines" : [
		{"id":"1","title":"Assignment 1","subscription":"Introduction to Programming","updated":false,"description":"","attachmentUrl":null,"additionalInfo":null,"dueDate":"Wed Jan 30 16:30:00 UTC 2013"}
	]
}