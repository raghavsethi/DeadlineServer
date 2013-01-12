package deadlineserver;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;
import deadlineserver.models.Subscription;

@SuppressWarnings("serial")
public class NewFeedServlet extends HttpServlet
{
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    
	    resp.setContentType("application/json");
	    
	    if(user==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"You need to be logged-in to create a new feed.\"}");
	    	return;
	    }
	    
	    DUser oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
	    
	    if(oldUser==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Internal error - user not found in database.\"}");
	    	return;
	    }
	    
	    if(oldUser.user==null){
	    	oldUser.user=user;
	    	ofy.put(oldUser);
	    }
	    
	    if(req.getParameter("feed-id")==null || req.getParameter("feed-name")==null)
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Required parameters not supplied\"}");
	    	return;
	    }
	    
	    String feedId = (String)req.getParameter("feed-id");
	    String feedName = (String)req.getParameter("feed-name");
	    
	    if(feedId == "" || feedName == "")
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Blank values not allowed\"}");
	    	return;
	    }
	    
	    try {
	    	ofy.get(new Key<Subscription>(Subscription.class, feedId));
	    	resp.getWriter().println("{\"success\":false, \"message\":\"This feed ID already exists\"}");
	    	return;
	    }
	    catch(Exception e)
	    {}
	    	    
	    Subscription s = new Subscription();
	    s.id = feedId;
	    s.name = feedName;
	    s.owner = new Key<DUser>(DUser.class, oldUser.id);

	    ofy.put(s);
	    
	    resp.getWriter().println("{\"success\":true, \"message\":\"Created new feed!\"}");
	}
}