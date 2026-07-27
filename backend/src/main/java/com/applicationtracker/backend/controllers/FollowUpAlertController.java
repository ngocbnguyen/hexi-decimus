package com.applicationtracker.backend.controllers;

import com.applicationtracker.backend.models.FollowUpAlert;
import com.applicationtracker.backend.repositories.FollowUpAlertRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/alerts")
@CrossOrigin(origins = "*")
public class FollowUpAlertController {

    @Autowired
    private FollowUpAlertRepository alertRepository;

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<FollowUpAlert>> getUserAlerts(@PathVariable Integer userId) {
        List<FollowUpAlert> alerts = alertRepository.findByUserId(userId);
        return ResponseEntity.ok(alerts);
    }

    @PostMapping
    public ResponseEntity<FollowUpAlert> saveAlert(@RequestBody FollowUpAlert alert) {
        // If isSent/isResolved are null, set defaults
        if (alert.getIsSent() == null) {
            alert.setIsSent(false);
        }
        if (alert.getIsResolved() == null) {
            alert.setIsResolved(false);
        }
        FollowUpAlert saved = alertRepository.save(alert);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAlert(@PathVariable Long id) {
        return alertRepository.findById(id).map(alert -> {
            alertRepository.delete(alert);
            return ResponseEntity.ok().body("Alert deleted successfully");
        }).orElse(ResponseEntity.notFound().build());
    }
}
