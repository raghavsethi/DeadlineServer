package deadlineserver.models;

import javax.persistence.Id;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Cached;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

import deadlineserver.SendEmail;

@Entity @Cached
public class Subscription
{
	@Id public String id;
	public String name;
	@Indexed public Key<DUser> owner;
	public int numSubscribers;
	public String websiteUrl;
	public String groupEmail;
	public String verificationCode;
	public boolean verified;
	
	public Subscription()
	{
		numSubscribers = 0;
		verificationCode = generateVerificationCode();
		verified = false;
	}
	
	private String generateVerificationCode()
	{
		Long x = System.nanoTime();
		x ^= (x << 21);
		x ^= (x >>> 35);
		x ^= (x << 4);
		return x.toString();
	}
	
	public void sendVerificationEmail()
	{
		String message = "Hello from deadline!\n\n" + owner.getName() + " selected the email address '" 
				+ groupEmail + "' to be notified when deadlines are posted or modified for the course '"
				+ name + "' (" + id + ").\n\nWe request " + owner.getName()
				+ " to click the following link to complete the verification procedure : " + 
				"http://deadlineapp.appspot.com/verify?verify-code=" + verificationCode + "&id=" + id
				+ "\n\nHave a great day!";

		SendEmail.sendCustomEmail("Course email verification required", message, groupEmail);
	}
}
