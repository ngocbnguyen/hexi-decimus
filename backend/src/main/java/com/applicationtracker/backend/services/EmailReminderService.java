package com.applicationtracker.backend.services;

import com.applicationtracker.backend.models.FollowUpAlert;
import com.applicationtracker.backend.repositories.FollowUpAlertRepository;
import com.applicationtracker.backend.model.User;
import com.applicationtracker.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class EmailReminderService {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Autowired
    private FollowUpAlertRepository alertRepository;

    @Autowired
    private UserRepository userRepository;

    // Runs every 60 seconds for demonstration and testing purposes
    @Scheduled(fixedRate = 60000)
    public void processReminders() {
        LocalDateTime now = LocalDateTime.now();
        List<FollowUpAlert> pendingAlerts = alertRepository.findByIsSentFalseAndAlertDateLessThanEqual(now);

        if (pendingAlerts.isEmpty()) {
            return;
        }

        System.out.println("⏰ [EmailReminderService] Found " + pendingAlerts.size() + " pending follow-up alerts to process.");

        for (FollowUpAlert alert : pendingAlerts) {
            try {
                // Fetch user dynamically
                String recipientEmail = "student@gsu.edu";
                if (alert.getUserId() != null) {
                    User user = userRepository.findById(alert.getUserId()).orElse(null);
                    if (user != null && user.getEmail() != null) {
                        recipientEmail = user.getEmail();
                    }
                }

                // If mailSender is configured, send a real email
                if (mailSender != null) {
                    SimpleMailMessage message = new SimpleMailMessage();
                    message.setTo(recipientEmail);
                    message.setSubject("Application Tracker: Follow-up Reminder");
                    message.setText("Hi,\n\nThis is a reminder to follow up on your job application:\n" +
                            "Alert Message: " + alert.getMessage() + "\n" +
                            "Date: " + alert.getAlertDate() + "\n\nBest of luck!\nApplication Tracker Team");
                    
                    mailSender.send(message);
                    System.out.println("✉️ Sent email reminder to " + recipientEmail + " for Alert ID: " + alert.getAlertId());
                } else {
                    System.out.println("⚠️ JavaMailSender not configured. Skipping email delivery to " + recipientEmail + " for Alert ID: " + alert.getAlertId());
                }

                // Mark as sent in database
                alert.setIsSent(true);
                alertRepository.save(alert);

            } catch (Exception e) {
                System.err.println("❌ Failed to process reminder for Alert ID: " + alert.getAlertId() + ". Error: " + e.getMessage());
            }
        }
    }
}
