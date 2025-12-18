-- Verification script to check USERS table structure
SET SERVEROUTPUT ON;
SET LINESIZE 200;

-- Check if USERS table exists
SELECT 'USERS table exists' AS status FROM user_tables WHERE table_name = 'USERS';

-- Show table structure
DESC USERS;

-- Show column details
SELECT column_name, data_type, data_length, nullable 
FROM user_tab_columns 
WHERE table_name = 'USERS'
ORDER BY column_id;

-- Count users
SELECT COUNT(*) as user_count FROM USERS;

-- Show sample users (without passwords)
SELECT id_user, username, display_name, email, role, created_at 
FROM USERS
WHERE ROWNUM <= 5;
