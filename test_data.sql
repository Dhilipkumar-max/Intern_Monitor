-- ============================================
-- INTERNSHIP MANAGEMENT SYSTEM - TEST DATA
-- ============================================
-- Run this script in Supabase SQL Editor to create test accounts
-- After running, set passwords in Supabase Dashboard → Authentication → Users

-- ============================================
-- 1. CREATE ADMIN USER
-- ============================================

-- Note: You'll need to create the auth user first via Supabase Dashboard
-- Then insert the profile with the same UUID

-- Example Admin Profile (update the UUID with your actual auth user ID)
INSERT INTO profiles (id, name, email, role, created_at, updated_at)
VALUES (
  'YOUR_ADMIN_AUTH_UUID_HERE',  -- Replace with actual UUID from auth.users
  'Admin User',
  'admin@college.edu',
  'admin',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  role = EXCLUDED.role;

-- ============================================
-- 2. CREATE STUDENT USERS
-- ============================================

-- Student 1: Computer Science
INSERT INTO profiles (id, name, email, register_number, department, year, role, profile_completion, created_at, updated_at)
VALUES (
  'YOUR_STUDENT1_AUTH_UUID_HERE',  -- Replace with actual UUID
  'John Doe',
  'john.doe@college.edu',
  'CS2021001',
  'Computer Science',
  3,
  'student',
  60,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  register_number = EXCLUDED.register_number,
  department = EXCLUDED.department,
  year = EXCLUDED.year;

-- Student 2: Information Technology
INSERT INTO profiles (id, name, email, register_number, department, year, role, profile_completion, created_at, updated_at)
VALUES (
  'YOUR_STUDENT2_AUTH_UUID_HERE',  -- Replace with actual UUID
  'Jane Smith',
  'jane.smith@college.edu',
  'IT2021002',
  'Information Technology',
  3,
  'student',
  75,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  register_number = EXCLUDED.register_number,
  department = EXCLUDED.department,
  year = EXCLUDED.year;

-- Student 3: Electronics
INSERT INTO profiles (id, name, email, register_number, department, year, role, profile_completion, created_at, updated_at)
VALUES (
  'YOUR_STUDENT3_AUTH_UUID_HERE',  -- Replace with actual UUID
  'Mike Johnson',
  'mike.johnson@college.edu',
  'EC2021003',
  'Electronics',
  2,
  'student',
  50,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  register_number = EXCLUDED.register_number,
  department = EXCLUDED.department,
  year = EXCLUDED.year;

-- ============================================
-- 3. ADD SAMPLE SKILLS FOR STUDENTS
-- ============================================

-- Skills for John Doe (CS Student)
INSERT INTO skills (user_id, skill_name, skill_level, created_at, updated_at)
VALUES 
  ('YOUR_STUDENT1_AUTH_UUID_HERE', 'Flutter', 'Advanced', NOW(), NOW()),
  ('YOUR_STUDENT1_AUTH_UUID_HERE', 'Python', 'Intermediate', NOW(), NOW()),
  ('YOUR_STUDENT1_AUTH_UUID_HERE', 'JavaScript', 'Intermediate', NOW(), NOW()),
  ('YOUR_STUDENT1_AUTH_UUID_HERE', 'React', 'Beginner', NOW(), NOW())
ON CONFLICT (user_id, skill_name) DO NOTHING;

-- Skills for Jane Smith (IT Student)
INSERT INTO skills (user_id, skill_name, skill_level, created_at, updated_at)
VALUES 
  ('YOUR_STUDENT2_AUTH_UUID_HERE', 'Java', 'Advanced', NOW(), NOW()),
  ('YOUR_STUDENT2_AUTH_UUID_HERE', 'SQL', 'Advanced', NOW(), NOW()),
  ('YOUR_STUDENT2_AUTH_UUID_HERE', 'Spring Boot', 'Intermediate', NOW(), NOW()),
  ('YOUR_STUDENT2_AUTH_UUID_HERE', 'Docker', 'Beginner', NOW(), NOW())
ON CONFLICT (user_id, skill_name) DO NOTHING;

-- Skills for Mike Johnson (EC Student)
INSERT INTO skills (user_id, skill_name, skill_level, created_at, updated_at)
VALUES 
  ('YOUR_STUDENT3_AUTH_UUID_HERE', 'Arduino', 'Intermediate', NOW(), NOW()),
  ('YOUR_STUDENT3_AUTH_UUID_HERE', 'C Programming', 'Advanced', NOW(), NOW()),
  ('YOUR_STUDENT3_AUTH_UUID_HERE', 'PCB Design', 'Beginner', NOW(), NOW())
ON CONFLICT (user_id, skill_name) DO NOTHING;

-- ============================================
-- 4. CREATE SAMPLE INTERNSHIPS
-- ============================================

-- Internship for John Doe
INSERT INTO internships (user_id, title, company, role, duration, status, required_skills, created_at, updated_at)
VALUES (
  'YOUR_STUDENT1_AUTH_UUID_HERE',
  'Mobile App Development Intern',
  'Tech Solutions Inc.',
  'Flutter Developer',
  '3 months',
  'Ongoing',
  ARRAY['Flutter', 'Dart', 'Mobile Development'],
  NOW(),
  NOW()
);

-- Internship for Jane Smith
INSERT INTO internships (user_id, title, company, role, duration, status, required_skills, created_at, updated_at)
VALUES (
  'YOUR_STUDENT2_AUTH_UUID_HERE',
  'Backend Development Intern',
  'Software Corp',
  'Java Developer',
  '6 months',
  'Assigned',
  ARRAY['Java', 'Spring Boot', 'SQL'],
  NOW(),
  NOW()
);

-- ============================================
-- 5. CREATE SAMPLE NOTIFICATIONS
-- ============================================

-- Notification for John Doe
INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
VALUES (
  'YOUR_STUDENT1_AUTH_UUID_HERE',
  'Internship Assigned',
  'You have been assigned an internship at Tech Solutions Inc.',
  'internship_assigned',
  false,
  NOW()
);

-- Notification for Jane Smith
INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
VALUES (
  'YOUR_STUDENT2_AUTH_UUID_HERE',
  'Internship Assigned',
  'You have been assigned an internship at Software Corp.',
  'internship_assigned',
  false,
  NOW()
);

-- ============================================
-- INSTRUCTIONS
-- ============================================
/*
1. First, create users in Supabase Dashboard:
   - Go to Authentication → Users
   - Click "Add User"
   - Enter email and password
   - Copy the UUID

2. Replace all 'YOUR_XXX_AUTH_UUID_HERE' with actual UUIDs

3. Run this script in Supabase SQL Editor

4. Test login with:
   - Admin: admin@college.edu
   - Student 1: john.doe@college.edu
   - Student 2: jane.smith@college.edu
   - Student 3: mike.johnson@college.edu

5. Use the passwords you set in step 1
*/
