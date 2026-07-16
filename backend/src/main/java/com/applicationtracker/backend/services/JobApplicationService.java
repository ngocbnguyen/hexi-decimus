package com.applicationtracker.backend.services;

import com.applicationtracker.backend.models.JobApplication;
import com.applicationtracker.backend.repositories.JobApplicationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JobApplicationService {

    private final JobApplicationRepository repository;

    public JobApplicationService(JobApplicationRepository repository) {
        this.repository = repository;
    }

    public List<JobApplication> getAll() {
        return repository.findAll();
    }

    public JobApplication getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Application not found"));
    }

    public JobApplication create(JobApplication application) {
        return repository.save(application);
    }

    public JobApplication update(Long id, JobApplication updated) {
        JobApplication existing = getById(id);

        existing.setCompanyName(updated.getCompanyName());
        existing.setJobTitle(updated.getJobTitle());
        existing.setPortalLink(updated.getPortalLink());
        existing.setContactName(updated.getContactName());
        existing.setContactEmail(updated.getContactEmail());
        existing.setApplicationDate(updated.getApplicationDate());
        existing.setStatus(updated.getStatus());
        existing.setNotes(updated.getNotes());
        existing.setUserId(updated.getUserId());

        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
