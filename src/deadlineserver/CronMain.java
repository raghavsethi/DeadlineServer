package deadlineserver;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

public class CronMain extends HttpServlet 
{
	private static Objectify ofy;
	static final Logger log = Logger.getLogger(CronMain.class.getName());
	
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException
	{		
		ofy = ObjectifyService.begin();
		log.setLevel(Level.INFO);
		Utils.registerObjectifyClasses();
		
		Object jobObj = req.getParameter("update");
		
		resp.setContentType("text/html");
		
		if(jobObj==null)
		{
			log.severe("Cron failed, 'job' parameter not present.");
			resp.getWriter().println("Error.");
		}
				
		String jobName = (String)jobObj;
		jobName = jobName.toLowerCase();
		
		try
		{
			performJob(jobName);
			resp.getWriter().println("Performed job " + jobName);
		}
		catch(Exception e)
		{
			resp.getWriter().println("Error occurred: " + e);
			e.printStackTrace();
			//AdminNotify.NotifyAdminsByEmail("Cron failed", "The cron job '" + jobName + "' failed "
			//+ "due to " + e, "High");
		}

		resp.getWriter().println("Finished");
	}
	
	public void performJob(String jobName){
		System.out.println(jobName);
		if(jobName.equals("notifyusers")){
			PendingMessageCron.refresh();
		}
	}
}
