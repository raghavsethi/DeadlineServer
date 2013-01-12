package deadlineserver;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;

public class SubscriptionApiServlet extends HttpServlet{

	private static final Logger log = Logger.getLogger(SubscriptionApiServlet.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException
	{
		Utils.registerObjectifyClasses();
		Objectify ofy = ObjectifyService.begin();
		log.setLevel(Level.ALL);
		log.info("Subscription API called.");
				
		resp.setContentType("application/json");
		resp.getWriter().println(Utils.getAllSubscriptionsJSON(ofy));
		return;
	}
}
