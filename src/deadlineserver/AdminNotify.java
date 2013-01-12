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

public class AdminNotify
{
	private static final Logger log = Logger.getLogger(AdminNotify.class.getName());
	/*
	public static void NotifyAdminsByEmail(String subject, String message, String severity)
	{
		log.setLevel(Level.INFO);
		Properties props = new Properties();
        Session session = Session.getDefaultInstance(props, null);
       
        boolean successfulSend = false;
        
        try 
        {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress("support@whatsnextup.com", "WNU Notification Service"));
            
            msg.addRecipient(Message.RecipientType.TO,
                             new InternetAddress("raghav@whatsnextup.com", "Raghav Sethi"));
            msg.addRecipient(Message.RecipientType.TO,
                    new InternetAddress("mayank@whatsnextup.com", "Mayank Pundir"));
            
            msg.setSubject("WNU " + severity + " alert: " + subject);
            msg.setText(message + "\n\nGenerated automatically by WNU servers at " + new Date());
            
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
        	log.info("Successfully sent email to admins.");
        
	}*/
}
