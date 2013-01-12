package deadlineserver;

import com.google.android.gcm.server.Constants;
import com.google.android.gcm.server.Message;
import com.google.android.gcm.server.Result;
import com.google.android.gcm.server.Sender;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import deadlineserver.models.DUser;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings("serial")
public class SendMessageServlet extends BaseServlet {

	private static final Logger log = Logger.getLogger(SendMessageServlet.class.getName());
	private static final String APIKey= Keys.gcmKey;
	private Sender sender;

	@Override
	public void init(ServletConfig config) throws ServletException {
		super.init(config);
		sender = new Sender(APIKey);
	}

	@Override
	 protected void doPost(HttpServletRequest req, HttpServletResponse resp)throws IOException, ServletException {
		String regId=getParameter(req,"regId");
		sendMessage(regId, resp);
		return;
	}
	
	private void sendMessage(String regId, HttpServletResponse resp) throws IOException {
		
		log.setLevel(Level.ALL);
		log.info("Sending message to device " + regId);
		Utils.registerObjectifyClasses();
		resp.setContentType("application/json");
		Objectify ofy = ObjectifyService.begin();
		DUser oldUser=ofy.query(DUser.class).filter("regId",regId).get();
		if(oldUser==null){
			 resp.getWriter().println("{\"error\":0, \"errorstr\":\"User not registered.\"}");
		}
		Message message = new Message.Builder().addData("allDeadlines", Utils.getAllDeadlinesJSON(oldUser, ofy).toJSONString()).build();
		System.out.println(message.getData());
		Result result;
		try {
			result = sender.sendNoRetry(message, regId);
		} catch (IOException e) {
			log.severe("Exception posting " + message);
			log.severe(e.getMessage());
			resp.setStatus(500);
			return;
		}
		if (result == null) {
			resp.setStatus(500);
			return;
		}
		if (result.getMessageId() != null) {
			log.info("Succesfully sent message to device " + regId);
			String canonicalRegId = result.getCanonicalRegistrationId();
			if (canonicalRegId != null) {
				log.info("Device "+regId+" has more than one registration id's");
				Utils.updateRegId(regId, canonicalRegId, ofy);
			}
		}
		else {
			String error = result.getErrorCodeName();
			if (error.equals(Constants.ERROR_NOT_REGISTERED)) {
				log.info("Device "+regId+" has uninstalled the app. Unregistering it");
				Utils.unregisterRegId(regId, ofy);
			} else {
				log.severe("Error sending message to device " + regId+ ": " + error);
				if(error.compareToIgnoreCase("Unavailable")==0){
					sendMessage(regId, resp);
				}
			}
		}
	}
}
