package com.applicationtracker.backend.repositories;

import com.applicationtracker.backend.models.FollowUpAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface FollowUpAlertRepository extends JpaRepository<FollowUpAlert, Long> {
    List<FollowUpAlert> findByUserId(Integer userId);
    List<FollowUpAlert> findByIsSentFalseAndAlertDateLessThanEqual(LocalDateTime dateTime);
}
