-- ============================================
-- CREATE STUDENT ACCOUNT: Dhilip Kumar
-- ============================================
-- Email: dhilipkumar.240086@cse.ritchennai.edu.in
-- Password: 2117240020086
-- ============================================

-- STEP 1: Create the authentication user in Supabase Dashboard
-- Go to: Authentication → Users → Add User
-- Email: dhilipkumar.240086@cse.ritchennai.edu.in
-- Password: 2117240020086
-- Auto Confirm User: YES
-- Copy the generated UUID

-- STEP 2: After creating the auth user, replace 'PASTE_UUID_HERE' below with the actual UUID
-- Then run this SQL in Supabase SQL Editor:

INSERT INTO profiles (
  id,
  name,
  email,
  register_number,
  department,
  year,
  phone_number,
  role,
  profile_completion,
  created_at,
  updated_at
)
VALUES (
  'PASTE_UUID_HERE',  -- Replace with UUID from auth.users
  'Dhilip Kumar',
  'dhilipkumar.240086@cse.ritchennai.edu.in',
  '240086',
  'Computer Science and Engineering',
  2,  -- Assuming 2nd year based on register number
  NULL,  -- Phone number can be added later
  'student',
  40,  -- Initial profile completion
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  register_number = EXCLUDED.register_number,
  department = EXCLUDED.department,
  year = EXCLUDED.year,
  role = EXCLUDED.role;

-- STEP 3: (Optional) Add some initial skills for the student
-- Replace 'PASTE_UUID_HERE' with the same UUID

INSERT INTO skills (user_id, skill_name, skill_level, created_at, updated_at)
VALUES 
  ('PASTE_UUID_HERE', 'Flutter', 'Beginner', NOW(), NOW()),
  ('PASTE_UUID_HERE', 'Dart', 'Beginner', NOW(), NOW())
ON CONFLICT (user_id, skill_name) DO NOTHING;

-- STEP 4: (Optional) Create a welcome notification
-- Replace 'PASTE_UUID_HERE' with the same UUID

INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
VALUES (
  'PASTE_UUID_HERE',
  'Welcome to InternInfo!',
  'Complete your profile and add your skills to get started with internship opportunities.',
  'system',
  false,
  NOW()
);

-- ============================================
-- VERIFICATION QUERY
-- ============================================
-- Run this to verify the account was created successfully:

SELECT 
  p.id,
  p.name,
  p.email,
  p.register_number,
  p.department,
  p.year,
  p.role,
  p.profile_completion,
  COUNT(DISTINCT s.id) as skills_count,
  COUNT(DISTINCT n.id) as notifications_count
FROM profiles p
LEFT JOIN skills s ON s.user_id = p.id
LEFT JOIN notifications n ON n.user_id = p.id
WHERE p.email = 'dhilipkumar.240086@cse.ritchennai.edu.in'
GROUP BY p.id, p.name, p.email, p.register_number, p.department, p.year, p.role, p.profile_completion;
