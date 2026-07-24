package com.hexadecimus.tracker.service;

import com.hexadecimus.tracker.entity.FollowUpAlert;
import com.hexadecimus.tracker.repository.FollowUpAlertRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class EmailReminderService {

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private FollowUpAlertRepository alertRepository;

    // Runs every day at 8:00 AM server time
    @Scheduled(cron = "0 0 8 * * ?")
    public void processReminders() {
        // 1. Fetch pending alerts from the DBeaver table
        List<FollowUpAlert> pendingAlerts = alertRepository.findPendingAlerts();

        for (FollowUpAlert alert : pendingAlerts) {
            try {
                // 2. Build and send the email
                SimpleMailMessage message = new SimpleMailMessage();
                // Note: In a real app, you'd join with the Users table to get their actual email
                message.setTo("testuser@example.com"); 
                message.setSubject("Job Tracker: Follow Up Reminder");
                message.setText("Reminder: It is time to follow up on Application ID: " + alert.getAlert_id());
                
                mailSender.send(message);

                // 3. Update the DBeaver table to reflect the sent status
                alert.setEmail_sent("true"); // Matches the VARCHAR from the ER diagram
                alert.setSent_at(LocalDateTime.now().toString());
                
                alertRepository.save(alert); // <-- This executes the SQL UPDATE

                System.out.println("Successfully processed alert ID: " + alert.getAlert_id());

            } catch (Exception e) {
                System.err.println("Failed to send alert ID " + alert.getAlert_id() + ": " + e.getMessage());
            }
        }
    }
}