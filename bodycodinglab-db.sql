CREATE DATABASE IF NOT EXISTS `fit_mate_db`
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `fit_mate_db`;

CREATE TABLE IF NOT EXISTS `users` (
	user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    profile_image LONGBLOB, 
    name VARCHAR(25) NOT NULL,
    birthdate DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    member_address VARCHAR(255), -- 보류
    trainer_job_address VARCHAR(255), -- 보류
    trainer_attachment BLOB,
    CHECK (gender IN ('MAN', 'WOMAN')) 
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `roles` (
	role_id BIGINT AUTO_INCREMENT PRIMARY KEY,	-- 역할 고유 ID
    role_name VARCHAR(50) NOT NULL UNIQUE		-- 역할 이름 (ex. ADMIN, USER), 중복 불가
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO roles (role_name)
VALUES
	('MEMBER'), ('TRAINER'), ('NON_MEMBER');	-- MEMBER: 구독회원, TRAINER: 트레이너, NON_MEMBER: 일반회원
    
CREATE TABLE IF NOT EXISTS `user_roles` (
	user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id), -- 복합 기본키: 중복 매핑 방지
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_infos`(
	trainer_id BIGINT PRIMARY KEY,
	trainer_short_introduce VARCHAR(150),
    trainer_long_introduce TEXT,
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 최종 학력만 기입 가능 
CREATE TABLE IF NOT EXISTS `trainer_educations` (
	education_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    education_name VARCHAR(100) NOT NULL,
    education_entrance YEAR NOT NULL,
    education_graduate YEAR NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_careers` (
	career_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    company_join YEAR NOT NULL,
    company_quit YEAR NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_licenses` (
	license_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	trainer_id BIGINT NOT NULL,
    license_type VARCHAR(20) NOT NULL,
    license_name VARCHAR(100) NOT NULL,
    license_image LONGBLOB NOT NULL,
    CHECK (license_type IN('LICENSE', 'CERTIFICATE', 'AWARD_DETAIL')), -- LICENSE: "자격증", CERTIFICATE: "수료증, AWARD_DETAIL: "수상내역"
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `members` (
	member_id BIGINT PRIMARY KEY,
    member_subscribe_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (member_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `matches`(
    match_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    # match_date DATE DEFAULT CURRENT_TIMESTAMP, -- 보류
    is_maintained BOOLEAN DEFAULT TRUE,
    UNIQUE KEY (member_id, trainer_id),
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `personal_community_board`(
    board_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    image LONGBLOB,
    writer_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (writer_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES personal_community_board_categories(category_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


CREATE TABLE  IF NOT EXISTS `personal_community_board_categories` (
	category_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(20) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `personal_community_board_comments` (
	comment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    board_id BIGINT NOT NULL,
    commenter_id BIGINT NOT NULL, 
    comment_content TEXT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- 보류
    FOREIGN KEY(board_id) REFERENCES personal_community_board (board_id),
    FOREIGN KEY(commenter_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 보류 --
CREATE TABLE IF NOT EXISTS `notes` (
	note_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    note_writer BIGINT NOT NULL,
    note_text TEXT NOT NULL,
    note_receiver BIGINT NOT NULL,
    note_important BOOLEAN DEFAULT FALSE,
    note_is_readed BOOLEAN DEFAULT FALSE,
    note_send_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    note_receive_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_writer) REFERENCES users(user_id),
    FOREIGN KEY (note_receiver) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `oneday_tickets`(
    ticket_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL, 
    trainer_id BIGINT NOT NULL,
    applied_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    used_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    processed_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- 보류
    reject_reason VARCHAR(100), -- 보류: 티켓 보류 사유
    ticket_progress VARCHAR(50) NOT NULL,
    CHECK (ticket_progress IN ('NOT_USED', 'APPLICATION', 'ISSUANCE', 'APPROVAL', 'USED_COMPLETE', 'REJECT')),
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 보류
CREATE TABLE IF NOT EXISTS `coupons`(
    coupon_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    coupon_image LONGBLOB,
    coupon_expiration_period DATE NOT NULL,
    coupon_used_date  TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
	coupon_progress VARCHAR(50) NOT NULL,
    CHECK (coupon_progress IN ('NOT_USED', 'APPLICATION', 'COMPLETE', 'EXPIRED')),
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 보류
CREATE TABLE IF NOT EXISTS `member_form`(
   form_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL ,
    age TINYINT NOT NULL,
    bodyform VARCHAR(10) NOT NULL,
    goal VARCHAR(20) NOT NULL,
    bmi TINYINT UNSIGNED NOT NULL,
    improved_part VARCHAR(20)  NOT NULL,
    preferred_diet VARCHAR(20) NOT NULL,
    sugar_intake VARCHAR(20) NOT NULL,
    water_intake VARCHAR(20)  NOT NULL,
    height TINYINT UNSIGNED NOT NULL,
    weight TINYINT UNSIGNED NOT NULL,
    weight_goal TINYINT UNSIGNED NOT NULL,
    pysical_level TINYINT UNSIGNED NOT NULL,
    exercising_problem VARCHAR(20) NOT NULL,
    pushup_level VARCHAR(20) NOT NULL,
    pullup_level VARCHAR(20) NOT NULL,
    exercise_frequency VARCHAR(20) NOT NULL,
    Investable_time VARCHAR(20) NOT NULL,
	CHECK (bodyform IN ('SLIM', 'NORMAL', 'FAT')),
    CHECK (goal IN('DIET', 'IMPROVEMENT_OF_MUSCLE', 'PERFORMANCE')),
    CHECK (improved_part IN ('CHEST', 'ARM', 'STOMACH', 'LEG', 'NOT_APPLICABLE')),
    CHECK (preferred_diet IN ('VEGETARIAM', 'VEGAN', 'KITO', 'MEDITERRANEAN', 'CANIBORE', 'NOT_APPLICABLE')),
    CHECK (sugar_intake IN ('DONT_OFTEN', 'WEEK_3TO5', 'EVERYDAY')),
    CHECK (water_intake IN ('COFFE_TEA', 'LESS_2', '2TO6', '7TO10', 'MORE_10')),
	CHECK (exercising_problem IN ('MOTIVATION', 'EFFECT', 'HARD', 'PLAN', 'COACHING', 'NOT_APPLICABLE')),
    CHECK (pushup_level IN ('LESS_5', '5TO10', 'MORE_10')), 
    CHECK (pullup_level IN ('LESS_5', '5TO10', 'MORE_10')),
	CHECK (exercise_frequency IN ('NEVER', 'WEEK_1TO2', 'WEEK_3', 'MORE_WEEK_3')),
	CHECK (Investable_time IN ('30MIN', '40MIN', '1HOUR', 'FREEDOM')),
    FOREIGN KEY (member_id) REFERENCES `users` (user_id)
 ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
 
-- 보류
 CREATE TABLE IF NOT EXISTS `trainer_files` (
    file_id BIGINT PRIMARY KEY AUTO_INCREMENT ,
    trainer_id BIGINT NOT NULL,
    -- file_name BLOB
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 자유 게시판 
CREATE TABLE IF NOT EXISTS `posts`(
    post_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    writer_id BIGINT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    post_recommend_count INT UNSIGNED NOT NULL, -- 좋아요, 추천 (보류)
    view_count INT UNSIGNED NOT NULL, -- 조회수
    image LONGBLOB, -- 보류
    FOREIGN KEY (writer_id) REFERENCES users (user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `post_comments`(
    comment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
	content TEXT NOT NULL,
    commeter_id BIGINT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (commeter_id) REFERENCES users (user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `reviews`(
    review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL ,
    content TEXT NOT NULL,
    content_image LONGBLOB, -- 보류
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP ,
    review_score TINYINT UNSIGNED NOT NULL, -- 평점 
    FOREIGN KEY (match_id) REFERENCES matches(match_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 보류
CREATE TABLE IF NOT EXISTS `match_waiting_list` (
	match_waiting_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    match_application_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    match_admission BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;