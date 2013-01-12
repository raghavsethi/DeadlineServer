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
		response.sendRedirect("/index.jsp?message=You%20are%20not%20logged%20in");
		return;
	}
	oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
	if (oldUser == null)
	{
		response.sendRedirect("/index.jsp?message=Error");
		return;
	}
	
	if(oldUser.user==null){
	    	oldUser.user=user;
	    	ofy.put(oldUser);
	}

    boolean loggedIn=false;

    if(oldUser!=null)
        loggedIn = true;

	pageContext.setAttribute("user", user);
	
	ArrayList<Subscription> subscriptions = new ArrayList<Subscription>();
	for(Key<Subscription> ks:oldUser.subscriptions) {
	  subscriptions.add(ofy.get(ks));
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
    <title>Deadline</title>
    <link href="/css/bootstrap.css" rel="stylesheet">
    <link rel="shortcut icon" href="/favicon.ico"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link href="/css/bootstrap-responsive.css" rel="stylesheet">
    <link href='http://fonts.googleapis.com/css?family=PT+Sans' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="/css/add2home.css">
    <script type="application/javascript" src="/js/add2home.js"></script>
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
                <% }%>
            </div>
        </div>

        <div class="span9">
            <form>
                <legend>New course</legend>

                <div class="alert alert-error" style="display:none;">
                  <button type="button" class="close" data-dismiss="alert">×</button>
                  <strong>Oops.</strong> <span id="e-message"></span>
              </div>
              <div class="alert alert-success" style="display:none;">
                  <button type="button" class="close" data-dismiss="alert">×</button>
                  <strong>Success!</strong> <span id="s-message"></span>
              </div>

              <div class="control-group" id="feed-id-group">
                <label><strong>Course ID</strong></label>
                <input type="text" placeholder="intro-to-crypto" id="feed-id">
                <span class="help-block">This should be short and unique. People can subscribe to your course using just this ID. Alphanumeric characters, underscores and dashes allowed.</span>
            </div>
            <label><strong>Course Name</strong></label>
            <input type="text" placeholder="Introductory Programming" id="feed-name">
            <span class="help-block">This should be descriptive, but still as short as possible, and should help people understand what exactly they've subscribed to. Alphanumeric characters, underscores and dashes allowed, but we recommend a simple English name</span>
            <button class="btn btn-inverse" id="save-feed-button" onClick="saveFeed()" type="button" data-loading-text="Saving...">Save new course</button>

        </form>
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

$('.btn').button();
$('.alert').alert();

var saveFeed = function(e) {
    $('.alert').hide();
    $('#save-feed-button').button('loading');
    $.post('/newfeed', {'feed-id':$('#feed-id').val(), 'feed-name':$('#feed-name').val()}, function(data) {
        if(data.success)
        {
            $('#s-message').text(data.message);
            $('.alert-success').show();
            setTimeout("window.location = '/feed/"+$('#feed-id').val()+"?newfeed=true'", 3000);
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
</script>

</body>
</html>