# 🎓 InternInfo - College Internship Management System

A comprehensive web application built with **Flutter Web** and **Supabase** for managing student internships, skills tracking, and certificate verification in colleges.

---

## 🚀 **Features**

### **For Students**
- ✅ **Dashboard** - Overview of profile completion, skills, internships, and notifications
- ✅ **Profile Management** - Edit personal information and academic details
- ✅ **Skills Management** - Add, edit, and delete technical/professional skills
- 📄 **Resume Upload** - Upload and manage resume (PDF)
- 📜 **Certificates** - Upload certificates and track verification status
- 💼 **Internship Tracking** - View assigned internships and update progress
- 🔔 **Notifications** - Receive updates on internships and certificate verifications

### **For Admins**
- ✅ **Admin Dashboard** - System-wide statistics and overview
- 👥 **Student Management** - View and manage all student profiles
- 🔍 **Skill-Based Search** - Find students by specific skills and levels
- 📋 **Internship Assignment** - Create and assign internships to students
- ✅ **Certificate Verification** - Verify or reject student certificates
- ➕ **Student Account Creation** - Add students individually or via CSV
- 📊 **Reports & Analytics** - Export data and view statistics

---

## 🛠️ **Technology Stack**

- **Frontend**: Flutter Web
- **Backend**: Supabase
  - Authentication
  - PostgreSQL Database
  - Row Level Security (RLS)
  - File Storage
- **State Management**: Provider (built-in)
- **UI/UX**: Material Design 3

---

## 📦 **Installation & Setup**

### **Prerequisites**
- Flutter SDK (3.9.2 or higher)
- Chrome/Edge browser for web development
- Supabase account

### **1. Clone the Repository**
```bash
cd d:\Flutter_Project\interninfo
```

### **2. Install Dependencies**
```bash
flutter pub get
```

### **3. Supabase Configuration**
The Supabase project is already configured in `lib/config/supabase_config.dart`:
- **URL**: `https://eqrxzrfpjzqqlbvgwesx.supabase.co`
- **Anon Key**: Already configured

### **4. Database Setup**
The database schema has been automatically created with:
- ✅ All tables (profiles, skills, internships, certificates, notifications)
- ✅ Row Level Security policies
- ✅ Storage buckets (resumes, certificates)
- ✅ Indexes and triggers

### **5. Create Test Users**
Run the SQL script in Supabase SQL Editor to create test accounts:

```sql
-- Create Admin User
INSERT INTO auth.users (id, email)
VALUES ('00000000-0000-0000-0000-000000000001', 'admin@college.edu')
ON CONFLICT DO NOTHING;

INSERT INTO profiles (id, name, email, role)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Admin User',
  'admin@college.edu',
  'admin'
) ON CONFLICT DO NOTHING;

-- Create Student User
INSERT INTO auth.users (id, email)
VALUES ('00000000-0000-0000-0000-000000000002', 'student@college.edu')
ON CONFLICT DO NOTHING;

INSERT INTO profiles (id, name, email, register_number, department, year, role)
VALUES (
  '00000000-0000-0000-0000-000000000002',
  'John Doe',
  'student@college.edu',
  'CS2021001',
  'Computer Science',
  3,
  'student'
) ON CONFLICT DO NOTHING;
```

**Note**: You'll need to set passwords via Supabase Dashboard → Authentication → Users

### **6. Run the Application**
```bash
flutter run -d chrome
```

---

## 🔐 **Default Login Credentials**

After setting up test users:

**Admin Account:**
- Email: `admin@college.edu`
- Password: (Set in Supabase Dashboard)

**Student Account:**
- Email: `student@college.edu`
- Password: (Set in Supabase Dashboard)

---

## 📁 **Project Structure**

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase configuration
├── theme/
│   └── app_theme.dart                # App theme and colors
├── models/
│   ├── user_profile.dart             # User profile model
│   ├── skill.dart                    # Skill model
│   ├── internship.dart               # Internship model
│   ├── certificate.dart              # Certificate model
│   └── notification.dart             # Notification model
├── services/
│   ├── auth_service.dart             # Authentication service
│   ├── student_service.dart          # Student operations
│   └── admin_service.dart            # Admin operations
├── widgets/
│   ├── status_badge.dart             # Status badge widget
│   ├── dashboard_card.dart           # Dashboard card widget
│   └── app_sidebar.dart              # Sidebar navigation
├── screens/
│   ├── auth/
│   │   └── login_screen.dart         # Login page
│   ├── student/
│   │   ├── student_dashboard.dart    # Student dashboard
│   │   ├── student_profile_screen.dart # Profile management
│   │   └── student_skills_screen.dart  # Skills management
│   └── admin/
│       └── admin_dashboard.dart      # Admin dashboard
└── main.dart                         # App entry point
```

---

## ✅ **Completed Features**

### **Backend (100%)**
- ✅ Database schema with all tables
- ✅ Row Level Security policies
- ✅ Storage buckets and policies
- ✅ Indexes and performance optimization

### **Core System (100%)**
- ✅ Authentication system
- ✅ Theme and styling
- ✅ All data models
- ✅ Complete services (Auth, Student, Admin)
- ✅ Reusable widgets

### **Screens Completed (6/15)**
- ✅ Login Screen
- ✅ Student Dashboard
- ✅ Student Profile
- ✅ Student Skills Management
- ✅ Admin Dashboard
- ⏳ 10 more screens in progress

---

## 🎨 **Design System**

### **Colors**
- **Primary**: Blue (#2563EB)
- **Secondary**: Purple (#7C3AED)
- **Success**: Green (#10B981)
- **Warning**: Orange (#F59E0B)
- **Error**: Red (#EF4444)

### **Features**
- Clean, professional academic design
- Card-based layout
- Responsive web-first design
- Status badges with color coding
- Sidebar navigation
- Material Design 3

---

## 🔒 **Security**

- ✅ Row Level Security (RLS) enabled
- ✅ Students can only access their own data
- ✅ Admins have full access to all data
- ✅ Secure file storage with user-based access
- ✅ JWT-based authentication

---

## 📝 **Usage Guide**

### **For Students**
1. Login with college email
2. Complete your profile
3. Add your skills
4. Upload resume and certificates
5. Wait for internship assignment
6. Track internship progress

### **For Admins**
1. Login with admin credentials
2. View dashboard statistics
3. Search students by skills
4. Assign internships to matching students
5. Verify student certificates
6. Add new student accounts

---

## 🚧 **Remaining Work**

### **Student Screens (4 remaining)**
- Resume Upload Page
- Certificates Page
- Internship Details Page
- Notifications Page

### **Admin Screens (6 remaining)**
- Student Management Page
- Student Detail View
- Skill-Based Search Page
- Internship Assignment Page
- Certificate Verification Page
- Student Account Creation Page
- Reports & Export Page

### **Auth Screens (1 remaining)**
- Forgot Password Screen

---

## 🤝 **Contributing**

This is a college project. For any issues or suggestions, please contact the development team.

---

## 📄 **License**

This project is for educational purposes.

---

## 📞 **Support**

For technical support or queries:
- Email: support@interninfo.edu
- Project Repository: [GitHub Link]

---

## 🎯 **Roadmap**

- ✅ Phase 1: Backend Setup & Core Features (Complete)
- ✅ Phase 2: Authentication & Basic UI (Complete)
- 🔄 Phase 3: Student Module (60% Complete)
- ⏳ Phase 4: Admin Module (20% Complete)
- ⏳ Phase 5: Testing & Deployment

---

**Built with ❤️ using Flutter & Supabase**
