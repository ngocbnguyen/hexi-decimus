package com.hexadecimus.tracker.repository;

import com.hexadecimus.tracker.entity.FollowUpAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface FollowUpAlertRepository extends JpaRepository<FollowUpAlert, Integer> {
    // Custom query to find alerts where the date has passed and email hasn't been sent
    @Query("SELECT a FROM FollowUpAlert a WHERE a.email_sent = 'false' AND a.follow_up_date <= CURRENT_TIMESTAMP")
    List<FollowUpAlert> findPendingAlerts();
}