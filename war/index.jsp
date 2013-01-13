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
        if(oldUser==null){
                oldUser = new DUser();
                ofy.put(oldUser);
            }

        if(oldUser.user==null){
                oldUser.user=user;
                ofy.put(oldUser);
            }
    }

    boolean loggedIn=false;

    List<Deadline> pendingDeadlines = new ArrayList<Deadline>();
    List<Deadline> expiredDeadlines = new ArrayList<Deadline>();

    HashMap<String, String> idToSubName = new HashMap<String, String>();

    if(oldUser!=null) {
        loggedIn = true;

        for(Key<Subscription> subK : oldUser.subscriptions) {
            try
            {
            sub = ofy.get(subK);

            idToSubName.put(sub.id, sub.name);

            Query<Deadline> q = ofy.query(Deadline.class).filter("subscription", subK).filter("dueDate >", new Date()).order("dueDate");
            Query<Deadline> qExpired = ofy.query(Deadline.class).filter("subscription", subK).filter("dueDate <", new Date()).order("-dueDate");

            pendingDeadlines.addAll(q.list());
            expiredDeadlines.addAll(qExpired.list());
            }
            catch(Exception e)
            {}
        }

        Collections.sort(pendingDeadlines);
        Collections.sort(expiredDeadlines);
        Collections.reverse(expiredDeadlines);
        
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
          <a class="brand" href="/"><img src="/img/logo.png" style="height:20px" /></a>
          <div class="nav-collapse collapse">
            <ul class="nav">
                <% if(loggedIn) { %>
                <li class="active"><a href="/">Schedule</a></li>
                <% } else { %>
                <li class="active"><a href="/">Home</a></li>
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
                <li class="active"><a href="/">Schedule</a></li>
                <% } else { %>
                <li class="active"><a href="/">Home</a></li>
                <% } %>
                <li><a href="/profile">Courses</a></li>
                <li><a href="/about">About</a></li>
                <li><a href="/help">Help</a></li>
                <% if(loggedIn) { %>
                <li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Log out</a></li>
                <% } %>
            </div>
        </div>

        <% if(!loggedIn) { %>
        <div class="span9">
            <div class="row-fluid">
                <h2>Deadline is an Android and web-app that allows you to easily manage your deadlines.</h2>
                
                <p>It's time to stop managing to-do apps you never update, sticky notes that don't sync and complicated calendar software that's a pain to manage.</p>
                <p><strong>Deadline</strong> makes managing all your deadlines dead simple.</p>

                <a class="btn btn-success btn-large" href="/profile"><strong>Sign up now!</strong></a>
                or 
                <a class="btn btn-info btn-large" href="<%= userService.createLoginURL("/") %>"><strong>Log in</strong></a>
                <br />
                <a class="btn btn-invers btn-large" href="https://dl.dropbox.com/u/27244696/Tesxt.apk"><strong>Get our Android app</strong></a>
            </div>
            <div class="row-fluid">
                <div class="span6"><h3>Students</h3><p>Let's say you're taking an Econ101 at your university and having trouble keeping track of the dozens of homework assignments your instructor keeps setting you. With <strong>Deadline</strong> you can just subscribe to the Econ101 feed and your Android phone will automagically remind you of your submission dates.</p></div>
                <div class="span6"><h3>Instructors</h3><p>Use our convenient interface to make sure your students never miss another deadline. Students will automatically be reminded of upcoming submissions, tests, reviews etc. well in time so that they're well prepared.</p></div>
            </div>
        </div>

        <% } else { %>
            <div class="span9">
                <h1 style="margin-bottom:1px;">Schedule</h1>
                <hr style="margin-top:0; margin-bottom:7px;" />

                <% if (pendingDeadlines.size()==0) { %>
                    <p>Yippee! No upcoming deadlines. <a href="/profile">Subscribe to more courses</a> to get upcoming deadlines</p>
                <% } %>

                <%
                for(Deadline d:pendingDeadlines)
                    {
                %>

                <div class="deadline">
                    <a href="#" class="expand-link deadlineview" data-expand="<%=d.id%>-more-info">
                    <table>
                        <tr>
                            <td width="100%">
                                
                                <h3><script type="text/javascript">document.write(printLocalDate(<%=d.dueDate.getTime()%>));</script></h3>
                                <h4><script type="text/javascript">document.write(printLocalTime(<%=d.dueDate.getTime()%>));</script></h4><br />
                                <h5><%=idToSubName.get(d.subscription.getName())%></h5>
                                <br />
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

                <% if (expiredDeadlines.size()==0) { %>
                    <p>No expired deadlines.</p>
                <% } %>

                <%
                for(Deadline d:expiredDeadlines)
                    {
                %>

                <div class="deadline passed">
                    <a href="#" class="expand-link deadlineview" data-expand="<%=d.id%>-more-info">
                    <table>
                        <tr>
                            <td width="100%">
                                <h3><script type="text/javascript">document.write(printLocalDate(<%=d.dueDate.getTime()%>));</script></h3>
                                <h4><script type="text/javascript">document.write(printLocalTime(<%=d.dueDate.getTime()%>));</script></h4><br />
                                <h5><%=idToSubName.get(d.subscription.getName())%></h5>
                                <br />
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
        <% } %>

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