CREATE DATABASE IF NOT EXISTS `fit_mate_db`
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `fit_mate_db`;

CREATE TABLE IF NOT EXISTS `roles` (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,	
    name VARCHAR(50) NOT NULL UNIQUE 
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO roles (name)
VALUES
	('MEMBER'), ('TRAINER'), ('ADMIN');

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
    FOREIGN KEY (role_id) REFERENCES roles(id),
    CHECK (gender IN ('MAN', 'WOMAN')) 
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `members` (
	 id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL,  
    member_address VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE, -- 구독 여부
    FOREIGN KEY (user_id) REFERENCES users(id),
    CHECK (status IN ('NOT_PAYMENT', 'PAYMENT', 'APPORVE', 'REJECT'))
    -- NOT_PAYMENT: "미결제", PAYMENT: "결제", APPORVE: "승인(구독)", REJECT: "거절"
);

CREATE TABLE IF NOT EXISTS `subscriptions` (
	 id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    subscription_name VARCHAR(50) NOT NULL,
    price INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    member_subscribe_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(id)
);

CREATE TABLE IF NOT EXISTS `trainer_infos`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
	job_address VARCHAR(255) NOT NULL,
	short_introduce VARCHAR(150),
    long_introduce TEXT,
    status VARCHAR(20) NOT NULL,
	education_name VARCHAR(100),
    education_entrance YEAR,
    education_graduate YEAR,
    FOREIGN KEY (user_id) REFERENCES users(id),
    CHECK (status IN ('NOT_APPROVE', 'APPORVE', 'REJECT')) 
);

CREATE TABLE IF NOT EXISTS `trainer_careers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    company_join YEAR NOT NULL,
    company_quit YEAR NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_licenses` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	trainer_id BIGINT NOT NULL,
    license_type VARCHAR(20) NOT NULL,
    license_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(id),
    CHECK (license_type IN('LICENSE', 'CERTIFICATE', 'AWARD_DETAIL')) 
    -- LICENSE: "자격증", CERTIFICATE: "수료증, AWARD_DETAIL: "수상내역"
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `match_waiting_list` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY (member_id, trainer_id),
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `matches`(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    matched_at DATE NOT NULL, 
    is_maintained BOOLEAN DEFAULT TRUE,
    UNIQUE KEY (member_id, trainer_id),
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `personal_community_board`(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    post_title VARCHAR(100) NOT NULL,
    post_content TEXT NOT NULL,
    writer_id BIGINT NOT NULL,
    view_count BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES matches(id),
    FOREIGN KEY (writer_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES personal_community_board_categories(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE  IF NOT EXISTS `personal_community_board_categories` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(20) NOT NULL, 
    CHECK(category_name IN ('MEAL', 'ROUTINE', 'COMMUNITY' )) 
    -- MEAL: "식단", ROUTINE: "운동루틴", COMMUNITY: "커뮤니티"
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

CREATE TABLE IF NOT EXISTS `oneday_tickets`(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL, 
    trainer_id BIGINT NOT NULL,
    applied_at DATE NOT NULL,  
    used_at DATE NOT NULL,  
    processed_at DATE NOT NULL, 
    reject_reason VARCHAR(100),
    status VARCHAR(50) NOT NULL,  
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id),
    CHECK (status IN ('NOT_USED', 'APPLICATION', 'ISSUANCE', 'APPROVAL', 'USED_COMPLETE', 'REJECT'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `coupons`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    coupon_image LONGBLOB,
    expiration_period DATE NOT NULL,
    used_date  TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
	status VARCHAR(50) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES users(id),
    FOREIGN KEY (trainer_id) REFERENCES users(id),
	CHECK (status IN ('NOT_USED', 'APPLICATION', 'COMPLETE', 'EXPIRED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `member_forms`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
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
    physical_level TINYINT UNSIGNED NOT NULL,
    exercising_problem VARCHAR(20) NOT NULL,
    pushup_level VARCHAR(20) NOT NULL,
    pullup_level VARCHAR(20) NOT NULL,
    exercise_frequency VARCHAR(20) NOT NULL,
    investable_time VARCHAR(20) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES users (id),
	CHECK (bodyform IN ('SLIM', 'NORMAL', 'FAT')),
    CHECK (goal IN('DIET', 'IMPROVEMENT_OF_MUSCLE', 'PERFORMANCE')),
    CHECK (improved_part IN ('CHEST', 'ARM', 'STOMACH', 'LEG', 'NOT_APPLICABLE')),
    CHECK (preferred_diet IN ('VEGETARIAN', 'VEGAN', 'KITO', 'MEDITERRANEAN', 'CANIBORE', 'NOT_APPLICABLE')),
    CHECK (sugar_intake IN ('DONT_OFTEN', 'WEEK_3TO5', 'EVERYDAY')),
    CHECK (water_intake IN ('COFFE_TEA', 'LESS_2', 'BETWEEN_2TO6', 'BETWEEN_7TO10', 'MORE_10')),
	CHECK (exercising_problem IN ('MOTIVATION', 'EFFECT', 'HARD', 'PLAN', 'COACHING', 'NOT_APPLICABLE')),
    CHECK (pushup_level IN ('LESS_5', 'BETWEEN_5TO10', 'MORE_10')), 
    CHECK (pullup_level IN ('LESS_5', 'BETWEEN_5TO10', 'MORE_10')),
	CHECK (exercise_frequency IN ('NEVER', 'WEEK_1TO2', 'WEEK_3', 'MORE_WEEK_3')),
	CHECK (investable_time IN ('MIN30', 'MIN30', 'HOUR1', 'FREEDOM'))
 ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `reviews`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL ,
    content TEXT NOT NULL,
    content_image LONGBLOB,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP ,
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
)CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `upload_files` (
	id BIGINT AUTO_INCREMENT PRIMARY KEY,
    original_name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL, 
    file_path VARCHAR(500) NOT NULL, 
    file_type VARCHAR(100), 
    file_size BIGINT NOT NULL, 
    target_id BIGINT NOT NULL,
    target_type ENUM('PROFILE', 'MEAL', 'ROUTINE', 'COMMUNITY', 'INFOS',
    'LICENSE', 'ATTACHMENT', 'REVIEW') NOT NULL,
    -- PROFILE: user 프로필, MEAL: 식단 게시판, ROUTINE: 운동루틴 게시판, COMMUNITY: 커뮤니티 게시판,
    -- TRAINER_INFOS: 트레이너 긴 소개 파일들, TRAINER_LICENSE: 자격증, TRAINER_ATTACHMENT: 계약서,
    -- REVIEW: 리뷰.
    INDEX idx_target (target_id, target_type)
)CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
