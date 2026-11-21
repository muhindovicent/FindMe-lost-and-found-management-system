-- FindMe static reference data for Neon PostgreSQL.
-- Excludes demo users/passwords intentionally.

INSERT INTO roles (id, name, description) VALUES
(1, 'Student', 'University student'),
(2, 'Lecturer', 'University lecturer or staff'),
(3, 'Administrator', 'System administrator') ON CONFLICT DO NOTHING;

INSERT INTO campuses (id, name, description) VALUES
(1, 'Main Campus (Siyani)', 'Main university campus - Faculty of Science and Technology'),
(2, 'Acacia Campus', 'Acacia campus - Faculty of Law'),
(3, 'Kingsgate Campus', 'Kingsgate campus - Faculty of Business and Management'),
(4, 'Mukono Campus', 'Mukono campus - Health related courses') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;

INSERT INTO faculties (id, name, description, campus_id) VALUES
(1, 'Faculty of Science and Technology', 'Computing, IT and technology programs - Main Campus (Siyani)', 1),
(2, 'Faculty of Business and Management', 'Business and management programs - Kingsgate', 3),
(3, 'Faculty of Health Sciences', 'Health related courses - Mukono', 4),
(4, 'Faculty of Engineering', 'Engineering programs - Main Campus (Siyani)', 1),
(5, 'Faculty of Arts and Social Sciences', 'Arts and social sciences programs - Main Campus (Siyani)', 1),
(6, 'Faculty of Law', 'Law programs - Acacia', 2) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, campus_id = EXCLUDED.campus_id;

INSERT INTO courses (id, name, code, faculty_id) VALUES
(1, 'Bachelor of Science in Computer Science', 'BSCS', 1),
(2, 'Bachelor of Science in Information Technology', 'BSIT', 1),
(3, 'Bachelor of Business Administration', 'BBA', 2),
(4, 'Bachelor of Science in Nursing', 'BSN', 3),
(5, 'Bachelor of Engineering in Software Engineering', 'BSE', 4),
(6, 'Bachelor of Arts in Communication', 'BAComm', 5),
(7, 'Diploma in Business Administration', 'DBA', 2),
(8, 'Certificate in IT', 'CIT', 1),
(9, 'Bachelor of Laws', 'LLB', 6),
(10, 'Bachelor of Public Health', 'BPH', 3),
(11, 'Bachelor of Business Computing', 'BBC', 2) ON CONFLICT DO NOTHING;

INSERT INTO categories (id, name, description) VALUES
(1, 'Electronics', 'Electronic devices and accessories'),
(2, 'Documents', 'Important documents and papers'),
(3, 'Bags', 'Handbags, backpacks, and bags'),
(4, 'Wallets', 'Wallets and purses'),
(5, 'Keys', 'Keys and keychains'),
(6, 'Books', 'Textbooks and books'),
(7, 'Clothing', 'Apparel and clothing items'),
(8, 'Accessories', 'Watches, jewelry, and accessories'),
(9, 'IDs/Cards', 'Identification cards and access cards'),
(10, 'Money', 'Currency and financial items'),
(11, 'Other', 'Other items not listed above') ON CONFLICT DO NOTHING;

INSERT INTO locations (id, name, description) VALUES
(1, 'Main Campus', 'Main campus area'),
(2, 'Library', 'University library'),
(3, 'Library Entrance', 'Near the library main entrance'),
(4, 'Lecture Room', 'Lecture rooms building'),
(5, 'Laboratory', 'Science and computer laboratories'),
(6, 'Cafeteria', 'University cafeteria and dining area'),
(7, 'Parking Area', 'Vehicle parking area'),
(8, 'Hostel', 'Student hostels'),
(9, 'Administration Block', 'University administration building'),
(10, 'Faculty Office', 'Faculty offices'),
(11, 'Computer Lab', 'Computer laboratories'),
(12, 'Lecture Hall', 'Lecture halls'),
(13, 'Student Lounge', 'Student common areas'),
(14, 'Sports Area', 'Sports and recreation area'),
(15, 'Other', 'Other locations') ON CONFLICT DO NOTHING;

SELECT setval(pg_get_serial_sequence('roles', 'id'), COALESCE((SELECT MAX(id) FROM roles), 1), true);

SELECT setval(pg_get_serial_sequence('campuses', 'id'), COALESCE((SELECT MAX(id) FROM campuses), 1), true);

SELECT setval(pg_get_serial_sequence('faculties', 'id'), COALESCE((SELECT MAX(id) FROM faculties), 1), true);

SELECT setval(pg_get_serial_sequence('courses', 'id'), COALESCE((SELECT MAX(id) FROM courses), 1), true);

SELECT setval(pg_get_serial_sequence('categories', 'id'), COALESCE((SELECT MAX(id) FROM categories), 1), true);

SELECT setval(pg_get_serial_sequence('locations', 'id'), COALESCE((SELECT MAX(id) FROM locations), 1), true);
