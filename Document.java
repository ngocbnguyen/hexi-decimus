package com.hexadecimus.tracker.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "documents")
public class Document {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer document_id;

    private String document_type;
    private String file_name;
    private String file_path;
    
    private LocalDateTime uploaded_at;
    private Integer users_user_id;

    @PrePersist
    protected void onCreate() {
        this.uploaded_at = LocalDateTime.now();
    }

    // Generate your Getters and Setters here
    public Integer getDocument_id() { return document_id; }
    public void setDocument_id(Integer document_id) { this.document_id = document_id; }
    public String getFile_path() { return file_path; }
    public void setFile_path(String file_path) { this.file_path = file_path; }
    public String getFile_name() { return file_name; }
    public void setFile_name(String file_name) { this.file_name = file_name; }
    public Integer getUsers_user_id() { return users_user_id; }
    public void setUsers_user_id(Integer users_user_id) { this.users_user_id = users_user_id; }
    public String getDocument_type() { return document_type; }
    public void setDocument_type(String document_type) { this.document_type = document_type; }
}