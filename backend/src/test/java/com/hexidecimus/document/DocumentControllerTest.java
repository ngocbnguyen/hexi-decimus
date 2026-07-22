package com.hexidecimus.document;
import com.hexidecimus.document.Document;
import com.hexidecimus.document.DocumentController;
import com.hexidecimus.document.DocumentService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;


import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DocumentController.class)
class DocumentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DocumentService documentService;

    // Scenario 1: POST /api/documents/upload returns HTTP 201 Created on valid upload.
    @Test
    void uploadDocument_validPdf_returnsCreated() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "Resume_2026.pdf",
                "application/pdf",
                "pdf content".getBytes()
        );

        Document savedDocument = new Document(1L, 1L, "Resume_2026.pdf", "application/pdf");
        when(documentService.upload(anyLong(), any())).thenReturn(savedDocument);

        mockMvc.perform(multipart("/api/documents/upload")
                        .file(file)
                        .param("userId", "1"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.fileName").value("Resume_2026.pdf"));

        verify(documentService, times(1)).upload(anyLong(), any());
    }

    // Scenario 2: POST /api/documents/upload returns HTTP 400 Bad Request for unsupported file.
    @Test
    void uploadDocument_unsupportedFileType_returnsBadRequest() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "script.exe",
                "application/octet-stream",
                "binary content".getBytes()
        );

        when(documentService.upload(anyLong(), any()))
                .thenThrow(new IllegalArgumentException("Unsupported file type. Use PDF, DOC, or DOCX."));

        mockMvc.perform(multipart("/api/documents/upload")
                        .file(file)
                        .param("userId", "1"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Unsupported file type. Use PDF, DOC, or DOCX."));
    }

    // Scenario 3: POST /api/documents/upload returns HTTP 400 Bad Request for empty file selection.
    @Test
    void uploadDocument_emptyFile_returnsBadRequest() throws Exception {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file",
                "",
                "application/pdf",
                new byte[0]
        );

        when(documentService.upload(anyLong(), any()))
                .thenThrow(new IllegalArgumentException("Please select a valid file to upload."));

        mockMvc.perform(multipart("/api/documents/upload")
                        .file(emptyFile)
                        .param("userId", "1"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Please select a valid file to upload."));
    }
}