package deadlineserver;

import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class SendEmail
{
	private static final Logger log = Logger.getLogger(SendEmail.class.getName());
	
	public static void sendCustomEmail(String subject, String message, String to)
	{
		log.setLevel(Level.INFO);
		Properties props = new Properties();
        Session session = Session.getDefaultInstance(props, null);
       
        boolean successfulSend = false;
        
        try 
        {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress("iiitd.deadline@gmail.com", "IIIT-D Deadline Service"));
            
            msg.addRecipient(Message.RecipientType.TO,
                             new InternetAddress(to));
            
            msg.setSubject(subject);
            msg.setText(message);
            
            Transport.send(msg);
            successfulSend = true;

        } catch (AddressException e) {
        	log.severe(e.toString());
        } catch (MessagingException e) {
        	log.severe(e.toString());
        } catch (UnsupportedEncodingException e) {
        	log.severe(e.toString());
		}
        
        if(successfulSend)
        	log.info("Successfully sent email.");
        
	}
}
