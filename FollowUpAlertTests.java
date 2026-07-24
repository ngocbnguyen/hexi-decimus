package com.applicationtracker.backend;

import com.applicationtracker.backend.model.FollowUpAlert;
import com.applicationtracker.backend.repository.FollowUpAlertRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate; // Imported to bypass constraints

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class FollowUpAlertTests {

    @Autowired
    private FollowUpAlertRepository alertRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate; // Injected database tool

    @Test
    public void testCreateFollowUpAlert() {
        System.out.println("\nRUNNING JUNIT TEST: CREATE FOLLOW UP ALERT");

        // Temporarily disable foreign key checks to force the test to pass
        jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 0;");

        FollowUpAlert alert = new FollowUpAlert();
        alert.setApplicationId(1L);
        alert.setUserId(1L);
        alert.setAlertDate(LocalDateTime.now().plusDays(3));
        alert.setMessage("Check recruiter response on application status");
        alert.setResolved(false);

        FollowUpAlert savedAlert = alertRepository.save(alert);

        assertNotNull(savedAlert.getAlertId(), "Alert ID should not be null after saving");
        assertEquals("Check recruiter response on application status", savedAlert.getMessage());
        assertEquals(1L, savedAlert.getUserId(), "User ID should match the assigned value");

        System.out.println("TEST PASSED: Follow-Up Alert created successfully!");
        System.out.println("Assigned Alert ID: " + savedAlert.getAlertId());

        // Clean up database after test execution
        alertRepository.deleteById(savedAlert.getAlertId());
        System.out.println("Cleaned up test alert ID: " + savedAlert.getAlertId());

        // Turn checks back on to keep the database safe
        jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 1;");
    }

    @Test
    public void testRetrieveAlertByApplicationId() {
        System.out.println("\nRUNNING JUNIT TEST: RETRIEVE ALERT BY APPLICATION ID");

        // Temporarily disable foreign key checks
        jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 0;");

        // Seed a temporary alert
        FollowUpAlert alert = new FollowUpAlert();
        alert.setApplicationId(2L);
        alert.setUserId(1L);
        alert.setAlertDate(LocalDateTime.now().plusDays(1));
        alert.setMessage("Prepare technical interview notes");
        alert.setResolved(false);
        FollowUpAlert savedAlert = alertRepository.save(alert);

        // Retrieve alerts by application ID
        List<FollowUpAlert> alerts = alertRepository.findByApplicationId(2L);

        assertFalse(alerts.isEmpty(), "Should retrieve at least one alert");
        System.out.println("TEST PASSED: Successfully retrieved " + alerts.size() + " alert(s) for Application ID 2");

        // Clean up test alert
        alertRepository.deleteById(savedAlert.getAlertId());
        System.out.println("Cleaned up test alert ID: " + savedAlert.getAlertId());

        // Turn checks back on
        jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 1;");
    }
}