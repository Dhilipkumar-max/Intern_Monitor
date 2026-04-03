-- Quick Fix Migration Script
-- Run this in your Supabase SQL Editor to fix the 400 error

-- Add GitHub and LinkedIn URL columns to profiles table (if they don't exist)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS github_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS linkedin_url TEXT;

-- Verify the columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN ('github_url', 'linkedin_url');