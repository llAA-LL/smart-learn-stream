-- ============================================================
-- Migration: Add secondary indexes for query performance
-- Run against running database: mysql -h 127.0.0.1 -P 3307 -u root -proot smart_learning < this_file.sql
-- ============================================================

-- learning_records (most heavily queried table)
CREATE INDEX idx_lr_user_date    ON learning_records (user_id, record_date);
CREATE INDEX idx_lr_user_created ON learning_records (user_id, created_at);

-- quiz_attempts
CREATE INDEX idx_qa_user_kp_completed ON quiz_attempts (user_id, kp_id, completed_at);
CREATE INDEX idx_qa_user_completed     ON quiz_attempts (user_id, completed_at);

-- plan_items
CREATE INDEX idx_pi_kp_completed     ON plan_items (kp_id, completed);
CREATE INDEX idx_pi_course_completed ON plan_items (course_id, completed);

-- recommendation_logs
CREATE INDEX idx_rl_user_created ON recommendation_logs (user_id, created_at);

-- learning_plans
CREATE INDEX idx_lp_user_status ON learning_plans (user_id, status);

-- questions
CREATE INDEX idx_q_kp_diff ON questions (kp_id, difficulty);
CREATE INDEX idx_q_kp_type ON questions (kp_id, question_type);

-- courses
CREATE INDEX idx_courses_category ON courses (category);

-- knowledge_points
CREATE INDEX idx_kp_course_level ON knowledge_points (course_id, level);

-- kp_prerequisites (reverse lookup: find KPs that depend on a given prerequisite)
CREATE INDEX idx_kpp_prereq ON kp_prerequisites (prerequisite_kp_id);
