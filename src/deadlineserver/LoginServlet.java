package deadlineserver;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import api.GetSubscriberSchedule;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;

public class LoginServlet extends HttpServlet
{
	private static final Logger log = Logger.getLogger(LoginServlet.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    
	    resp.setContentType("application/json");
	    
	    if(user==null) {
	    	resp.sendRedirect(userService.createLoginURL("/login"));
	    	return;
	    }
	    
	    DUser oldUser = null;
	    try
	    {
	    	oldUser = ofy.get(DUser.class, user.getEmail());
	    }
	    catch(Exception e)
	    {
	    	oldUser = new DUser();
	    	oldUser.email = user.getEmail();
	    	ofy.put(oldUser);
	    }
	    
	    resp.sendRedirect("/");
	}
}
