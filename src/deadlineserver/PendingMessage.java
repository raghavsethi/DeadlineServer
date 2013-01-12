package deadlineserver;

import java.util.ArrayList;

import javax.persistence.Id;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Unindexed;

import deadlineserver.models.Deadline;

@Entity
public class PendingMessage {

	@Id public String regId;
	@Unindexed public ArrayList<Key<Deadline>> addedDeadlines;
	
	public PendingMessage(){
		addedDeadlines=new ArrayList<Key<Deadline>>();
	}
}
