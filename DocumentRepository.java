package com.hexadecimus.tracker.repository;

import com.hexadecimus.tracker.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DocumentRepository extends JpaRepository<Document, Integer> {
}