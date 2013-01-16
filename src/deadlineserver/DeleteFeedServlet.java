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
import com.googlecode.objectify.Query;

import deadlineserver.models.DUser;
import deadlineserver.models.Subscription;

@SuppressWarnings("serial")
public class DeleteFeedServlet extends HttpServlet
{
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    if(user==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"You need to be logged-in to delete feeds.\"}");
	    	return;
	    }
	    
	    DUser oldUser = null;
	    try
	    {
	    	oldUser = ofy.get(DUser.class,user.getEmail());
	    }
	    catch(Exception e)
	    {
	    	//Do nothing
	    }
	    
	    resp.setContentType("application/json");
	    
	    if(oldUser==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Internal error - user not found in database.\"}");
	    	return;
	    }
	    
	    if(req.getParameter("feed-id")==null)
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Required parameters not supplied\"}");
	    	return;
	    }
	    
	    String feedId = (String)req.getParameter("feed-id");
	    
	    if(feedId == "")
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Blank values not allowed\"}");
	    	return;
	    }
	    
	    try {
	    	Key<Subscription> sKey = new Key<Subscription>(Subscription.class, feedId);
	    	Subscription s = ofy.get(sKey);
	    	DUser owner = ofy.get(s.owner);
	    	if(owner.email.equals(oldUser.email))
	    	{
		    	ofy.delete(s);

		    	//Remove subscription from all the users who have subscribed
				Query<DUser> allUsersQuery = ofy.query(DUser.class);
				for(DUser du : allUsersQuery)
				{
					if(du.subscriptions.contains(sKey))
					{
						du.subscriptions.remove(sKey);
						ofy.put(du);
					}
				}
		    	
		    	resp.getWriter().println("{\"success\":true, \"message\":\"Deleted feed successfully\"}");
		    	return;
	    	}
	    	else
	    	{
	    		resp.getWriter().println("{\"success\":false, \"message\":\"You are not authorized to delete this feed.\"}");
		    	return;
	    	}
	    }
	    catch(Exception e)
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Unable to find feed with given ID.\"}");
	    }
	    
	    
	}
}