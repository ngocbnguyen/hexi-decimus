package com.applicationtracker.backend.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "job_applications")
public class JobApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long applicationId;

    @Column(nullable = false, length = 45)
    private String companyName;

    @Column(nullable = false, length = 45)
    private String jobTitle;

    @Column(length = 255)
    private String portalLink;

    @Column(length = 45)
    private String contactName;

    @Column(length = 45)
    private String contactEmail;

    private LocalDateTime applicationDate;

    @Column(length = 45)
    private String status;

    @Column(length = 255)
    private String notes;

    @Column(nullable = false)
    private Long userId; // FK to users table

    // Constructors
    public JobApplication() {}

    public JobApplication(Long applicationId, String companyName, String jobTitle, String portalLink, 
                          String contactName, String contactEmail, LocalDateTime applicationDate, 
                          String status, String notes, Long userId) {
        this.applicationId = applicationId;
        this.companyName = companyName;
        this.jobTitle = jobTitle;
        this.portalLink = portalLink;
        this.contactName = contactName;
        this.contactEmail = contactEmail;
        this.applicationDate = applicationDate;
        this.status = status;
        this.notes = notes;
        this.userId = userId;
    }

    // Getters and Setters
    public Long getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(Long applicationId) {
        this.applicationId = applicationId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getJobTitle() {
        return jobTitle;
    }

    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
    }

    public String getPortalLink() {
        return portalLink;
    }

    public void setPortalLink(String portalLink) {
        this.portalLink = portalLink;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public LocalDateTime getApplicationDate() {
        return applicationDate;
    }

    public void setApplicationDate(LocalDateTime applicationDate) {
        this.applicationDate = applicationDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    // Builder pattern (to maintain compatibility if any builder was used)
    public static JobApplicationBuilder builder() {
        return new JobApplicationBuilder();
    }

    public static class JobApplicationBuilder {
        private Long applicationId;
        private String companyName;
        private String jobTitle;
        private String portalLink;
        private String contactName;
        private String contactEmail;
        private LocalDateTime applicationDate;
        private String status;
        private String notes;
        private Long userId;

        public JobApplicationBuilder applicationId(Long applicationId) {
            this.applicationId = applicationId;
            return this;
        }

        public JobApplicationBuilder companyName(String companyName) {
            this.companyName = companyName;
            return this;
        }

        public JobApplicationBuilder jobTitle(String jobTitle) {
            this.jobTitle = jobTitle;
            return this;
        }

        public JobApplicationBuilder portalLink(String portalLink) {
            this.portalLink = portalLink;
            return this;
        }

        public JobApplicationBuilder contactName(String contactName) {
            this.contactName = contactName;
            return this;
        }

        public JobApplicationBuilder contactEmail(String contactEmail) {
            this.contactEmail = contactEmail;
            return this;
        }

        public JobApplicationBuilder applicationDate(LocalDateTime applicationDate) {
            this.applicationDate = applicationDate;
            return this;
        }

        public JobApplicationBuilder status(String status) {
            this.status = status;
            return this;
        }

        public JobApplicationBuilder notes(String notes) {
            this.notes = notes;
            return this;
        }

        public JobApplicationBuilder userId(Long userId) {
            this.userId = userId;
            return this;
        }

        public JobApplication build() {
            return new JobApplication(applicationId, companyName, jobTitle, portalLink, contactName, 
                                      contactEmail, applicationDate, status, notes, userId);
        }
    }
}
