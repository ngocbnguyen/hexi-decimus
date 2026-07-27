import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/document_service.dart';

class DocumentsView extends StatefulWidget {
  final Map<String, dynamic> user;

  const DocumentsView({
    super.key,
    required this.user,
  });

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allDocuments = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  String _selectedCategory = 'Resume';
  String _errorMessage = '';
  final _searchController = TextEditingController();

  // Form Fields for Upload Mock
  final _formKey = GlobalKey<FormState>();
  final _docNameController = TextEditingController();
  String _selectedUploadType = 'Resume';
  String _mockFileName = '';
  List<int> _mockFileBytes = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _docNameController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = widget.user['userId'] ?? 1;
      final docs = await DocumentService.fetchDocuments(userId);
      setState(() {
        _allDocuments = docs;
        _applyCategoryFilterAndSearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _applyCategoryFilterAndSearch();
  }

  void _applyCategoryFilterAndSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredDocuments = _allDocuments.where((doc) {
        final matchesCategory = doc['documentType'] == _selectedCategory;
        final matchesSearch = query.isEmpty ||
            (doc['fileName'] ?? '').toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyCategoryFilterAndSearch();
    });
  }

  void _showUploadDialog() {
    _docNameController.clear();
    _selectedUploadType = 'Resume';
    _mockFileName = '';
    _mockFileBytes = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Upload Document',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedUploadType,
                      decoration: const InputDecoration(labelText: 'Document Category'),
                      items: ['Resume', 'Cover Letter', 'Transcript', 'Certificate']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            _selectedUploadType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _docNameController,
                      decoration: const InputDecoration(
                        labelText: 'Document Name',
                        prefixIcon: Icon(Icons.description_outlined),
                        hintText: 'e.g. My_Google_Resume',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Document name is required' : null,
                    ),
                    const SizedBox(height: 20),
                    // Mock file selector button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 32, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          if (_mockFileName.isEmpty)
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  final cleanName = _docNameController.text.trim().replaceAll(RegExp(r'\s+'), '_');
                                  final namePrefix = cleanName.isNotEmpty ? cleanName : 'document';
                                  _mockFileName = '${namePrefix}_mock.pdf';
                                  _mockFileBytes = utf8.encode('Dummy Mock PDF File Content');
                                });
                              },
                              child: const Text('Generate Mock PDF File'),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _mockFileName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                  onPressed: () {
                                    setModalState(() {
                                      _mockFileName = '';
                                      _mockFileBytes = [];
                                    });
                                  },
                                )
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _mockFileName.isNotEmpty ? _submitUpload : null,
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitUpload() async {
    if (_formKey.currentState!.validate() && _mockFileBytes.isNotEmpty) {
      Navigator.pop(context); // Close dialog
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = widget.user['userId'] ?? 1;
        await DocumentService.uploadDocument(
          userId: userId,
          documentType: _selectedUploadType,
          fileName: _mockFileName,
          fileBytes: _mockFileBytes,
        );
        _loadDocuments();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _downloadDocument(int id) async {
    final downloadUrl = DocumentService.getDownloadUrl(id);
    final uri = Uri.parse(downloadUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open download link.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download error: $e')),
      );
    }
  }

  void _deleteDocument(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to permanently delete this document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await DocumentService.deleteDocument(id);
        _loadDocuments();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Count files per category
    final resumeCount = _allDocuments.where((d) => d['documentType'] == 'Resume').length;
    final coverLetterCount = _allDocuments.where((d) => d['documentType'] == 'Cover Letter').length;
    final transcriptCount = _allDocuments.where((d) => d['documentType'] == 'Transcript').length;
    final certificateCount = _allDocuments.where((d) => d['documentType'] == 'Certificate').length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Action Header
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search documents...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showUploadDialog,
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text('Upload File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
  
          // Grid/Row Folder cards matching Wireframe 4
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: _buildFolderCard('Resume', resumeCount, Icons.description, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildFolderCard('Cover Letter', coverLetterCount, Icons.mail_outline, Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildFolderCard('Transcript', transcriptCount, Icons.school_outlined, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildFolderCard('Certificate', certificateCount, Icons.card_membership_outlined, Colors.green)),
              ],
            ),
          ),
  
          // Files List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📂 Active Folder: $_selectedCategory',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
  
          // List of Documents in active folder
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
                    )
                  : _filteredDocuments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_zip_outlined, size: 56, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No documents in this folder.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          itemCount: _filteredDocuments.length,
                          itemBuilder: (context, index) {
                    final doc = _filteredDocuments[index];
                    final date = DateTime.tryParse(doc['uploadedAt'] ?? '') ?? DateTime.now();
                    final dateStr = '${date.month}/${date.day}/${date.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          doc['fileName'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Uploaded: $dateStr'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.blueAccent),
                              onPressed: () => _downloadDocument(doc['documentId']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _deleteDocument(doc['documentId']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFolderCard(String title, int count, IconData icon, Color color) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => _onCategorySelected(title),
      child: Card(
        color: isSelected ? color.withOpacity(0.08) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        elevation: isSelected ? 3 : 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '$count files',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
