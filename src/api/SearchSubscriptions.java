package api;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;

import deadlineserver.Utils;
import deadlineserver.models.*;

public class SearchSubscriptions extends HttpServlet{

	private static final Logger log = Logger.getLogger(SearchSubscriptions.class.getName());
	
	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException
	{
		Utils.registerObjectifyClasses();
		Objectify ofy = ObjectifyService.begin();
		log.setLevel(Level.ALL);

		
		List<Subscription> q = ofy.query(Subscription.class).list();
		
		resp.setContentType("application/json");
		JSONArray jResult = new JSONArray();
		
		String query = (String)req.getParameter("q");
		
		//log.info("Search called with query: " + query);
		
		if(query==null) {
			resp.getWriter().println("[]");
		}
		
		//Best matches
		for(Subscription s:q)
		{
			if(s.id.toLowerCase().startsWith(query.toLowerCase()) || s.name.toLowerCase().startsWith(query.toLowerCase()))
			{
				JSONObject jSubscription =new JSONObject();
				jSubscription.put("id", s.id);
				jSubscription.put("name", s.name);
				jResult.add(jSubscription);
				s.name=""; //Hack to prevent duplicates..
			}
		}
		
		//Middle matches
		for(Subscription s:q)
		{
			if(s.id.toLowerCase().contains(query.toLowerCase()) || s.name.toLowerCase().contains(query.toLowerCase()))
			{
				JSONObject jSubscription =new JSONObject();
				jSubscription.put("id", s.id);
				jSubscription.put("name", s.name);
				jResult.add(jSubscription);
			}
		}
		
		resp.getWriter().println(jResult.toJSONString());
	}

}
