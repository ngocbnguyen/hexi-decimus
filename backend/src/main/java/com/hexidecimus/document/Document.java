package com.hexidecimus.document;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Document {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    private String fileName;
    private String fileType;

    public Document() {}

    public Document(Long id, Long userId, String fileName, String fileType) {
        this.id = id;
        this.userId = userId;
        this.fileName = fileName;
        this.fileType = fileType;
    }

    public Long getId() { return id; }
    public Long getUserId() { return userId; }
    public String getFileName() { return fileName; }
    public String getFileType() { return fileType; }
}