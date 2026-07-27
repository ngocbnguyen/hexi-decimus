package com.hexadecimus.tracker.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "follow_up_alerts")
public class FollowUpAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer alert_id;

    private Integer application_id;
    private LocalDateTime follow_up_date;
    
    // Kept as VARCHAR/String to match your team's ER diagram
    private String email_sent = "false"; 
    private String sent_at;

    // Generate your Getters and Setters here
    public Integer getAlert_id() { return alert_id; }
    public void setAlert_id(Integer alert_id) { this.alert_id = alert_id; }
    public String getEmail_sent() { return email_sent; }
    public void setEmail_sent(String email_sent) { this.email_sent = email_sent; }
    public String getSent_at() { return sent_at; }
    public void setSent_at(String sent_at) { this.sent_at = sent_at; }
}