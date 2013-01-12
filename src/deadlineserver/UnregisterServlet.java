package deadlineserver;

import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;

@SuppressWarnings("serial")
public class UnregisterServlet extends BaseServlet {

	private static final Logger log = Logger.getLogger(UnregisterServlet.class.getName());
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException {

		String regId = getParameter(req,"regId");
		String userId = getParameter(req,"userId");
		log.info("Unregistering "+userId+" with Registration Id "+regId);
		Utils.registerObjectifyClasses();
		Objectify ofy = ObjectifyService.begin();
		try{
			DUser oldUser = ofy.query(DUser.class).filter("userId",userId).get();
			if(oldUser==null){
				log.info("User "+ userId+" already unregistered.");
			}
			else if(oldUser.regId.compareToIgnoreCase(regId)==0){
				ofy.delete(oldUser);
				log.info("User "+ userId+" unregistered.");
			}
			else{
				log.info("User "+ userId+" already unregistered.");
			}
		}catch(Exception e){
			log.info("User "+ userId+" already unregistered.");
		}
		setSuccess(resp);
  	}
}
