-- ============================================
-- DATABASE MIGRATION FOR NEW FEATURES
-- ============================================
-- This script adds:
-- 1. GitHub and LinkedIn URL fields to profiles table
-- 2. New projects table for student projects
-- ============================================

-- 1. ADD GITHUB AND LINKEDIN FIELDS TO PROFILES TABLE (IF NOT EXISTS)
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name='profiles' AND column_name='github_url') THEN
      ALTER TABLE profiles ADD COLUMN github_url TEXT;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name='profiles' AND column_name='linkedin_url') THEN
      ALTER TABLE profiles ADD COLUMN linkedin_url TEXT;
   END IF;
END $$;

-- 2. CREATE PROJECTS TABLE (IF NOT EXISTS)
CREATE TABLE IF NOT EXISTS projects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    github_url TEXT,
    live_url TEXT,
    image_url TEXT,
    technologies TEXT[],  -- Array of technology names
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CREATE INDEXES FOR BETTER PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at DESC);

-- 4. ENABLE ROW LEVEL SECURITY ON PROJECTS TABLE
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- 5. CREATE RLS POLICIES FOR PROJECTS
-- Students can only view/edit their own projects
CREATE POLICY "Students can view their own projects" ON projects
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Students can insert their own projects" ON projects
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Students can update their own projects" ON projects
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Students can delete their own projects" ON projects
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

-- Admins can view all projects
CREATE POLICY "Admins can view all projects" ON projects
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- 6. CREATE TRIGGER TO UPDATE updated_at TIMESTAMP
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON projects 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA INSERTION (Optional)
-- ============================================
-- Uncomment and modify the UUIDs to add sample data

/*
-- Add sample GitHub/LinkedIn links to existing profiles
UPDATE profiles 
SET 
    github_url = 'https://github.com/johndoe',
    linkedin_url = 'https://linkedin.com/in/johndoe'
WHERE email = 'john.doe@college.edu';

-- Add sample projects
INSERT INTO projects (user_id, title, description, github_url, live_url, technologies)
VALUES 
(
    'STUDENT1_UUID_HERE',  -- Replace with actual student UUID
    'E-Commerce Mobile App',
    'A full-featured e-commerce application built with Flutter and Firebase',
    'https://github.com/username/ecommerce-app',
    'https://ecommerce-demo.com',
    ARRAY['Flutter', 'Firebase', 'Dart', 'REST API']
),
(
    'STUDENT1_UUID_HERE',  -- Replace with actual student UUID
    'Task Management Dashboard',
    'Web-based task management system with real-time updates',
    'https://github.com/username/task-manager',
    'https://taskmanager-demo.com',
    ARRAY['React', 'Node.js', 'MongoDB', 'Socket.io']
);
*/