# 🔧 Quick Fix: Create Student Account

## Problem
You're getting a 400 error because the user doesn't exist in Supabase Auth yet.

## Solution: Create User via Supabase Dashboard

### **Method 1: Via Supabase Dashboard (Recommended)**

1. **Go to Supabase Dashboard**
   - URL: https://supabase.com/dashboard/project/eqrxzrfpjzqqlbvgwesx/auth/users

2. **Click "Add User" (Green button on top right)**

3. **Fill in the form:**
   ```
   Email: dhilipkumar.240086@cse.ritchennai.edu.in
   Password: 2117240020086
   Auto Confirm User: ✅ YES (IMPORTANT!)
   ```

4. **Click "Create User"**

5. **Copy the UUID** (looks like: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

6. **Run this SQL in SQL Editor** (replace UUID):
   ```sql
   INSERT INTO profiles (
     id,
     name,
     email,
     register_number,
     department,
     year,
     role,
     profile_completion,
     created_at,
     updated_at
   )
   VALUES (
     'PASTE_YOUR_UUID_HERE',
     'Dhilip Kumar',
     'dhilipkumar.240086@cse.ritchennai.edu.in',
     '240086',
     'Computer Science and Engineering',
     2,
     'student',
     40,
     NOW(),
     NOW()
   );
   ```

7. **Test Login**
   - Email: `dhilipkumar.240086@cse.ritchennai.edu.in`
   - Password: `2117240020086`

---

### **Method 2: Quick SQL Script (If Method 1 Doesn't Work)**

If you're having trouble with the dashboard, you can use the Supabase SQL Editor to create both the auth user and profile:

```sql
-- This creates a user with a hashed password
-- Note: This is a workaround and Method 1 is preferred

DO $$
DECLARE
  new_user_id uuid;
BEGIN
  -- Generate a new UUID
  new_user_id := gen_random_uuid();
  
  -- Insert into auth.users (this might require admin privileges)
  -- If this fails, you MUST use Method 1 (Dashboard)
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    role
  )
  VALUES (
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'dhilipkumar.240086@cse.ritchennai.edu.in',
    crypt('2117240020086', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    false,
    'authenticated'
  );
  
  -- Insert into profiles
  INSERT INTO profiles (
    id,
    name,
    email,
    register_number,
    department,
    year,
    role,
    profile_completion,
    created_at,
    updated_at
  )
  VALUES (
    new_user_id,
    'Dhilip Kumar',
    'dhilipkumar.240086@cse.ritchennai.edu.in',
    '240086',
    'Computer Science and Engineering',
    2,
    'student',
    40,
    NOW(),
    NOW()
  );
  
  -- Add welcome notification
  INSERT INTO notifications (
    user_id,
    title,
    message,
    type,
    is_read,
    created_at
  )
  VALUES (
    new_user_id,
    'Welcome to InternInfo!',
    'Complete your profile and add your skills to get started.',
    'system',
    false,
    NOW()
  );
  
  RAISE NOTICE 'User created with ID: %', new_user_id;
END $$;
```

---

### **Method 3: Using Supabase CLI (Advanced)**

If you have Supabase CLI installed:

```bash
supabase auth create-user dhilipkumar.240086@cse.ritchennai.edu.in --password 2117240020086
```

---

## ✅ Verification

After creating the user, verify with this SQL:

```sql
SELECT 
  au.id,
  au.email,
  au.email_confirmed_at,
  p.name,
  p.role,
  p.register_number
FROM auth.users au
LEFT JOIN profiles p ON p.id = au.id
WHERE au.email = 'dhilipkumar.240086@cse.ritchennai.edu.in';
```

You should see:
- ✅ User ID (UUID)
- ✅ Email confirmed timestamp
- ✅ Profile name: "Dhilip Kumar"
- ✅ Role: "student"

---

## 🔐 Then Try Login Again

Once the user is created:
1. Refresh your Flutter app (or hot reload)
2. Login with:
   - Email: `dhilipkumar.240086@cse.ritchennai.edu.in`
   - Password: `2117240020086`

---

## 🆘 Still Not Working?

If you still get errors:

1. **Check Supabase Auth Settings:**
   - Go to Authentication → Settings
   - Ensure "Enable email confirmations" is OFF (or user is confirmed)

2. **Check the browser console** for detailed error messages

3. **Verify Supabase URL and Key** in `lib/config/supabase_config.dart`

Let me know which method you used and if you encounter any issues!
