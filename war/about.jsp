<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
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
        oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
        if(oldUser.user==null){
                oldUser.user=user;
                ofy.put(oldUser);
            }
    }

    boolean loggedIn=false;

    if(oldUser!=null) {
        loggedIn = true;
    }
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
    <script src="/js/date.js"></script>
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
                <li class="active"><a href="/about">About</a></li>
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
                <li class="active"><a href="/about">About</a></li>
                <li><a href="/help">Help</a></li>
                <% if(loggedIn) { %>
                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
                <% } %>
            </div>
        </div>

        <div class="span9">
            <div class="row-fluid">
                <h1>About</h1>
                <p>Deadline is an application that helps instructors and students manage deadlines, course-related or otherwise. Instructors can use Deadline to post and manage new deadlines, while students can use the web or Android applications to easily see all their deadlines (from each of their classes) in one convenient interface.</p>
                <p>Deadline was built by Raghav Sethi, Mayank Pundir and Naved Alam to help IIIT-D students (and themselves) keep track of all the deadlines they have to meet</p>
            </div>

        </div>
    </div>
<hr />
<footer class="container">
    <p>Built by Mayank Pundir, Naved Alam and Raghav Sethi. Some rights reserved.</p>
</footer>
</body>
<script src="/js/jquery.js"></script>
<script src="/js/bootstrap.js"></script>
<script src="/js/retina.js"></script>
<script type="text/javascript">

$('.expand-link').click(function(e) {

    var clicked = $(this);
    var toExpand = clicked.attr("data-expand");

    if($('#'+toExpand).is(':hidden'))
        $('#'+toExpand).slideDown(200);
    else
        $('#'+toExpand).slideUp(200);

    return false;

});
</script>
</html>