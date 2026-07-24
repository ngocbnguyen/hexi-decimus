package com.applicationtracker.backend.repository;

import com.applicationtracker.backend.model.FollowUpAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface FollowUpAlertRepository extends JpaRepository<FollowUpAlert, Long> {
    
    List<FollowUpAlert> findByApplicationId(Long applicationId);
    
    List<FollowUpAlert> findByIsResolvedFalse();
}