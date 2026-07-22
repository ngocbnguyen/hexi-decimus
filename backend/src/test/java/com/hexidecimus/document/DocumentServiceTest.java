package com.hexidecimus.document;
import com.hexidecimus.document.Document;
import com.hexidecimus.document.DocumentRepository;
import com.hexidecimus.document.DocumentService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import com.hexidecimus.document.Document;
import com.hexidecimus.document.DocumentService;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DocumentServiceTest {

    @Mock
    private DocumentRepository documentRepository;

    @InjectMocks
    private DocumentService documentService;

    private final long USER_ID = 1L;

    // Test Case 1: Valid PDF upload
    @Test
    void upload_validPdfResume_savesDocumentSuccessfully() {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "Resume_2026.pdf",
                "application/pdf",
                "sample pdf content".getBytes()
        );

        Document savedDocument = new Document(1L, USER_ID, "Resume_2026.pdf", "application/pdf");
        when(documentRepository.save(any(Document.class))).thenReturn(savedDocument);

        Document result = documentService.upload(USER_ID, file);

        assertNotNull(result);
        assertEquals("Resume_2026.pdf", result.getFileName());
        verify(documentRepository, times(1)).save(any(Document.class));
    }

    // Test Case 2: Unsupported file format (.exe)
    @Test
    void upload_unsupportedFileType_throwsExceptionAndDoesNotSave() {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "script.exe",
                "application/octet-stream",
                "binary content".getBytes()
        );

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> documentService.upload(USER_ID, file)
        );

        assertTrue(exception.getMessage().toLowerCase().contains("unsupported"));
        verify(documentRepository, never()).save(any(Document.class));
    }

    // Test Case 3: File exceeds max size (11 MB)
    @Test
    void upload_fileExceedsMaxSize_throwsExceptionAndDoesNotSave() {
        byte[] oversizedContent = new byte[11 * 1024 * 1024]; // 11MB
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "Large_Resume.pdf",
                "application/pdf",
                oversizedContent
        );

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> documentService.upload(USER_ID, file)
        );

        assertTrue(exception.getMessage().toLowerCase().contains("size"));
        verify(documentRepository, never()).save(any(Document.class));
    }

    // Test Case 4: Empty file selection
    @Test
    void upload_emptyFile_throwsExceptionAndDoesNotSave() {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "empty.pdf",
                "application/pdf",
                new byte[0]
        );

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> documentService.upload(USER_ID, file)
        );

        assertTrue(exception.getMessage().toLowerCase().contains("empty"));
        verify(documentRepository, never()).save(any(Document.class));
    }
}