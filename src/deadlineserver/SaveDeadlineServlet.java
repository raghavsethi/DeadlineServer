package deadlineserver;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONObject;
import org.mortbay.log.Log;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;

import deadlineserver.models.*;

@SuppressWarnings("serial")
public class SaveDeadlineServlet extends HttpServlet
{
	private static final Logger log = Logger.getLogger(SaveDeadlineServlet.class.getName());
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException
	{
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		log.setLevel(Level.ALL);
		
		UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	    
	    if(user==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"You need to be logged-in to create a new deadline.\"}");
	    	return;
	    }
	    
	    DUser oldUser = ofy.query(DUser.class).filter("userId",user.getEmail()).get();
	    
	    resp.setContentType("application/json");
	        
	    if(oldUser==null) {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Internal error - user not found in database.\"}");
	    	return;
	    }
	    
	    if(oldUser.user==null){
	    	oldUser.user=user;
	    	ofy.put(oldUser);
	    }
	    
	    if(req.getParameter("id")==null || req.getParameter("title")==null 
	    		|| req.getParameter("date")==null || req.getParameter("subscription-id")==null
	    		|| ((String)req.getParameter("date")).equals("NaN"))
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Required parameters not supplied\"}");
	    	return;
	    }
	    
	    Long dId = (long) 0;
	    String deadlineIdStr = (String)req.getParameter("deadline-id");
	    if(deadlineIdStr!=null);
	    {
	    	System.out.println("Deadline ID!: "+ deadlineIdStr==null);
	    	dId = Long.parseLong(deadlineIdStr);
	    }
	    
	    String dTitle = (String)req.getParameter("title");
	    Long dDate = Long.parseLong((String)req.getParameter("date"));
	    String subscriptionId = (String)req.getParameter("subscription-id");
	    
	    if(dTitle == "" || subscriptionId=="")
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Blank values not allowed\"}");
	    	return;
	    }
	    
	    // First check if subscription exists
	    
	    Subscription s = null;
	    
	    try {
	    	s = ofy.get(new Key<Subscription>(Subscription.class, subscriptionId));
	    }
	    catch(Exception e)
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"Feed does not exist\"}");
	    	return;
	    }
	    
	    // Check if user is owner of subscription
	    
	    if(s.owner.getId()!=oldUser.id)
	    {
	    	resp.getWriter().println("{\"success\":false, \"message\":\"You are not authorized to add deadlines to this feed.\"}");
	    	return;
	    }
	    
	    
	    // Check if existing deadline is being modified, or new one is being created
	    
	    Deadline d = null;
	    boolean updatedDeadline=false;
	    
	    
	    if(dId==0)
	    {
	    	d = new Deadline();
	    }
	    else
	    {
		    updatedDeadline=true;
	    	try
		    {
		    	d = ofy.get(new Key<Deadline>(Deadline.class, dId));
		    }
		    catch(Exception e)
		    {
		    	resp.getWriter().println("{\"success\":false, \"message\":\"Could not find the given deadline.\"}");
		    	return;
		    }
	    }
	    d.updated=updatedDeadline;	    
	    d.title = dTitle;
	    d.dueDate = new Date(dDate);
	    d.description = (String)req.getParameter("description");
	    
	    if((String)req.getParameter("attachment-url")!=null && (String)req.getParameter("attachment-url")!="")
	        d.attachmentUrl = (String)req.getParameter("attachment-url");
	    
	    //System.out.println("Attachment url:"+d.attachmentUrl);
	    
	    if((String)req.getParameter("additional-info")!=null && (String)req.getParameter("additional-info")!="")
	    	d.additionalInfo = (String)req.getParameter("additional-info");
	    
	    d.subscription = new Key<Subscription>(Subscription.class, s.id);
	    ofy.put(d);
	    
	    
	    /*
	    JSONObject addedDeadline=new JSONObject();
	    addedDeadline.put("title",d.title);
	    addedDeadline.put("description",d.description);
	    addedDeadline.put("dueDate",d.dueDate.toString());
	    addedDeadline.put("additionalInfo",d.additionalInfo);
	    addedDeadline.put("attachmentUrl",d.attachmentUrl);
	    addedDeadline.put("subscription",s.name);*/
	    
	    log.info("Saving the added deadline as pending messages");
	    
	    ArrayList<DUser> userList=new ArrayList<DUser>();
	    Query<DUser> q=ofy.query(DUser.class);
	    Key k=new Key<Subscription>(Subscription.class, subscriptionId);
	    for(DUser deadlineUser: q){
	    	if(deadlineUser.regId==null || !deadlineUser.subscriptions.contains(d.subscription)){
	    		continue;
	    	}
	    	System.out.println(deadlineUser.userId);
	    	System.out.println(deadlineUser.subscriptions.toArray().toString());
	    	//userList.add(deadlineUser);
	    	log.info("Newly added deadline to be sent to "+deadlineUser.userId);
	    	PendingMessage message;
	    	try{
	    		message=ofy.get(PendingMessage.class, deadlineUser.regId);
	    		message.addedDeadlines.add(new Key<Deadline>(Deadline.class,d.id));
	    	}catch(Exception e){
	    		message=new PendingMessage();
		    	message.regId=deadlineUser.regId;
		    	message.addedDeadlines.add(new Key<Deadline>(Deadline.class,d.id));
	    	}
	    	ofy.put(message);
	    	log.info("Pending Message to be sent to "+deadlineUser.userId+" added");
	    }
	    log.info("Done.");
	    resp.getWriter().println("{\"success\":true, \"message\":\"Saved deadline!\"}");
	    return;
	    
	    
	    /*
	    System.out.println("Sending message to users subscribed to "+s.name);
	    Key k=new Key<Subscription>(Subscription.class, subscriptionId);
	    for(int i=0;i<userList.size();i++){
	    	if(userList.get(i).subscriptions.contains(k) && userList.get(i).regId!=null){
	    		System.out.println("Send message to user "+userList.get(i).userId);
	    		Utils.sendMessage(userList.get(i).regId, addedDeadline);
	    	}
	    }*/
	    
	    //Utils.sendMessage("APA91bEB0ArL4z7c9E5v4x0qV5ApHCmIFqoj55bBZTia3padK2mTEgMGd39BhT0kuqtLCscgQnl2I6-r5iKo5uxj0ebHWKinFd6rE8i6oJZcaJtEDRk1NUbJxljssLZXMPU6i_Iw79Bcz-0GqBALspdtz74yll0jvw", addedDeadline);
	    //Send the details of the new Deadline to all DUssers who have subscribed to it
	    
	    
	}
}