CREATE DATABASE IF NOT EXISTS `fit_mate_db`
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `fit_mate_db`;

CREATE TABLE IF NOT EXISTS `roles` (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,	
    name VARCHAR(50) NOT NULL UNIQUE 
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `users` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NOT NULL,
    username VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(25) NOT NULL,
    birthdate DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    profile_image_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    CHECK (gender IN ('MAN', 'WOMAN')) 
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `members` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,  
    member_address VARCHAR(255) NOT NULL,
    one_day_ticket_count TINYINT DEFAULT 3,
    status VARCHAR(20) NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE, -- 구독 여부
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CHECK (status IN ('NOT_PAYMENT', 'PAYMENT', 'REJECT'))
    -- NOT_PAYMENT: "미결제", PAYMENT: "결제", REJECT: "거절"
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `subscriptions` (
	 id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    price INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_infos`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
	job_address VARCHAR(255) NOT NULL,
    attachment_file_id BIGINT,
	short_introduce VARCHAR(150),
    long_introduce TEXT,
    status VARCHAR(20) NOT NULL,
	education_name VARCHAR(100),
    education_entrance VARCHAR(10),
    education_graduate VARCHAR(10),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CHECK (status IN ('PENDING', 'APPROVE', 'REJECT'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_careers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    company_join DATE NOT NULL,
    company_quit DATE NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_licenses` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	trainer_id BIGINT NOT NULL,
    license_type VARCHAR(20) NOT NULL,
    license_name VARCHAR(100) NOT NULL,
    license_image_id BIGINT,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(id),
    CHECK (license_type IN('LICENSE', 'CERTIFICATE', 'AWARD_DETAIL')) 
    -- LICENSE: "자격증", CERTIFICATE: "수료증, AWARD_DETAIL: "수상내역"
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `match_waiting_list` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL UNIQUE,
    trainer_id BIGINT NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id),
    CHECK (approved_status IN ('NOT_APPROVED', 'APPROVED', 'REJECT'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE match_waiting_list
ADD COLUMN reject_response TEXT;

CREATE TABLE IF NOT EXISTS `matches`(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL UNIQUE,
    trainer_id BIGINT NOT NULL,
    matched_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    is_maintained BOOLEAN DEFAULT TRUE,
    UNIQUE KEY (member_id, trainer_id),
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE  IF NOT EXISTS `personal_community_board_categories` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(20) NOT NULL, 
    CHECK(category_name IN ('MEAL', 'ROUTINE', 'COMMUNITY' )) 
    -- MEAL: "식단", ROUTINE: "운동루틴", COMMUNITY: "커뮤니티"
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `personal_community_board`(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    post_title VARCHAR(100) NOT NULL,
    post_content TEXT NOT NULL,
    writer_id BIGINT NOT NULL,
    view_count BIGINT NOT NULL DEFAULT 0,
    post_like BIGINT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES matches(id),
    FOREIGN KEY (writer_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES personal_community_board_categories(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `personal_community_board_comments` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    board_id BIGINT NOT NULL,
    commenter_id BIGINT NOT NULL, 
    comment_content TEXT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(board_id) REFERENCES personal_community_board (id),
    FOREIGN KEY(commenter_id) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `notes` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    note_text TEXT NOT NULL,
    note_writer BIGINT NOT NULL, 
    note_receiver BIGINT NOT NULL, 
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_writer) REFERENCES users(id),
    FOREIGN KEY (note_receiver) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `one_day_tickets`(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    issued_at DATE NOT NULL,
    used_at DATE,
    canceled_at DATE,
    cancel_reason VARCHAR(255),
    status VARCHAR(50) NOT NULL,  
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id),
    CHECK (status IN ('ISSUANCE', 'USED', 'CANCEL'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `coupons`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    expiration_period DATE NOT NULL,
    used_date  TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
	status VARCHAR(50) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id),
	CHECK (status IN ('NOT_USED', 'APPLICATION', 'COMPLETE', 'EXPIRED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `member_forms`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    is_submit BOOLEAN DEFAULT FALSE,
    bodyform VARCHAR(30) NOT NULL,
    goal VARCHAR(30) NOT NULL,
    bmi VARCHAR(30) NOT NULL,
    improved_part VARCHAR(30)  NOT NULL,
    preferred_diet VARCHAR(30) NOT NULL,
    sugar_intake VARCHAR(30) NOT NULL,
    water_intake VARCHAR(30)  NOT NULL,
    height TINYINT UNSIGNED NOT NULL,
    weight TINYINT UNSIGNED NOT NULL,
    weight_goal TINYINT UNSIGNED NOT NULL,
    physical_level TINYINT UNSIGNED NOT NULL,
    exercising_problem VARCHAR(30) NOT NULL,
    pushup_level VARCHAR(30) NOT NULL,
    pullup_level VARCHAR(30) NOT NULL,
    exercise_frequency VARCHAR(30) NOT NULL,
    investable_time VARCHAR(30) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members (id),
	CHECK (bodyform IN ('SLIM', 'NORMAL', 'FAT')),
    CHECK (goal IN('DIET', 'IMPROVEMENT_OF_MUSCLE', 'PERFORMANCE')),
    CHECK(bmi IN('LESS_18', 'BETWEEN_18TO23', 'BETWEEN_23TO25', 'MORE_25')),
    CHECK (improved_part IN ('CHEST', 'ARM', 'STOMACH', 'LEG', 'NOT_APPLICABLE')),
    CHECK (preferred_diet IN ('VEGETARIAN', 'VEGAN', 'KITO', 'MEDITERRANEAN', 'CANIBORE', 'NOT_APPLICABLE')),
    CHECK (sugar_intake IN ('DONT_OFTEN', 'WEEK_3TO5', 'EVERYDAY')),
    CHECK (water_intake IN ('COFFEE_TEA', 'LESS_2', 'BETWEEN_2TO6', 'BETWEEN_7TO10', 'MORE_10')),
	CHECK (exercising_problem IN ('MOTIVATION', 'EFFECT', 'HARD', 'PLAN', 'COACHING', 'NOT_APPLICABLE')),
    CHECK (pushup_level IN ('LESS_5', 'BETWEEN_5TO10', 'MORE_10')), 
    CHECK (pullup_level IN ('LESS_5', 'BETWEEN_5TO10', 'MORE_10')),
	CHECK (exercise_frequency IN ('NEVER', 'WEEK_1TO2', 'WEEK_3', 'MORE_WEEK_3')),
	CHECK (investable_time IN ('MIN30', 'MIN40', 'HOUR1', 'FREEDOM'))
 ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `reviews`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL ,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    review_score TINYINT UNSIGNED NOT NULL,
    recommend_count INT UNSIGNED NOT NULL,
    FOREIGN KEY (match_id) REFERENCES matches(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `review_comments`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	review_id BIGINT NOT NULL,
    match_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES reviews(id),
	FOREIGN KEY (match_id) REFERENCES matches(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `upload_files` (
	id BIGINT AUTO_INCREMENT PRIMARY KEY,
    original_name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL, 
    file_path VARCHAR(500) NOT NULL, 
    file_type VARCHAR(100), 
    file_size BIGINT NOT NULL, 
    target_id BIGINT NOT NULL,
    target_type VARCHAR(30) NOT NULL,
    license_id BIGINT,
    CHECK (target_type IN ('PROFILE', 'BOARD', 'INFOS', 'LICENSE', 'ATTACHMENT', 'REVIEW')),
    -- PROFILE: user 프로필, MEAL: 식단 게시판, ROUTINE: 운동루틴 게시판, COMMUNITY: 커뮤니티 게시판,
    -- TRAINER_INFOS: 트레이너 긴 소개 파일들, TRAINER_LICENSE: 자격증, TRAINER_ATTACHMENT: 계약서,
    -- REVIEW: 리뷰.
    INDEX idx_target (target_id, target_type)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `users`
ADD CONSTRAINT fk_users_profile_image
FOREIGN KEY (profile_image_id) REFERENCES upload_files(id) ON DELETE CASCADE;

ALTER TABLE `trainer_infos`
ADD CONSTRAINT fk_trainer_infos_attachment_file
FOREIGN KEY (attachment_file_id) REFERENCES upload_files(id) ON DELETE CASCADE;

ALTER TABLE `trainer_licenses`
ADD CONSTRAINT fk_trainer_licenses_image
FOREIGN KEY (license_image_id) REFERENCES upload_files(id);

CREATE TABLE `trainer_change_logs` (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    trainer_id BIGINT NOT NULL,
    username VARCHAR(20),
    prev_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_by BIGINT,
    change_reason VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW `trainer_list_view` AS
SELECT
	t.id AS trainer_id,
	u.username,
	u.name,
	u.birthdate,
	t.job_address,
	u.created_at,
	t.status
FROM
	trainer_infos t
JOIN
	users u ON t.user_id = u.id
WHERE
	u.role_id = (SELECT id FROM roles WHERE name = 'TRAINER');
    
    CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    order_id VARCHAR(255) NOT NULL UNIQUE,     
  
	amount INT NOT NULL,
    payment_status VARCHAR(50) NOT NULL,             
    payment_method VARCHAR(50) NOT NULL, 
    
    member_id BIGINT NOT NULL,              
    subscription_id BIGINT UNIQUE,          

    CONSTRAINT fk_payments_member FOREIGN KEY (member_id) REFERENCES members(id),
    CONSTRAINT fk_payments_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    CHECK (payment_status IN("READY", "SUCCESS", "FAIL" )),
    CHECK (payment_method IN("KAKAO_PAY"))
)CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


INSERT INTO roles (name)
VALUES
	('MEMBER'), ('TRAINER'), ('ADMIN');