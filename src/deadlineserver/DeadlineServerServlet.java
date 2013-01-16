package deadlineserver;

import java.io.IOException;
import java.util.ArrayList;

import javax.servlet.http.*;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;

import deadlineserver.models.*;

@SuppressWarnings("serial")
public class DeadlineServerServlet extends HttpServlet
{
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    System.out.println("DeadlineServerServlet");
	    DUser oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
	    if(oldUser==null){
	    	oldUser=new DUser();
	    	oldUser.email = user.getEmail();
	    	ofy.put(oldUser);
	    }	    
	    Subscription s = new Subscription();
	    s.id = "CSE343";
	    s.name = "Machine Learning";
	    s.owner = new Key<DUser>(DUser.class, user.getEmail());
	    oldUser.subscriptions.add(new Key<Subscription>(Subscription.class, s.id));
	    //oldUser.subscriptions.get(0).
	    ofy.put(s);
	    ofy.put(oldUser);
	    
		resp.setContentType("text/plain");
		resp.getWriter().println("Hello, world");
	}
}
