<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.lang.Long" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="deadlineserver.*" %>
<%@ page import="deadlineserver.models.*" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.googlecode.objectify.*" %>


<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
	Objectify ofy = ObjectifyService.begin();
	Utils.registerObjectifyClasses();
	UserService userService = UserServiceFactory.getUserService();
	User user = userService.getCurrentUser();
	DUser oldUser = null;
	Subscription sub = null;
	Deadline deadline = null;

	if (user != null) {
		oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
		if(oldUser.user==null){
	    		oldUser.user=user;
	    		ofy.put(oldUser);
	    	}
	}

	String requestedDeadline = request.getRequestURI();
	if(requestedDeadline.lastIndexOf('/')==requestedDeadline.length()-1)
	{
		requestedDeadline = requestedDeadline.substring(0,requestedDeadline.lastIndexOf('/'));
	}

	requestedDeadline = requestedDeadline.substring(requestedDeadline.lastIndexOf('/')+1);

	try 
	{
		deadline = ofy.get(new Key<Deadline>(Deadline.class, Long.parseLong(requestedDeadline)));
	}
	catch (Exception e)
	{
		response.sendError(404);
		return;
	}

	sub = ofy.get(deadline.subscription);

	boolean owner=false;
	boolean loggedIn=false;

	if(oldUser!=null)
		loggedIn = true;

	if(oldUser!=null && sub.owner.getId()==oldUser.id)
		owner=true;

	if(!owner) 
	{
		response.sendError(401);
		return;
	}

	%>

	<!DOCTYPE html>
	<html>
	<head>
		<title>Deadline - Edit Deadline (<%= deadline.title %>)</title>
		<link href="/css/bootstrap.css" rel="stylesheet">
		<link rel="shortcut icon" href="/favicon.ico"/>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="apple-mobile-web-app-capable" content="yes" />
		<meta name="apple-mobile-web-app-status-bar-style" content="black" />
		<link href="/css/bootstrap-responsive.css" rel="stylesheet">
		<link href='http://fonts.googleapis.com/css?family=PT+Sans' rel='stylesheet' type='text/css'>
		<link href="/css/datepicker.css" rel="stylesheet">
		<link href="/css/timepicker.css" rel="stylesheet">
		<script src="/js/date.js"></script>
	</head>
	<body>
		<script type = "text/javascript">
			dDueDate = new Date(<%=deadline.dueDate.getTime()%>);
		</script>
		<div class="navbar navbar-inverse navbar-fixed-top visible-phone">
			<div class="navbar-inner">
				<div class="container">
					<button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>
					<a class="btn btn-small" style="float:left; padding-top:7px; padding-bottom:7px; margin-bottom:0px;" href="#" onClick="history.back(); return false;"><i class="icon-chevron-left"></i></a>
					<a class="brand" href="/"><img src="/img/logo.png" style="height:20px" /></a>
					<div class="nav-collapse collapse">
						<ul class="nav">
		                <% if(loggedIn) { %>
		                <li><a href="/">Schedule</a></li>
		                <% } else { %>
		                <li><a href="/">Home</a></li>
		                <% } %>
		                <li><a href="/profile">Courses</a></li>
		                <li><a href="/about">About</a></li>
		                <li><a href="/help">Help</a></li>
		                <% if(loggedIn) { %>
		                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
		                <% } %>
						</ul>
					</div>
				</div>
			</div>
		</div>

		<header class="jumbotron subhead hidden-phone" id="overview">
			<div class="container">
				<a href="/">
					<img src="/img/logo.png" height="50" width="225"/>
					<p class="lead">Dead simple deadline management</p>
				</a>
			</div>
		</header>

		<div class="padding-top-phone visible-phone"></div>

		<div class="container container-fluid top-margin">

			<div class="row-fluid">
				<div class="span3 hidden-phone" style="padding-top:15px;">
					<div class="nav nav-list bs-docs-sidenav">
		                <% if(loggedIn) { %>
		                <li><a href="/">Schedule</a></li>
		                <% } else { %>
		                <li><a href="/">Home</a></li>
		                <% } %>
		                <li><a href="/profile">Courses</a></li>
		                <li><a href="/about">About</a></li>
		                <li><a href="/help">Help</a></li>
		                <% if(loggedIn) { %>
		                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
		                <% } %>
					</div>
				</div>

				<div class="span9 feed-header">
							<h5>DEADLINE FOR COURSE</h5>
							<h1><%= sub.name %></h1> <h3><%= sub.id %></h3>


				<div id="new-deadline-form">
					<br />
					<div class="alert alert-error" style="display:none;">
						<button type="button" class="close" data-dismiss="alert">×</button>
						<strong>Oops.</strong> <span id="e-message"></span>
					</div>
					<div class="alert alert-success" style="display:none;">
						<button type="button" class="close" data-dismiss="alert">×</button>
						<strong>Success!</strong> <span id="s-message"></span>
					</div>

					<form class="form-horizontal" action="/savedeadline">
						
						<input type="hidden" id="deadlineId" value="<%=deadline.id%>">

						<legend>Edit deadline</legend>
						<div class="control-group">
							<label class="control-label" for="inputTitle">Title</label>
							<div class="controls">
								<input type="text" id="inputTitle" placeholder="Title" value="<%=deadline.title%>">
								<span class="deadline-help-inline">Describe the deadline as succintly as possible. Example: Homework Assignment 2.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputDate">Due Date</label>
							<div class="controls">
								<input type="datetime" id="inputDate" placeholder="Date" class="datepicker" value="">
								<span class="deadline-help-inline">DD/MM/YYYY</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputTime">Due Time</label>
							<div class="controls">
								<input type="datetime" id="inputTime" placeholder="Time" class="timepicker" value="">
								<span class="deadline-help-inline">Your computer's timezone will be used.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputDescription">Description</label>
							<div class="controls">
								<textarea rows="5" style="width:95%" id="inputDescription"><% if(deadline.description!=null) { %><%= deadline.description %><% } %></textarea>
								<span class="deadline-help-inline">This is the place you should be putting all the detail your subscribers could want.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputAttachment">Attachment</label>
							<div class="controls">
								<input type="text" id="inputAttachment" placeholder="URL" <% if(deadline.attachmentUrl!=null) { %> value="<%=deadline.attachmentUrl%>" <% } %>>
								<span class="deadline-help-inline">Enter the URL of the main reference for this deadline. This could be a PDF, a YouTube video or anything else that's relevant.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputAdditional">Additional Info</label>
							<div class="controls">
								<textarea rows="3" style="width:95%" id="inputAdditional"><% if(deadline.additionalInfo!=null) { %><%=deadline.additionalInfo%><% } %></textarea>
								<span class="deadline-help-inline">Here's where put information about penalties, weightage or expected duration.</span>
							</div>
						</div>

						<div class="control-group">
							<div class="controls">
								<button class="btn btn-inverse" id="save-deadline-button" onClick="saveDeadline()" type="button" data-loading-text="Saving...">Save deadline</button>
							</div>
						</div>
					</form>
				</div>

				<hr />



</div>

</div>
</div>
<hr />
<footer class="container">
	<p>Built by Raghav Sethi, Mayank Pundir and Naved Alam at <a href="http://www.iiitd.ac.in">IIIT-D</a>. Some rights reserved.</p>
</footer>
<script src="/js/jquery.js"></script>
<script src="/js/bootstrap.js"></script>
<script src="/js/retina.js"></script>
<script src="/js/bootstrap-datepicker.js"></script>
<script src="/js/bootstrap-timepicker.js"></script>

<script type="text/javascript">

tdate = "" + dDueDate.getDate();
tdate = (tdate.length==1)?"0"+tdate:tdate;
tdate = tdate + "/" + (dDueDate.getMonth()+1) + "/" + dDueDate.getFullYear();

$('#inputDate').val(tdate);

h=dDueDate.getHours();
c=(h>12)?1:0
h=h%12
m=dDueDate.getMinutes();
t=(c==1)?'PM':'AM'
m=""+m
h=""+h
m = (m.length==1)?'0'+m:m
h = (h.length==1)?'0'+h:h
$('#inputTime').val(h+":"+m+" "+t);

$('.expand-link').click(function(e) {

	var clicked = $(this);
	var toExpand = clicked.attr("data-expand");

	if($('#'+toExpand).is(':hidden'))
		$('#'+toExpand).slideDown(200);
	else
		$('#'+toExpand).slideUp(200);

	return false;

});

$( ".datepicker" ).datepicker({'format':'dd/mm/yyyy'});
$( ".timepicker" ).timepicker({'defaultTime':'value', 'minuteStep':10, 'showMeridian':false});

$('#create-deadline-button').click(function(e) {

	if($('#create-deadline-button').text()=="Create new deadline") {
		$('#new-deadline-form').fadeIn();
		$('#create-deadline-button').text("Hide");
	}
	else {
		$('#new-deadline-form').fadeOut();
		$('#create-deadline-button').text("Create new deadline");
	}

	return false;	
});

$('.edit-link').click( function(e) {

	var clicked = $(this);
	window.location = clicked.attr('href');
	return true;

});

var saveDeadline = function(e) {
	$('.alert').hide();
	$('#save-deadline-button').button('loading');

	var timeStr = $('#inputTime').val();
	var dateParts = $('#inputDate').val().match(/(\d+)/g);
	var timeParts = timeStr.match(/(\d+)/g);

	var hrs = (timeStr.indexOf("PM")>-1) ? parseInt(timeParts[0])+12 : parseInt(timeParts[0]);

	// new Date(year, month [, date [, hours[, minutes[, seconds[, ms]]]]])
	var d = new Date(dateParts[2], dateParts[1]-1, dateParts[0], hrs, timeParts[1]);

	$.post('/savedeadline', {'id':0, 'date':d.getTime(), 'title':$('#inputTitle').val(), 'subscription-id':'<%=sub.id%>', 
		'description':$('#inputDescription').val(), 'attachment-url':$('#inputAttachment').val(), 'additional-info':$('#inputAdditional').val(), 'deadline-id':$('#deadlineId').val()}, function(data) {
			if(data.success)
			{
				$('#s-message').text(data.message);
				$('.alert-success').show();
				setTimeout("window.location='/feed/<%=sub.id%>';", 2000);
			}
			else
			{
				$('#e-message').text(data.message);
				$('.alert-error').show();
				$('#save-feed-button').button('reset')
			}
		});
	return false;
}

var qs = (function(a) {
	if (a == "") return {};
	var b = {};
	for (var i = 0; i < a.length; ++i)
	{
		var p=a[i].split('=');
		if (p.length != 2) continue;
		b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
	}
	return b;
})(window.location.search.substr(1).split('&'));

if(qs["newfeed"])
{
	$('#newfeed').slideDown();
}

</script>
</body>
</html>