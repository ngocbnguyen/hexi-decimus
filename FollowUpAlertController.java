package com.applicationtracker.backend.controller;

import com.applicationtracker.backend.model.FollowUpAlert;
import com.applicationtracker.backend.repository.FollowUpAlertRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/alerts")
public class FollowUpAlertController {

    @Autowired
    private FollowUpAlertRepository alertRepository;

    // Create a new follow-up alert
    @PostMapping
    public ResponseEntity<FollowUpAlert> createAlert(@RequestBody FollowUpAlert alert) {
        FollowUpAlert savedAlert = alertRepository.save(alert);
        return ResponseEntity.ok(savedAlert);
    }

    // Get all alerts for a specific application
    @GetMapping("/application/{applicationId}")
    public ResponseEntity<List<FollowUpAlert>> getAlertsByApplication(@PathVariable Long applicationId) {
        List<FollowUpAlert> alerts = alertRepository.findByApplicationId(applicationId);
        return ResponseEntity.ok(alerts);
    }

    // Mark an alert as resolved
    @PutMapping("/{alertId}/resolve")
    public ResponseEntity<FollowUpAlert> resolveAlert(@PathVariable Long alertId) {
        return alertRepository.findById(alertId).map(alert -> {
            alert.setResolved(true);
            FollowUpAlert updatedAlert = alertRepository.save(alert);
            return ResponseEntity.ok(updatedAlert);
        }).orElse(ResponseEntity.notFound().build());
    }
}