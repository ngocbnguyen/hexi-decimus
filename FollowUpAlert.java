package com.applicationtracker.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "follow_up_alerts")
public class FollowUpAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "alert_id")
    private Long alertId;

    @Column(name = "application_id", nullable = false)
    private Long applicationId;

    // Added user_id column mapping
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "alert_date", nullable = false)
    private LocalDateTime alertDate;

    @Column(nullable = false)
    private String message;

    @Column(name = "is_resolved")
    private boolean isResolved = false;

    // Default constructor
    public FollowUpAlert() {}

    // Getters and Setters
    public Long getAlertId() { 
        return alertId; 
    }
    
    public void setAlertId(Long alertId) { 
        this.alertId = alertId; 
    }

    public Long getApplicationId() { 
        return applicationId; 
    }
    
    public void setApplicationId(Long applicationId) { 
        this.applicationId = applicationId; 
    }

    // New Getter and Setter for userId
    public Long getUserId() { 
        return userId; 
    }
    
    public void setUserId(Long userId) { 
        this.userId = userId; 
    }

    public LocalDateTime getAlertDate() { 
        return alertDate; 
    }
    
    public void setAlertDate(LocalDateTime alertDate) { 
        this.alertDate = alertDate; 
    }

    public String getMessage() { 
        return message; 
    }
    
    public void setMessage(String message) { 
        this.message = message; 
    }

    public boolean isResolved() { 
        return isResolved; 
    }
    
    public void setResolved(boolean resolved) { 
        this.isResolved = resolved; 
    }
}