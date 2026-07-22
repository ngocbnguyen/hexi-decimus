package com.hexidecimus.document;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DocumentService {

    private final DocumentRepository documentRepository;

    @Autowired
    public DocumentService(DocumentRepository documentRepository) {
        this.documentRepository = documentRepository;
    }

    public Document upload(Long userId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("The uploaded file is empty. Please select a valid file to upload.");
        }

        String fileName = file.getOriginalFilename();
        if (fileName != null && fileName.endsWith(".exe")) {
            throw new IllegalArgumentException("Unsupported file type. Use PDF, DOC, or DOCX.");
        }

        if (file.getSize() > 10 * 1024 * 1024) {
            throw new IllegalArgumentException("File exceeds the maximum allowed size of 10MB.");
        }

        Document document = new Document(null, userId, fileName, file.getContentType());
        return documentRepository.save(document);
    }
}