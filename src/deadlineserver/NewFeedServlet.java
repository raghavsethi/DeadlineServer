package deadlineserver;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import api.GetSubscriberSchedule;

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
	private static final Logger log = Logger.getLogger(NewFeedServlet.class.getName());
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		log.setLevel(Level.ALL);
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    
	    resp.setContentType("application/json");
	    
	    if(user==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"You need to be logged-in to create a new feed.\"}");
	    	log.info("You need to be logged-in to create a new feed");
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
	    
	    if(oldUser==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Internal error - user not found in database.\"}");
	    	log.info("Internal error - user not found in database");
	    	return;
	    }
	    
	    if(req.getParameter("feed-id")==null || req.getParameter("feed-name")==null)
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Required parameters not supplied\"}");
	    	log.info("Required parameters not supplied");
	    	return;
	    }
	    
	    String feedId = (String)req.getParameter("feed-id");
	    String feedName = (String)req.getParameter("feed-name");
	    
	    String websiteUrl = (String)req.getParameter("website-url");
	    String groupEmail = (String)req.getParameter("group-email");
	    
	    if(feedId == "" || feedName == "")
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Blank values not allowed for ID and name\"}");
	    	log.info("Blank values not allowed for ID and name");
	    	return;
	    }
	    
	    try {
	    	ofy.get(new Key<Subscription>(Subscription.class, feedId));
	    	resp.getWriter().println("{\"success\":false, \"message\":\"This feed ID already exists\"}");
	    	log.info("This feed ID already exists");
	    	return;
	    }
	    catch(Exception e)
	    {}
	    	    
	    Subscription s = new Subscription();
	    s.id = feedId;
	    s.name = feedName;

	    if(websiteUrl!="")
	    	s.websiteUrl = websiteUrl;
	    
	    if(groupEmail!="")
	    {
	    	 try {
	    	      InternetAddress emailAddr = new InternetAddress(groupEmail);
	    	      emailAddr.validate();
	    	      s.groupEmail = groupEmail;
	    	 }
	    	 catch (AddressException ex) {
	    		 resp.getWriter().println("{\"success\":false, \"message\":\"Invalid email address. Try again.\"}");
	    	 }
	    }

	    s.owner = new Key<DUser>(DUser.class, oldUser.email);
	    ofy.put(s);
	    
	    s.sendVerificationEmail();
	    resp.getWriter().println("{\"success\":true, \"message\":\"Created new feed! Verification email sent.\"}");
	    log.info("Created new feed! Verification email sent");
	}
}