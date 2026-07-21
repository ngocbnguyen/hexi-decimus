package com.applicationtracker.backend.services;

import com.applicationtracker.backend.models.ApplicationStatusHistory;
import com.applicationtracker.backend.models.JobApplication;
import com.applicationtracker.backend.repositories.ApplicationStatusHistoryRepository;
import com.applicationtracker.backend.repositories.JobApplicationRepository;
import com.applicationtracker.backend.specifications.JobApplicationSpecs;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class JobApplicationService {

    private final JobApplicationRepository repository;
    private final ApplicationStatusHistoryRepository historyRepository;

    public JobApplicationService(JobApplicationRepository repository,
                                 ApplicationStatusHistoryRepository historyRepository) {
        this.repository = repository;
        this.historyRepository = historyRepository;
    }

    public List<JobApplication> getFilteredAndSorted(
            String status,
            String companyName,
            String jobTitle,
            String sortField,
            String sortOrder
    ) {
        Specification<JobApplication> spec = Specification.where(
                JobApplicationSpecs.hasStatus(status)
        ).and(JobApplicationSpecs.hasCompanyName(companyName))
         .and(JobApplicationSpecs.hasJobTitle(jobTitle));

        Sort sort = Sort.unsorted();

        if (sortField != null && sortOrder != null) {
            sort = sortOrder.equalsIgnoreCase("desc")
                    ? Sort.by(sortField).descending()
                    : Sort.by(sortField).ascending();
        }

        return repository.findAll(spec, sort);
    }

    public List<ApplicationStatusHistory> getHistory(Long applicationId) {
        return historyRepository.findByApplicationIdOrderByChangedAtDesc(applicationId);
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

        if (updated.getStatus() != null &&
            !updated.getStatus().equals(existing.getStatus())) {

            ApplicationStatusHistory history = new ApplicationStatusHistory(
                    existing.getApplicationId(),
                    existing.getStatus(),
                    updated.getStatus(),
                    LocalDateTime.now()
            );

            historyRepository.save(history);
        }

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
