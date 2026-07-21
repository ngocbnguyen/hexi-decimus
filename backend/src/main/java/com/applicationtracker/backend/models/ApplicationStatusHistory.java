package com.applicationtracker.backend.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "applicationStatusHistory")  // match your SQL table name EXACTLY
public class ApplicationStatusHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "history_id")
    private Long historyId;

    @Column(name = "application_id", nullable = false)
    private Long applicationId;

    @Column(name = "old_status", length = 45)
    private String oldStatus;

    @Column(name = "new_status", length = 45)
    private String newStatus;

    @Column(name = "changed_at")
    private LocalDateTime changedAt;

    public ApplicationStatusHistory() {}

    public ApplicationStatusHistory(Long applicationId, String oldStatus, String newStatus, LocalDateTime changedAt) {
        this.applicationId = applicationId;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.changedAt = changedAt;
    }

    public Long getHistoryId() {
        return historyId;
    }

    public Long getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(Long applicationId) {
        this.applicationId = applicationId;
    }

    public String getOldStatus() {
        return oldStatus;
    }

    public void setOldStatus(String oldStatus) {
        this.oldStatus = oldStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }
}
