package com.applicationtracker.backend.controllers;

import com.applicationtracker.backend.models.ApplicationStatusHistory;
import com.applicationtracker.backend.models.JobApplication;
import com.applicationtracker.backend.services.JobApplicationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/applications")
@CrossOrigin("*")
public class JobApplicationController {

    private final JobApplicationService service;

    public JobApplicationController(JobApplicationService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<JobApplication>> getAll(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String companyName,
            @RequestParam(required = false) String jobTitle,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order
    ) {
        return ResponseEntity.ok(
            service.getFilteredAndSorted(status, companyName, jobTitle, sort, order)
        );
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<List<ApplicationStatusHistory>> getHistory(@PathVariable Long id) {
        return ResponseEntity.ok(service.getHistory(id));
    }

    @PostMapping
    public ResponseEntity<JobApplication> create(@RequestBody JobApplication application) {
        return ResponseEntity.ok(service.create(application));
    }

    @PutMapping("/{id}")
    public ResponseEntity<JobApplication> update(@PathVariable Long id,
                                                 @RequestBody JobApplication updated) {
        return ResponseEntity.ok(service.update(id, updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok("Application deleted");
    }
}
