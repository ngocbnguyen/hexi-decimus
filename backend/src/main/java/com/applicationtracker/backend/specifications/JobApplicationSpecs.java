package com.applicationtracker.backend.specifications;

import com.applicationtracker.backend.models.JobApplication;
import org.springframework.data.jpa.domain.Specification;

public class JobApplicationSpecs {

    public static Specification<JobApplication> hasStatus(String status) {
        return (root, query, builder) ->
                status == null ? null : builder.equal(root.get("status"), status);
    }

    public static Specification<JobApplication> hasCompanyName(String companyName) {
        return (root, query, builder) ->
                companyName == null ? null : builder.like(
                        builder.lower(root.get("companyName")),
                        "%" + companyName.toLowerCase() + "%"
                );
    }

    public static Specification<JobApplication> hasJobTitle(String jobTitle) {
        return (root, query, builder) ->
                jobTitle == null ? null : builder.like(
                        builder.lower(root.get("jobTitle")),
                        "%" + jobTitle.toLowerCase() + "%"
                );
    }
}
