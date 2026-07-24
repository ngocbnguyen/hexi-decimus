package com.hexadecimus.tracker.controller;

import com.hexadecimus.tracker.entity.Document;
import com.hexadecimus.tracker.repository.DocumentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {

    private final String UPLOAD_DIR = "uploads/";

    @Autowired
    private DocumentRepository documentRepository;

    @PostMapping("/upload")
    public ResponseEntity<String> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Integer userId,
            @RequestParam("documentType") String documentType) {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("File is empty");
        }

        try {
            // 1. Create directory if it doesn't exist
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // 2. Save file to the local system
            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            file.transferTo(filePath);

            // 3. Save the record into the DBeaver 'documents' table
            Document doc = new Document();
            doc.setFile_name(file.getOriginalFilename());
            doc.setFile_path(filePath.toString());
            doc.setUsers_user_id(userId);
            doc.setDocument_type(documentType);
            
            documentRepository.save(doc); // <-- This executes the SQL INSERT

            return ResponseEntity.ok("File uploaded and saved to database successfully.");

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Upload failed: " + e.getMessage());
        }
    }
}