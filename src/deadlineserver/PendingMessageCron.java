package deadlineserver;

import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Logger;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;

import deadlineserver.models.Deadline;
import deadlineserver.models.Subscription;

public class PendingMessageCron {

	private static final Logger log = Logger.getLogger(PendingMessageCron.class.getName());
	
	public static void refresh(){
		
		Objectify ofy = ObjectifyService.begin();
		Utils.registerObjectifyClasses();
		
		Query<PendingMessage> q=ofy.query(PendingMessage.class);
		ArrayList<PendingMessage> messages=new ArrayList<PendingMessage>();
		for(PendingMessage m:q){
			messages.add(m);
		}
		
		for(int i=0;i<messages.size();i++){
			try {
				Utils.sendMessage(messages.get(i).regId, getJSONArray(messages.get(i).addedDeadlines, ofy));
				ofy.delete(messages.get(i));
			} catch (IOException e) {
				//SEND EMAIL
			}
		}
	}
	
	@SuppressWarnings("unchecked")
	public static JSONObject getJSON(Deadline d, Objectify ofy){
		JSONObject jObject=new JSONObject();
		Subscription s=ofy.get(d.subscription);
		jObject.put("title", d.title);
		jObject.put("description", d.description);
		jObject.put("additionalInfo", d.additionalInfo);
		jObject.put("attachmentUrl", d.attachmentUrl);
		jObject.put("dueDate", d.dueDate.toString());
		jObject.put("subscription", s.name);
		jObject.put("id", d.id);
		jObject.put("updated", d.updated);
		return jObject;
	}
	
	@SuppressWarnings("unchecked")
	public static JSONArray getJSONArray(ArrayList<Key<Deadline>> message, Objectify ofy){
		JSONArray addedDeadlines=new JSONArray();
		for(int i=0;i<message.size();i++){
			Deadline d=ofy.get(message.get(i));
			addedDeadlines.add(getJSON(d, ofy));
		}	
		return addedDeadlines;
	}
}
