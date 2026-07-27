package com.applicationtracker.backend.controllers;

import com.applicationtracker.backend.models.Document;
import com.applicationtracker.backend.repositories.DocumentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("/api/documents")
@CrossOrigin(origins = "*")
public class DocumentController {

    private final Path fileStorageLocation;

    @Autowired
    private DocumentRepository documentRepository;

    public DocumentController() {
        // Set storage location to 'backend/uploads' directory in the project
        this.fileStorageLocation = Paths.get("uploads").toAbsolutePath().normalize();
        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (IOException ex) {
            throw new RuntimeException("Could not create the directory where the uploaded files will be stored.", ex);
        }
    }

    @PostMapping("/upload")
    public ResponseEntity<?> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Integer userId,
            @RequestParam("documentType") String documentType) {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("File is empty");
        }

        try {
            // Create unique file name
            String originalFileName = file.getOriginalFilename();
            String fileName = System.currentTimeMillis() + "_" + (originalFileName != null ? originalFileName.replaceAll("\\s+", "_") : "document");
            Path targetLocation = this.fileStorageLocation.resolve(fileName);
            
            // Save file physically to storage location
            Files.copy(file.getInputStream(), targetLocation);

            // Save metadata in database table
            Document doc = new Document();
            doc.setUserId(userId);
            doc.setDocumentType(documentType);
            doc.setFileName(originalFileName);
            doc.setFileUrl(fileName); // We store the unique filename as key to load/download

            Document saved = documentRepository.save(doc);
            return ResponseEntity.ok(saved);

        } catch (IOException ex) {
            return ResponseEntity.internalServerError().body("Failed to upload file: " + ex.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Document>> getUserDocuments(@PathVariable Integer userId) {
        List<Document> docs = documentRepository.findByUserId(userId);
        return ResponseEntity.ok(docs);
    }

    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> downloadDocument(@PathVariable Integer id) {
        try {
            Document doc = documentRepository.findById(id)
                    .orElseThrow(() -> new FileNotFoundException("Document record not found"));

            Path filePath = this.fileStorageLocation.resolve(doc.getFileUrl()).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists()) {
                String contentType = "application/octet-stream";
                try {
                    contentType = Files.probeContentType(filePath);
                    if (contentType == null) {
                        contentType = "application/octet-stream";
                    }
                } catch (IOException ex) {
                    // fallback to octet-stream
                }

                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + doc.getFileName() + "\"")
                        .body(resource);
            } else {
                throw new FileNotFoundException("File not found on server disk");
            }
        } catch (Exception ex) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDocument(@PathVariable Integer id) {
        return documentRepository.findById(id).map(doc -> {
            try {
                // Delete physical file
                Path filePath = this.fileStorageLocation.resolve(doc.getFileUrl()).normalize();
                Files.deleteIfExists(filePath);
                
                // Delete database record
                documentRepository.delete(doc);
                return ResponseEntity.ok().body("Document deleted successfully");
            } catch (IOException ex) {
                return ResponseEntity.internalServerError().body("Failed to delete physical file: " + ex.getMessage());
            }
        }).orElse(ResponseEntity.notFound().build());
    }
}
