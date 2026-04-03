import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({super.key});

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  UserProfile? _adminProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedDepartment = AppTheme.departments[0];
  int _selectedYear = 1;

  final List<String> _departments = AppTheme.departments;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = await _authService.currentUserId;
    if (userId != null) {
      _adminProfile = await _authService.getUserProfile(userId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      final success = await _adminService.addStudent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        registerNumber: _regNumberController.text.trim(),
        department: _selectedDepartment,
        year: _selectedYear,
        initialPassword: _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student added successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add student. Check if email already exists.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _regNumberController.clear();
    _passwordController.clear();
    setState(() {
      _selectedDepartment = AppTheme.departments[0];
      _selectedYear = 1;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _pickAndUploadCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() => _isSaving = true);
        
        final Uint8List? fileBytes = result.files.first.bytes;
        final String csvData;

        if (kIsWeb) {
          csvData = utf8.decode(fileBytes!);
        } else {
          final file = File(result.files.first.path!);
          csvData = await file.readAsString();
        }

        final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
        
        if (rows.length < 2) {
          throw 'CSV file is empty or missing headers';
        }

        // Assume headers: name, email, register_number, department, year, password
        final headers = rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
        
        List<Map<String, dynamic>> students = [];
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length < headers.length) continue;

          Map<String, dynamic> student = {};
          for (int j = 0; j < headers.length; j++) {
            var value = row[j];
            String header = headers[j];
            
            if (header == 'year') {
              student[header] = int.tryParse(value.toString()) ?? 1;
            } else {
              student[header] = value.toString().trim();
            }
          }
          
          // Basic validation for required fields
          if (student['email'] != null && student['email'].contains('@')) {
            // If password is missing, use register_number as default password
            if (student['password'] == null || student['password'].toString().isEmpty) {
              student['password'] = student['register_number'] ?? '123456';
            }
            students.add(student);
          }
        }

        if (students.isEmpty) {
          throw 'No valid student records found in CSV';
        }

        final report = await _adminService.bulkAddStudents(students);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Bulk Upload Complete'),
              content: Text('Successfully added: ${report['success']}\nFailed to add: ${report['failed']}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentRoute: '/admin/add-students',
            items: [
              SidebarItem(icon: Icons.dashboard, label: 'Dashboard', route: '/admin/dashboard'),
              SidebarItem(icon: Icons.people, label: 'Students', route: '/admin/students'),
              SidebarItem(icon: Icons.search, label: 'Skill Search', route: '/admin/skill-search'),
              SidebarItem(icon: Icons.assignment, label: 'Assign Internship', route: '/admin/assign-internship'),
              SidebarItem(icon: Icons.verified, label: 'Verify Certificates', route: '/admin/verify-certificates'),
              SidebarItem(icon: Icons.person_add, label: 'Add Students', route: '/admin/add-students'),
              SidebarItem(icon: Icons.analytics, label: 'Reports', route: '/admin/reports'),
            ],
            onLogout: _handleLogout,
            userName: _adminProfile?.name ?? 'Admin',
            userEmail: _adminProfile?.email ?? '',
          ),
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Add Students',
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Register new students individually or in bulk',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Single Registration Form
                              Expanded(
                                flex: 3,
                                child: _buildSingleAddCard(),
                              ),
                              const SizedBox(width: 32),
                              // Bulk Upload Info
                              Expanded(
                                flex: 2,
                                child: _buildBulkUploadCard(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleAddCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Text('Single Student Registration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _regNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Register Number',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (v) => v!.isEmpty ? 'Register number is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Initial Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (v) => v!.length < 6 ? 'Password must be at least 6 chars' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business)),
                      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _selectedDepartment = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: 'Year', prefixIcon: Icon(Icons.calendar_today)),
                      items: [1, 2, 3, 4].map((y) => DropdownMenuItem(value: y, child: Text('Year $y'))).toList(),
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _addStudent,
                  icon: _isSaving 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.person_add),
                  label: Text(_isSaving ? 'Processing...' : 'Register Student'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulkUploadCard() {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.file_upload_outlined, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('Bulk Upload', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload a CSV file containing student details to register multiple accounts at once.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text('Required columns:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• name\n• email\n• register_number\n• department\n• year', style: TextStyle(height: 1.5)),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickAndUploadCsv,
              icon: _isSaving 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload_file),
              label: Text(_isSaving ? 'Uploading...' : 'Select CSV File'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Sample Template'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _regNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
