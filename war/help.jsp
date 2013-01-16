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
        try
        {
            oldUser = ofy.get(DUser.class,user.getEmail());
        }
        catch(Exception e)
        {
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
                <li><a href="/about">About</a></li>
                <li class="active"><a href="/help">Help</a></li>
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
                <li class="active"><a href="/help">Help</a></li>
                <% if(loggedIn) { %>
                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
                <% } %>
            </div>
        </div>

        <div class="span9">
            <div class="row-fluid">
                <h1>Help</h1>
                
                <p>Deadline was built dead simple. Every user can use Deadline to both post (for instructors) and manage assignments (for students). Help for both of these flows is below.</p>
                <h3>Students</h3>
                <h4>Adding a new subscription</h4>
                <p><strong>Web</strong> On the my profile page, click on the 'Subscribe to course' button. In the text-box, start typing the name of the course you want to subscribe to. Hit 'enter' or click the 'Add to my courses' button to finish.</p>
                <p><strong>Mobile</strong> Tap the gear icon on the top-right to add a new course to your subscriptions.</p>

                <h4>Removing a subscription</h4>
                <p><strong>Web</strong> Click on a course to open the course page. On the top-right, you will see the option to unsubscribe. Click on it - if it does not seem to work, clik it again.</p>
                <p><strong>Mobile</strong> Tap the gear icon on the top-right, and tap the cross icon next to the courses you want to unsubscribe from.</p>

                <h3>Instructors</h3>
                <h4>Adding a new course</h4>
                <p>On the my profile page, click on the 'Create new course' button. Select an easy-to-remember name and ID for your course. Do not use special characters except for dashes and underscores.</p>

                <h4>Adding a new deadline</h4>
                <p>Open the course page. If you are the owner of that course, you will see the option to create a new deadline on the top right. Fill out the form that appears. Be as accurate and detailed as possible (your students will thank you for it). When you click save, Deadline will begin sending push notifications to all students in that course who use Deadline on ther Android phones</p>

                <h4>Editing a deadline</h4>
                <p>Open the course page, click the pencil icon next to the course title. A page will open that will allow you to edit the deadline details.</p>

                <br />
                <p>If this page didn't help, please write to 'raghav09035@iiitd.ac.in' for further support. <strong>If you're on a cellphone, or another device with a limited resolution, use the dropdown menu on the top-right of the screen to navigate through the app.</strong></p>
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