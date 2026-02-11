-- ============================================
-- CREATE ADMIN ACCOUNT
-- ============================================
-- Follow these steps to set up your first admin account:

-- STEP 1: Go to your Supabase Dashboard
-- 1. Navigate to: Authentication → Users → Add User
-- 2. Email: admin@ritchennai.edu.in
-- 3. Password: admin123 (or any password you choose)
-- 4. Auto Confirm User: YES
-- 5. Copy the generated User ID (UUID)

-- STEP 2: Run this SQL in Supabase SQL Editor
-- Replace 'PASTE_UUID_HERE' with the actual UUID from Step 1

INSERT INTO public.profiles (
    id,
    name,
    email,
    role
) VALUES (
    'PASTE_UUID_HERE', 
    'System Admin', 
    'admin@ritchennai.edu.in', 
    'admin'
) ON CONFLICT (id) DO UPDATE SET
    role = 'admin';
