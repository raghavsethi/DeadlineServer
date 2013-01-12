package deadlineserver.models;

import javax.persistence.Id;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Cached;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity @Cached
public class Subscription
{
	@Id public String id;
	public String name;
	@Indexed public Key<DUser> owner;
	public int numSubscribers;
	
	public Subscription()
	{
		numSubscribers = 0;
	}
}
