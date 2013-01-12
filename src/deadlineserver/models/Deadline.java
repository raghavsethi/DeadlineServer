package deadlineserver.models;

import java.util.Date;
import java.util.HashMap;

import javax.persistence.Id;
import javax.persistence.Transient;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Cached;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity @Cached
public class Deadline implements Comparable<Deadline>
{
	// Required fields
	@Id public Long id;
	public String title;
	@Indexed public Date dueDate;
	@Indexed public Key<Subscription> subscription;

	// Optional fields
	public String description;
	public String attachmentUrl;
	public String additionalInfo;
	public boolean updated;
	
	public Deadline(){
		updated=false;
	}

	@Override
	public int compareTo(Deadline o)
	{
		return this.dueDate.compareTo(o.dueDate);
	}
}
