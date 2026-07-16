package com.applicationtracker.backend.models;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "job_applications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
}
