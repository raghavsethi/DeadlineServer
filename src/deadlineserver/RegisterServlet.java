package deadlineserver;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;
import deadlineserver.models.Subscription;

@SuppressWarnings("serial")
public class RegisterServlet extends BaseServlet {
	
	private static final Logger log = Logger.getLogger(RegisterServlet.class.getName());
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)	throws ServletException, IOException {
		
		log.setLevel(Level.ALL);
		String regId = getParameter(req,"regId");
		String userId = getParameter(req,"userId");

		log.info("Registering "+userId+" with Registration Id "+regId);
		Utils.registerObjectifyClasses();
		Objectify ofy = ObjectifyService.begin();
		DUser oldUser = ofy.query(DUser.class).filter("userId",userId).get();
		if(oldUser==null){
			DUser newUser=new DUser();
			newUser.email=userId;
			newUser.regId=regId;
			ofy.put(newUser);
			log.info("User "+ userId+" registered.");
		}
		else{
			log.info("User "+ userId+" already present.");
			if(oldUser.regId==null){
				log.info("User "+ userId+" present but not registered");
				oldUser.regId=regId;
				ofy.put(oldUser);
				log.info("User "+ userId+"registered");
			}
		}
		resp.getWriter().println("OK");
		//setSuccess(resp);
	}
	
	

}
