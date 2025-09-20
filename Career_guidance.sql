-- career_guidance_system.sql


DROP DATABASE IF EXISTS career_db;
CREATE DATABASE career_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE career_db;

-- --------------------------------------------------
-- Users (students + experts + admins)
-- --------------------------------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(200) NOT NULL,
  role ENUM('student','expert','admin') NOT NULL DEFAULT 'student',
  bio TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- --------------------------------------------------
-- Courses
-- --------------------------------------------------
DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  level ENUM('beginner','intermediate','advanced') DEFAULT 'beginner',
  duration_weeks INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- --------------------------------------------------
-- Student Enrollments (many-to-many: students <-> courses)
-- --------------------------------------------------
DROP TABLE IF EXISTS enrollments;
CREATE TABLE enrollments (
  enrollment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('active','completed','dropped') DEFAULT 'active',
  UNIQUE KEY uq_student_course (student_id, course_id),
  CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;


DROP TABLE IF EXISTS career_paths;
CREATE TABLE career_paths (
  path_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


DROP TABLE IF EXISTS career_courses;
CREATE TABLE career_courses (
  path_id INT NOT NULL,
  course_id INT NOT NULL,
  PRIMARY KEY (path_id, course_id),
  CONSTRAINT fk_cc_path FOREIGN KEY (path_id) REFERENCES career_paths(path_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_cc_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;


DROP TABLE IF EXISTS student_careers;
CREATE TABLE student_careers (
  student_id INT NOT NULL,
  path_id INT NOT NULL,
  start_date DATE,
  progress_percent DECIMAL(5,2) DEFAULT 0.00,
  PRIMARY KEY (student_id, path_id),
  CONSTRAINT fk_sc_student FOREIGN KEY (student_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_sc_path FOREIGN KEY (path_id) REFERENCES career_paths(path_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS experts;
CREATE TABLE experts (
  expert_id INT PRIMARY KEY,
  specialization VARCHAR(200),
  experience_years INT,
  linkedin VARCHAR(255),
  FOREIGN KEY (expert_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;


DROP TABLE IF EXISTS interactions;
CREATE TABLE interactions (
  interaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  expert_id INT NOT NULL,
  topic VARCHAR(200),
  message TEXT,
  interaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_interaction_student FOREIGN KEY (student_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_interaction_expert FOREIGN KEY (expert_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;


DROP TABLE IF EXISTS resources;
CREATE TABLE resources (
  resource_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  type ENUM('article','video','guide','other') DEFAULT 'article',
  url VARCHAR(500) NOT NULL,
  description TEXT,
  uploaded_by INT,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_resource_uploader FOREIGN KEY (uploaded_by) REFERENCES users(user_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

DROP TABLE IF EXISTS forum_posts;
CREATE TABLE forum_posts (
  post_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_post_user FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS forum_replies;
CREATE TABLE forum_replies (
  reply_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  post_id BIGINT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reply_post FOREIGN KEY (post_id) REFERENCES forum_posts(post_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_reply_user FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_courses_title ON courses(title);
CREATE INDEX idx_resources_type ON resources(type);
CREATE INDEX idx_forum_posts_user ON forum_posts(user_id);

-- End of schema
