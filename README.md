# InternInfo - Advanced Internship Management Platform

InternInfo is a premium, high-fidelity internship management system designed for academic institutions to bridge the gap between students and professional opportunities. Built with a focus on "Editorial Academic Excellence," it provides a sophisticated interface for tracking professional growth, skill acquisition, and certificate verification.

## 🚀 Real-World Use Case
In modern academic environments, tracking students' professional milestones (internships, projects, skills) is often fragmented across multiple platforms. InternInfo centralizes this journey, allowing students to build a verified professional portfolio while giving administrators powerful search and reporting tools to manage student success.

---

## ✨ Key Features

### 🎓 Student Interface
- **Bento Grid Dashboard**: A modern overview of your professional journey with real-time progress tracking.
- **Innovation Incubator (Projects)**: Showcase your technical projects with social and live demonstration links.
- **Skill Matrix**: Dynamic tracking of technical proficiency with an interactive grid of chips.
- **Professional Timeline**: A chronological history of internships with status-aware lifecycle management.
- **Credential Vault (Certificates)**: Upload and manage certificates with an integrated administrative verification flow.
- **Academic Profile**: Comprehensive management of personal, academic, and social (GitHub/LinkedIn) data.
- **Responsive Navigation**: Seamless experience across Desktop (Sidebar) and Mobile (Bottom Bar).

### 🛠️ administrator Interface
- **Student Management**: Centralized hub to manage all registered students and their academic records.
- **Skill-Based Search**: Advanced filtering to identify candidates based on specific technical proficiencies.
- **Certificate Verification**: Review and approve student credentials with administrative remarks.
- **Internship Assignment**: Track and manage internship placements across the student body.
- **Reporting & Analytics**: Comprehensive exports and views of student professional preparedness.

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter (Web & Mobile)
- **State Management**: Provider
- **Design System**: Custom "Editorial Academic Excellence" (Tonal Stacking, Organic Structuralism)
- **Typography**: Manrope (Headlines), Inter (Body)
- **Architecture**: Material 3 with Custom Component Library

### Backend
- **Runtime**: Node.js & Express
- **Authentication**: JWT (JSON Web Tokens) with Bcrypt hashing
- **File Handling**: Multer for secure document uploads
- **Environment**: Dotenv for configuration management

### Database
- **Engine**: MySQL
- **Schema**: `internship_management` (Relational)

---

## 🏗️ System Architecture

InternInfo follows a standard **Client-Server-Database** architecture:
1. **Flutter Client**: Handles UI rendering and state management, communicating with the backend via RESTful APIs.
2. **Express Server**: Orchestrates business logic, authentication, and file processing.
3. **MySQL Database**: Stores persistent data for students, admins, certificates, skills, and internships.

---

## 📂 Project Structure

```bash
interninfo/
├── lib/                     # Flutter Frontend
│   ├── config/              # API and Environment configurations
│   ├── models/              # Data models (Student, Internship, Skill, etc.)
│   ├── screens/             # UI Screens
│   │   ├── admin/           # administrator modules
│   │   ├── student/         # Student modules
│   │   └── common/          # Shared screens (Login, Landing)
│   ├── services/            # API communication and business logic
│   ├── theme/               # Global design tokens and AppTheme
│   └── widgets/             # Reusable UI components (Sidebar, Cards)
├── server/                  # Node.js Backend
│   ├── uploads/             # Stores uploaded resumes and certificates
│   ├── index.js             # Main server entry point
│   ├── db.js                # Database connection and utilities
│   └── .env                 # Environment variables (JWT_SECRET, DB_CONFIG)
└── pubspec.yaml             # Flutter dependencies
```

---

## 📝 Page & Module Description

| Module | Function | Role |
| :--- | :--- | :--- |
| **Student Dashboard** | Bento-grid overview of progress and quick actions. | Student Home |
| **Profile Screen** | Editorial form for academic and social identity management. | User Data |
| **Project Screen** | Portfolio showcase for innovation and technical projects. | Proof of Work |
| **Skills Screen** | Interactive ledger for tracking technical proficiency. | Skill Tracking |
| **Internship Status** | Timeline view of professional history and current tenure. | Work History |
| **Admin Dashboard** | Oversight panel for student body statistics and alerts. | Admin Home |
| **Skill Search** | Reverse-search students based on technical stacks. | Recruitment |
| **Verification Hub** | Queue for reviewing and approving student certificates. | Auditing |

---

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK (latest)
- Node.js & NPM
- MySQL Server

### 1. Database Setup
1. Create a MySQL database named `internship_management`.
2. Run the provided SQL scripts (if any) or ensure the schema is initialized.

### 2. Backend Setup
1. Navigate to the `server/` directory.
2. Install dependencies: `npm install`
3. Configure `.env` with your DB credentials and `JWT_SECRET`.
4. Start the server: `node index.js`

### 3. Frontend Setup
1. Navigate back to the root directory.
2. Install Flutter packages: `flutter pub get`
3. Run the application: `flutter run -d chrome` (for web)

---

## 🔮 Future Enhancements
- **AI Career Copilot**: AI-driven suggestions for skills based on internship trends.
- **Direct Messaging**: In-app communication between Students and Admins.
- **Export to PDF**: Generate professional resumes directly from the platform data.
- **Dark Mode Optimization**: Comprehensive theme switching system.

---

## 👤 Author
**Dhilip Kumar**  
Developer & UI/UX Enthusiast

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
