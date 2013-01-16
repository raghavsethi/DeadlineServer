<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
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

	if (user != null) {
        try
        {
            oldUser = ofy.get(DUser.class,user.getEmail());
        }
        catch(Exception e)
        {
            response.sendRedirect("/login");
        }
    }

	String requestedFeed = request.getRequestURI();
	if(requestedFeed.lastIndexOf('/')==requestedFeed.length()-1)
	{
		requestedFeed = requestedFeed.substring(0,requestedFeed.lastIndexOf('/'));
	}

	requestedFeed = requestedFeed.substring(requestedFeed.lastIndexOf('/')+1);

	try 
	{
		sub = ofy.get(new Key<Subscription>(Subscription.class, requestedFeed));
	}
	catch (Exception e)
	{
		response.sendError(404);
		return;
	}

	Query<Deadline> q = ofy.query(Deadline.class).filter("subscription", new Key<Subscription>(Subscription.class, sub.id)).filter("dueDate >", new Date()).order("dueDate");
	Query<Deadline> qExpired = ofy.query(Deadline.class).filter("subscription", new Key<Subscription>(Subscription.class, sub.id)).filter("dueDate <", new Date()).order("-dueDate");



	boolean owner=false;
	boolean loggedIn=false;
	boolean subscriber=false;

	if(oldUser!=null)
		loggedIn = true;

	if(oldUser!=null && sub.owner.getName().equals(oldUser.email))
		owner = true;

	if(oldUser!=null) {
		for(int i=0; i<oldUser.subscriptions.size(); i++)
		{
			if(oldUser.subscriptions.get(i).getName().equals(sub.id))
			{
				subscriber=true;
				break;
			}
		}
	}

	String newUserSubscribeUrl = UserServiceFactory.getUserService().createLoginURL("/subscribe?subscription-id="+sub.id);

	%>

	<!DOCTYPE html>
	<html>
	<head>
		<title>Deadline - <%= sub.name %></title>
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
		<script type="text/javascript" src="https://www.google.com/jsapi"></script>
	</head>
	<body>

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

				<div class="span9">
					<div class="row-fluid">
						<div class="span9 feed-header">

							<div class="alert alert-success" style="display:none;" id="newfeed">
								<button type="button" class="close" data-dismiss="alert">×</button>
								<p style="font-size:18px; font-weight:bold;">You successfully created a new course!</p>
								Your students can subscribe using this course id: <strong><%= sub.id %></strong>
							</div>

							<div class="alert alert-success" style="display:none;" id="success-message">
								<button type="button" class="close" data-dismiss="alert">×</button>
								<strong>Success!</strong> <span id="s-message"></span>
							</div>

							<div class="alert alert-error" style="display:none;" id="error-message">
							  <button type="button" class="close" data-dismiss="alert">×</button>
							  <strong>Oops.</strong> <span id="e-message"></span>
							</div>


							<h5>COURSE</h5>
							<h1><%= sub.name %></h1> <h3><%= sub.id %></h3> <h3 class="num-subscribers"><%= sub.numSubscribers %> subscribers</h3>

						</div>
						<div class="span3 feed-header" style="margin-left:0px; margin-top:25px;" id="feed-menu">
						<% if(owner) { %>
						<a class="btn btn-info" href="#" id="create-deadline-button">Create new deadline</a>
						<% } %>
						<% if(subscriber) { %>
						<a class="btn btn-danger" href="#" id="unsubscribe-button">Unsubscribe</a>
						<% } %>
						<% if(!subscriber && loggedIn) { %>
						<a class="btn btn-primary" href="#" id="subscribe-button">Subscribe</a>
						<% } %>
						<!--
						<a class="btn" href="https://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=http://deadlineapp.appspot.com/feed/<%=sub.id%>" target="_blank">View full-size QR code <i class="icon-qrcode"></i></a>
						-->
						<% if(!loggedIn) { %>
						<a class="btn btn-danger" href="<%=newUserSubscribeUrl%>" id="subscribe-button">Subscribe</a>
						<% } %>

					</div>
				</div>

				<div id="new-deadline-form" style="display:none;">
					<br />
					<div class="alert alert-error" style="display:none;" id="create-error">
						<button type="button" class="close" data-dismiss="alert">×</button>
						<strong>Oops.</strong> <span id="e-message"></span>
					</div>
					<div class="alert alert-success" style="display:none;" id="create-success">
						<button type="button" class="close" data-dismiss="alert">×</button>
						<strong>Success!</strong> <span id="s-message"></span>
					</div>

					<form class="form-horizontal" action="/savedeadline">
						<legend>Create new deadline</legend>
						<div class="control-group">
							<label class="control-label" for="inputTitle">Title</label>
							<div class="controls">
								<input type="text" id="inputTitle" placeholder="Title">
								<span class="deadline-help-inline">Describe the deadline as succintly as possible. Example: Homework Assignment 2.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputDate">Due Date</label>
							<div class="controls">
								<input type="text" id="inputDate" placeholder="Date" class="datepicker">
								<span class="deadline-help-inline">DD/MM/YYYY</span>
							</div>
						</div>

						<div class="control-group">
							<label class="control-label">Scheduling Assistance</label>
							<div class="controls">
								<a class="btn btn-primary showchart-help" href="#" id="showchart-button" style="width:190px;">Show class workload</a>&nbsp;&nbsp;<span class="deadline-help-inline showchart-help">We recommend you take a look<br /></span>
								<div id="scheduling-chart" style="width:100%"></div>
								<span class="deadline-help-inline" id="showchart-help" style="display:none;">This chart shows you how many students in your class have other deadlines on a given day (including deadlines in this course). Hover over a bar to see more details. A good time to schedule a new deadline is when most of your class is relatively unburdened.<br /><br />Note: A deadline at 00:00 on the 6th of September will appear as a deadline due on the 5th of September (because your students will be busy with this deadline on the 5th, rather than the 6th).</span>
							</div>
						</div>

						<div class="control-group">
							<label class="control-label" for="inputTime">Due Time</label>
							<div class="controls">
								<input type="text" id="inputTime" placeholder="Time" class="timepicker">
								<span class="deadline-help-inline">Your computer's timezone will be used</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputDescription">Description</label>
							<div class="controls">
								<textarea rows="5" style="width:95%" id="inputDescription"></textarea>
								<span class="deadline-help-inline">This is the place you should be putting all the detail your subscribers could want.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputAttachment">Attachment</label>
							<div class="controls">
								<input type="text" id="inputAttachment" placeholder="URL">
								<span class="deadline-help-inline">Enter the URL of the main reference for this deadline. This could be a PDF, a YouTube video or anything else that's relevant.</span>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="inputAdditional">Additional Info</label>
							<div class="controls">
								<textarea rows="3" style="width:95%" id="inputAdditional"></textarea>
								<span class="deadline-help-inline">Here's where put information about penalties, weightage or expected duration.</span>
							</div>
						</div>

						<div class="control-group">
							<div class="controls">
								<button class="btn btn-inverse" id="save-deadline-button" onClick="saveDeadline()" type="button" data-loading-text="Saving...">Create new deadline</button>
								<span class="deadline-help-inline">Clicking this button will cause an email with the deadline information to be sent to your course group, and push notifications to be sent to subscribers with Android devices.</span>
							</div>
						</div>
					</form>
				</div>

				<hr />

				<h4>Upcoming deadlines</h4>

				<%
				if(q.count()==0) {
				%>
					<p>No upcoming deadlines</p>

				<%
				}
				for(Deadline d:q)
				{
				%>

				<div class="deadline">
					<a href="#" class="expand-link deadlineview" data-expand="<%=d.id%>-more-info">
					<table>
						<tr>
							<td width="100%">
								
								<h3><script type="text/javascript">document.write(printLocalDate(<%=d.dueDate.getTime()%>));</script></h3>
								<h4><script type="text/javascript">document.write(printLocalTime(<%=d.dueDate.getTime()%>));</script></h4>
								<br />
								<% if(owner) { %>

								<a class="btn btn-inverse btn-small edit-link" style="margin-top:-3px; color:#fff" href="/deadline/<%=d.id%>">edit <i class="icon-pencil icon-white"></i></a>

								<% } %>
								<h2><%=d.title%></h2>
								
							</td>

							<td width="16">
								<div class="expandicon"><i class="icon-chevron-down"></i></div>
							</td>
						</tr>
					</table>
					</a>

					<div style="display:none;" class="more-info" id="<%=d.id%>-more-info">
						<% if (d.description==null || d.description=="") { %>
						<p><strong>Description </strong>None provided.</p>
						<% } else { %>
						<p><strong>Description </strong><%=d.description%></p>
						<% } %>

						<% if (d.attachmentUrl!=null && d.attachmentUrl!="") { %>
						<strong>Attachment </strong>
						<a href = "<%= d.attachmentUrl %>">click here</a>
						<% } %>
						
						<% if (d.additionalInfo==null || d.additionalInfo=="") { %>
						<p><strong>Additional Information </strong>None provided.</p>
						<% } else { %>
						<p><strong>Additional Information </strong><%=d.additionalInfo%></p>
						<% } %>
					</div>

				</div>

				<% } %>

				<!-- Expired deadlines -->
				<br />
				<h4>Expired deadlines</h4>
				<%
				if(q.count()==0) {
				%>
					<p>No expired deadlines</p>

				<%
				}
				for(Deadline d:qExpired)
				{
				%>

				<div class="deadline passed">
					<a href="#" class="expand-link deadlineview" data-expand="<%=d.id%>-more-info">
					<table>
						<tr>
							<td width="100%">
								
								<h3><script type="text/javascript">document.write(printLocalDate(<%=d.dueDate.getTime()%>));</script></h3>
								<h4><script type="text/javascript">document.write(printLocalTime(<%=d.dueDate.getTime()%>));</script></h4>
								<br />
								<% if(owner) { %>

								<a class="btn btn-inverse btn-small edit-link" style="margin-top:-3px; color:#fff" href="/deadline/<%=d.id%>">edit <i class="icon-pencil icon-white"></i></a>

								<% } %>
								<h2><%=d.title%></h2>
								
							</td>

							<td width="16">
								<div class="expandicon"><i class="icon-chevron-down"></i></div>
							</td>
						</tr>
					</table>
					</a>

					<div style="display:none;" class="more-info" id="<%=d.id%>-more-info">
						<% if (d.description==null || d.description=="") { %>
						<p><strong>Description </strong>None provided.</p>
						<% } else { %>
						<p><strong>Description </strong><%=d.description%></p>
						<% } %>

						<% if (d.attachmentUrl!=null && d.attachmentUrl!="") { %>
						<strong>Attachment </strong>
						<a href = "<%= d.attachmentUrl %>">click here</a>
						<% } %>
						
						<% if (d.additionalInfo==null || d.additionalInfo=="") { %>
						<p><strong>Additional Information </strong>None provided.</p>
						<% } else { %>
						<p><strong>Additional Information </strong><%=d.additionalInfo%></p>
						<% } %>
					</div>

				</div>

				<% } %>

			</div>
		</div>
	</div>
	<hr />
	<footer class="container">
		<p>Built by Raghav Sethi, Mayank Pundir and Naved Alam at <a href="http://www.iiitd.ac.in">IIIT-D</a>. Some rights reserved.</p>
	</footer>
</body>

<script src="/js/jquery.js"></script>
<script src="/js/bootstrap.js"></script>
<script src="/js/retina.js"></script>
<script src="/js/bootstrap-datepicker.js"></script>
<script src="/js/bootstrap-timepicker.js"></script>

<script type="text/javascript">
	var unsubscribePost = function () {

		$('.alert').slideUp();

		var clicked = $(this);

		$.post("/api/unsubscribe", {"id":"<%= sub.id %>"}, function(data) {
			if(data.success)
	        {
	            $('#s-message').text(data.message);
	            $('#success-message').show();
	            clicked.remove();
				$('#feed-menu').append('<a class="btn btn-primary" href="#" id="subscribe-button">Subscribe</a>');
				$('#subscribe-button').click(subscribePost);
	        }
	        else
	        {
	            $('#e-message').text(data.message);
	            $('#error-message').show();
	            $('#save-feed-button').button('reset')
	        }
		}, 'json');

		return false;
	}

	var subscribePost = function () {

		$('.alert').slideUp();

		var clicked = $(this);

		$.post("/api/subscribe", {"id":"<%= sub.id %>"}, function(data) {
			if(data.success)
	        {
	            $('#s-message').text(data.message);
	            $('#success-message').show();
	            clicked.remove();
				$('#feed-menu').append('<a class="btn btn-danger" href="#" id="unsubscribe-button">Unsubscribe</a>');
				$('#unsubscribe-button').click(unsubscribePost);
	        }
	        else
	        {
	            $('#e-message').text(data.message);
	            $('#error-message').show();
	            $('#save-feed-button').button('reset')
	        }
		}, 'json');

		return false;
	}

	$('#unsubscribe-button').click(unsubscribePost);

	$('#subscribe-button').click(subscribePost);

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
	$( ".timepicker" ).timepicker({'minuteStep':10, 'showMeridian':false});

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
			'description':$('#inputDescription').val(), 'attachment-url':$('#inputAttachment').val(), 'additional-info':$('#inputAdditional').val(), 'deadline-id':0}, function(data) {
				if(data.success)
				{
					$('#s-message').text(data.message);
					$('#create-success').show();
					setTimeout("window.location.reload()", 2000);
				}
				else
				{
					$('#e-message').text(data.message);
					$('#create-error').show();
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

	if(qs["success"])
	{
		$('#s-message').text(qs["success"]);
		$('#success-message').show();
	}

	if(qs["error"])
	{
		$('#e-message').text(qs["error"]);
		$('#error-message').show();
	}

</script>

<!-- For scheduling chart -->
<script type="text/javascript">

function loadChart() {

	google.load('visualization', '1.0', {'packages':['corechart'], "callback" : drawChart});
	//google.setOnLoadCallback(drawChart);
}

function drawChart() {
	var offset = new Date().getTimezoneOffset();

	$.getJSON("/api/schedule", { "id":"<%= sub.id %>", "offset":offset }, function(scheduleData) {
		var data = new google.visualization.DataTable();
		data.addColumn('string', 'Date');
		data.addColumn('number', 'Subscribers with assignments');
		data.addColumn({type: 'string', role: 'tooltip', 'p': {'html': true}});
		data.addRows(scheduleData);
		var options = {
			'legend': {position: 'none'},
			'height':390,
			'width':'100%',
			'colors':['#167261', '#1FA38B', '#0E4B40'],
			'vAxis': {textStyle: {fontSize: 12, color: '#666'}},
			'hAxis': {title:'Number of subscribers with existing deadlines'},
			'chartArea': {left: 50, top: 10, height:320, width:'85%'},
			'tooltip': {isHtml: true},
			'fontName': 'PT Sans',
			'bar': {groupWidth: '95%'},
		};

		// Instantiate and draw chart
		var chart = new google.visualization.BarChart(document.getElementById('scheduling-chart'));
		chart.draw(data, options);
		$('#showchart-help').slideDown();
	});
}

$('#showchart-button').click(function() {
	loadChart();
	$('#scheduling-chart').html('<center><img src="/img/spinner.gif"/></center>');
	$('.showchart-help').hide();
	return false;
});


</script>
</html>