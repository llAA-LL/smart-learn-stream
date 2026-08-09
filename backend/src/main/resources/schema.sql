CREATE DATABASE IF NOT EXISTS smart_learning DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE smart_learning;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    real_name VARCHAR(50),
    role VARCHAR(20) NOT NULL DEFAULT 'STUDENT' COMMENT 'STUDENT or ADMIN',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    cover_url VARCHAR(255),
    created_by BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_courses_category (category)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS knowledge_points (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    learning_content MEDIUMTEXT,
    course_id BIGINT,
    level INT DEFAULT 0 COMMENT 'depth level',
    x_position DOUBLE DEFAULT 0,
    y_position DOUBLE DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    INDEX idx_kp_course_level (course_id, level)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS kp_prerequisites (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    kp_id BIGINT NOT NULL,
    prerequisite_kp_id BIGINT NOT NULL,
    UNIQUE KEY uk_kp_prereq (kp_id, prerequisite_kp_id),
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_kp_id) REFERENCES knowledge_points(id) ON DELETE CASCADE,
    INDEX idx_kpp_prereq (prerequisite_kp_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_plans (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT 'ACTIVE, COMPLETED, PAUSED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_lp_user_status (user_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS plan_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    plan_id BIGINT NOT NULL,
    course_id BIGINT,
    kp_id BIGINT,
    item_type VARCHAR(20) NOT NULL COMMENT 'COURSE or KNOWLEDGE_POINT',
    sort_order INT DEFAULT 0,
    target_date DATE,
    completed BOOLEAN DEFAULT FALSE,
    completed_score INT DEFAULT NULL COMMENT 'quiz score 0-100 that triggered completion',
    completed_at DATETIME,
    FOREIGN KEY (plan_id) REFERENCES learning_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE SET NULL,
    INDEX idx_pi_kp_completed (kp_id, completed),
    INDEX idx_pi_course_completed (course_id, completed)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT,
    kp_id BIGINT,
    duration_minutes INT NOT NULL DEFAULT 0 COMMENT 'learning duration',
    mastery_level INT DEFAULT 0 COMMENT 'self-rated mastery 0-100',
    notes TEXT,
    record_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE SET NULL,
    INDEX idx_lr_user_date (user_id, record_date),
    INDEX idx_lr_user_created (user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_kp_mastery (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    kp_id BIGINT NOT NULL,
    mastery_score INT DEFAULT 0 COMMENT 'system-calculated 0-100',
    learn_count INT DEFAULT 0,
    last_learn_at DATETIME,
    UNIQUE KEY uk_user_kp (user_id, kp_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recommendation_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    kp_id BIGINT,
    reason VARCHAR(255),
    clicked BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE SET NULL,
    INDEX idx_rl_user_created (user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS questions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    kp_id BIGINT NOT NULL,
    question_type VARCHAR(20) NOT NULL COMMENT 'SINGLE_CHOICE, MULTI_CHOICE, TRUE_FALSE',
    content TEXT NOT NULL,
    options JSON COMMENT 'e.g. [{"key":"A","text":"..."}]',
    answer VARCHAR(100) NOT NULL,
    explanation TEXT,
    difficulty INT DEFAULT 1 COMMENT '1=easy 2=medium 3=hard',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE CASCADE,
    INDEX idx_q_kp_diff (kp_id, difficulty),
    INDEX idx_q_kp_type (kp_id, question_type)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    kp_id BIGINT NOT NULL,
    total_questions INT NOT NULL DEFAULT 0,
    correct_count INT NOT NULL DEFAULT 0,
    score INT NOT NULL DEFAULT 0 COMMENT '0-100',
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (kp_id) REFERENCES knowledge_points(id) ON DELETE CASCADE,
    INDEX idx_qa_user_kp_completed (user_id, kp_id, completed_at),
    INDEX idx_qa_user_completed (user_id, completed_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS quiz_answers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    attempt_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    user_answer VARCHAR(200),
    is_correct BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attempt_id) REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO users (username, password, real_name, role) VALUES
('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '管理员', 'ADMIN')
ON DUPLICATE KEY UPDATE username=username;
