package api;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.Utils;
import deadlineserver.models.DUser;

public class GetDeadlineServlet extends HttpServlet{

	private static final Logger log = Logger.getLogger(GetDeadline.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException
	{
		Utils.registerObjectifyClasses();
		Objectify ofy = ObjectifyService.begin();
		log.setLevel(Level.ALL);
		log.info("Deadline API called.");
				
		resp.setContentType("application/json");
		
		String userId = req.getParameter("userId");
		String regId = req.getParameter("regId");
		DUser oldUser;
		if(regId!=null){
			oldUser = ofy.query(DUser.class).filter("regId",regId).get();
			if(oldUser==null){
				log.severe("API called with unregistered user");
			    resp.getWriter().println("{\"error\":0, \"errorstr\":\"User not registered.\"}");
			    return;
			}
		}
		else if(userId!=null){
			oldUser = ofy.query(DUser.class).filter("userId",regId).get();
			if(oldUser==null || oldUser.regId==null){
				log.severe("API called with unregistered user");
			    resp.getWriter().println("{\"error\":0, \"errorstr\":\"User not registered.\"}");
			    return;
			}
		}
		else{
			log.severe("API called with no userId or regId");
		    resp.getWriter().println("{\"error\":0, \"errorstr\":\"No userId/regId found in api call.\"}");
		    return;
		}
		
		resp.getWriter().println(Utils.getAllDeadlinesJSON(oldUser, ofy));
		return;
	}

}
