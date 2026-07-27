package com.applicationtracker.backend.repositories;

import com.applicationtracker.backend.models.JobApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface JobApplicationRepository  
        extends JpaRepository<JobApplication, Integer>,
                JpaSpecificationExecutor<JobApplication> {

    List<JobApplication> findByUserId(Integer userId);

    List<JobApplication> findByStatus(String status);

}
