<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
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
	
    if (user == null) {
		response.sendRedirect(userService.createLoginURL("/profile.jsp"));
		return;
	}

	oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
	
	if (oldUser == null)
	{
		oldUser = new DUser();
		oldUser.user = user;
		oldUser.userId=user.getEmail();
		ofy.put(oldUser);
	}
	else{
		if(oldUser.user==null){
	    		oldUser.user=user;
	    		ofy.put(oldUser);
	    	}
	}

    boolean loggedIn=false;
 
    if(oldUser!=null)
        loggedIn = true;
	
	pageContext.setAttribute("user", user);
	
	ArrayList<Subscription> subscriptions = new ArrayList<Subscription>();
	for(Key<Subscription> ks:oldUser.subscriptions) {
		try {
		  subscriptions.add(ofy.get(ks));
		}
		catch(Exception e)
		{}

	}
	pageContext.setAttribute("subscriptions", subscriptions);
	
	Query<Subscription> q = ofy.query(Subscription.class).filter("owner", oldUser);
	ArrayList<Subscription> managed = new ArrayList<Subscription>();
	for(Subscription s:q) {
	  managed.add(s);
	}
	pageContext.setAttribute("managed", managed);

%>
<!DOCTYPE html>
<html>
<head>
    <title>Deadline - My profile</title>
    <link href="/css/bootstrap.css" rel="stylesheet">
    <link rel="shortcut icon" href="/favicon.ico"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link href="/css/bootstrap-responsive.css" rel="stylesheet">
    <link href='http://fonts.googleapis.com/css?family=PT+Sans' rel='stylesheet' type='text/css'>
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
                <li class="active"><a href="/profile">Courses</a></li>
                <li><a href="/about">About</a></li>
                <li><a href="/help">Help</a></li>
                <% if(loggedIn) { %>
                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
                <% }%>
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
                <li class="active"><a href="/profile">Courses</a></li>
                <li><a href="/about">About</a></li>
                <li><a href="/help">Help</a></li>
                <% if(loggedIn) { %>
                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
                <% }%>
            </div>
        </div>

        <div class="span5">
				<h3>Courses you're subscribed to</h3>

				<%
				for (Subscription s : subscriptions) {
				%>
				<div class="subscription" data-href="/feed/<%= s.id %>">
					<a href="/feed/<%= s.id %>"><h4><%= s.name %></h4></a>
					<a class="btn btn-small unsubscribe-button" href="#" data-id="<%= s.id %>"><i class="icon-remove-sign"></i></a>
					<h5><%= s.id %></h5>
				</div>
				<% } %>

				<div class="alert alert-error" style="display:none;" id="subscribe-error">
				  <button type="button" class="close" data-dismiss="alert">×</button>
				  <strong>Oops.</strong> <span id="e-message"></span>
				</div>
				<div class="alert alert-success" style="display:none;" id="subscribe-success">
				  <button type="button" class="close" data-dismiss="alert">×</button>
				  <strong>Success!</strong> <span id="s-message"></span>
				</div>

				<div id="course-subscribe-box" style="display:none;">
					<h4>Start typing the name or ID of the course</h4>
					<input type="text" id="course-text-box">
				</div>

				<br />

				<a href="#" class="btn btn-info" id="course-subscribe-button">Subscribe to a course</a>

			</div>
			<div class="span4">
				<h3>Courses you manage</h3>

				<div class="alert alert-error" style="display:none;" id="manage-error">
					<button type="button" class="close" data-dismiss="alert">×</button>
					<strong>Oops.</strong> <span id="e-message"></span>
				</div>

				<%
				for (Subscription s : managed) {
				%>
				<div class="subscription" data-href="/feed/<%= s.id %>">
					<a href="/feed/<%= s.id %>"><h4><%= s.name %></h4></a>
					<a class="btn btn-small delete-confirm" href="#" data-id="<%= s.id %>"><i class="icon-trash"></i></a>
					<h5><%= s.id %></h5>
				</div>
				<% } %>
				<br />
				<a href="/new.jsp" class="btn">Create a new course</a>
			</div>

    </div>
</div>
<hr />
<footer class="container">
    <p>Built by Mayank Pundir, Naved Alam and Raghav Sethi. Some rights reserved.</p>
</footer>
<script src="/js/jquery.js"></script>
<script src="/js/bootstrap.js"></script>
<script src="/js/retina.js"></script>

<script type="text/javascript">

	$('#course-subscribe-button').click(function () {
		
		if($('#course-subscribe-button').text()=="Subscribe to a course") {
			$('#course-subscribe-box').fadeIn();
			$('#course-subscribe-button').text("Hide");
			$('#course-text-box').focus();
		}
		else {
			$('#course-subscribe-box').fadeOut();
			$('#course-subscribe-button').text("Subscribe to a course");
		}

		return false;
	});

	$('.unsubscribe-button').click(function () {
		
		var clicked = $(this);
    	console.log(clicked);
    	var unsubscribeId = clicked.attr("data-id");

		$.post("/api/unsubscribe", {"id":unsubscribeId}, function(data) {
			if(data.success)
	        {
	            $('#s-message').text(data.message);
	            $('#subscribe-success').show();
	        }
	        else
	        {
	            $('#e-message').text(data.message);
	            $('#subscribe-error').show();
	            $('#save-feed-button').button('reset')
	        }
		}, 'json');

		return false;
	});	

	$('#course-text-box').typeahead({
		
		source: function (query, resultCallback) {
			$.getJSON("/api/search", {q:query}, function(data) {
				results = [];
				for(i=0; i<data.length; i++)
				{
					results.push(data[i].name + " (" + data[i].id + ")");
				}
				resultCallback(results);
			});
		},

		updater: function (item) {
			$.post("/api/subscribe", {"id":item.substring(item.indexOf('(')+1, item.length-1)}, function(data) {
				if(data.success)
		        {
		            $('#s-message').text(data.message);
		            $('#subscribe-success').show();
		            setTimeout("window.location = '/profile'", 3000);
		        }
		        else
		        {
		            $('#e-message').text(data.message);
		            $('#subscribe-error').show();
		            $('#save-feed-button').button('reset')
		        }
			}, 'json');
		}
    });

    $('.subscription').click(function(e) {
    	var clicked = $(this);
    	console.log(clicked);
    	window.location = clicked.attr("data-href");
    });
	
	$('.delete-confirm').click(function(e) {
		var clicked = $(this);
		clicked.html('Click again to confirm <i class="icon-trash icon-white"></i>');
		clicked.addClass('btn-danger');
		clicked.addClass('delete');
		clicked.removeClass('delete-confirm');
		
		$('.delete').click(function(e) {
			console.log("Delete clicked");
			var clicked = $(this);
			$.post('/deletefeed', {'feed-id':clicked.attr('data-id')}, function(data) {
				if(data.success)
				{
					clicked.parent().fadeOut();	
				}
				else
				{
					$('#e-message').text(data.message);
					$('#manage-error').show();
				}
			});
			return false;	
		});
		
		return false;	
	});

</script>

</body>
</html>