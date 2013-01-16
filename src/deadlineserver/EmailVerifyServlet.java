package deadlineserver;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;
import deadlineserver.models.Subscription;

public class EmailVerifyServlet extends HttpServlet
{
	private static final Logger log = Logger.getLogger(EmailVerifyServlet.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    
	    if(user==null) {
		    log.info("User not logged-in to Google, logging in to redirect");
	    	resp.sendRedirect(userService.createLoginURL(req.getQueryString()));
	    	return;
	    }
	    
	    DUser oldUser = null;
	    try
	    {
	    	oldUser = ofy.get(DUser.class, user.getEmail());
	    }
	    catch(Exception e)
	    {
	    	log.warning("User not found in database, saving again.");
	    	oldUser = new DUser();
	    	oldUser.email = user.getEmail();
	    	ofy.put(oldUser);
	    }
	    
	    String subId = (String)req.getParameter("id");
	    String verificationCode = (String)req.getParameter("verify-code");
	    
	    Subscription s = null;
	    try
	    {
	    	s = ofy.get(Subscription.class, subId);
	    }
	    catch(Exception e)
	    {
	    	log.warning("Course ID not found");
	    	resp.sendError(500);
	    	return;
	    }
	    
	    if(s.verified)
	    {
	    	resp.sendRedirect("/feed/"+s.id+"?error=Email%20already%20verified");
	    	return;
	    }
	    
	    if(!oldUser.email.equals(s.owner.getName()))
	    {
	    	resp.sendRedirect("/feed/"+s.id+"?error=You%20must%20be%20logged%20in%20as%20the%20course%20administrator%20to%20verify%20the%20email%20address");
	    }
	    
	    
	    if(verificationCode.equals(s.verificationCode))
	    {
	    	s.verified=true;
	    	ofy.put(s);
	    	resp.sendRedirect("/feed/"+s.id+"?success=Email%20verified%20successfully");
	    }
	    else
	    {
	    	resp.sendRedirect("/feed/"+s.id+"?error=Email%20verification%20failed");
	    }
	    
	    
	}
}