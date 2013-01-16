package deadlineserver.models;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Id;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Cached;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class DUser
{
	@Id public String email;
	public String regId;
	
	public ArrayList<Key<Subscription>> subscriptions;
	
	public DUser()
	{
		subscriptions = new ArrayList<Key<Subscription>>();
	}
}
