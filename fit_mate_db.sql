CREATE DATABASE IF NOT EXISTS `fit_mate_db`;

USE `fit_mate_db`;

CREATE TABLE IF NOT EXISTS `users` (
	user_id BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    role_id VARCHAR(20) CHECK (role_id IN ('MEMBER', 'TRAINER')) NOT NULL,
    user_account VARCHAR(20) NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    user_image BLOB,
    user_name VARCHAR(25) NOT NULL,
    user_birthdate DATE NOT NULL,
    user_gender VARCHAR(20) CHECK (user_gender IN('MAN', 'WOMAN')) NOT NULL,
    user_phone VARCHAR(20) NOT NULL,
    user_email VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS `trainer_infos`(
	trainer_id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    trainer_job_adress VARCHAR(100) NOT NULL,
	trainer_short_introduce VARCHAR(150),
    trainer_long_introduce TEXT,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `trainer_educations` (
	education_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    education_name VARCHAR(100) NOT NULL,
    education_entrance YEAR NOT NULL,
    education_graduate YEAR NOT NULL,
    
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
);

CREATE TABLE IF NOT EXISTS `trainer_careers` (
	career_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    company_join YEAR NOT NULL,
    company_quit YEAR NOT NULL,
    
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
);

CREATE TABLE IF NOT EXISTS `trainer_licenses` (
	trainer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	license_id BIGINT NOT NULL,
    license_type VARCHAR(20) CHECK (license_type IN('1', '2', '3')) NOT NULL,
    license_name VARCHAR(100) NOT NULL,
    license_image BLOB NOT NULL,
    
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
);

CREATE TABLE IF NOT EXISTS `members` (
	member_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    member_address VARCHAR(255) NOT NULL,
    member_subscribe_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    member_is_approved BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `matches`(
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    match_id BIGINT NOT NULL,
    match_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    match_is_maintained BOOLEAN NOT NULL DEFAULT TRUE,
    
    PRIMARY KEY(member_id, trainer_id),
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
);


CREATE TABLE IF NOT EXISTS `personal_community_posts`(
    post_id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,
    post_title VARCHAR(100) NOT NULL,
    post_content TEXT,
    post_image BLOB,
    post_writer BIGINT NOT NULL,
    post_date DATETIME NOT NULL,
    
    FOREIGN KEY (match_id) REFERENCES matches(member_id),
    FOREIGN KEY (post_writer) REFERENCES users(user_id)
);

CREATE TABLE  IF NOT EXISTS`personal_community_categories` (
	category_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    category_name VARCHAR(20) NOT NULL,
    
    FOREIGN KEY (post_id) REFERENCES personal_community_posts (post_id)
);

CREATE TABLE IF NOT EXISTS `personal_community_comments` (
	comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    comment_contents TEXT NOT NULL,
    comment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY(post_id) REFERENCES personal_community_posts(post_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `notes` (
	note_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    note_writer BIGINT NOT NULL,
    note_text TEXT NOT NULL,
    note_receiver BIGINT NOT NULL,
    note_important BOOLEAN DEFAULT FALSE,
    note_is_readed BOOLEAN DEFAULT FALSE,
    note_send_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note_receive_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (note_writer) REFERENCES users(user_id),
    FOREIGN KEY (note_receiver) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `oneday_tickets`(
    ticket_id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    ticket_apply_date DATE,
    ticket_used_date DATE,
    ticket_processed_date DATE,
    ticket_reject_reason VARCHAR(100),
    ticket_progress VARCHAR(50) CHECK (ticket_progress IN 
		('NOT_USED', 'APPLICATION', 'IN_PROGRESS', 'COMPLETE', 'REJECT')) NOT NULL,
    
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `coupons`(
    coupon_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    coupon_image BLOB,
    coupon_expiration_period DATE NOT NULL,
    coupon_used_date DATE,
	coupon_progress VARCHAR(50) CHECK (coupon_progress IN 
		('NOT_USED', 'APPLICATION', 'COMPLETE', 'EXPIRED')) NOT NULL,
    
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `member_form`(
   form_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL ,
    age TINYINT NOT NULL,
    bodyform VARCHAR(10) CHECK (bodyform IN ('SLIM', 'NORMAL', 'FAT')) NOT NULL,
    goal VARCHAR(20) CHECK (goal IN('DIET', 'IMPROVEMENT_OF_MUSCLE', 'PERFORMANCE')) NOT NULL,
    bmi TINYINT UNSIGNED NOT NULL,
    improved_part VARCHAR(20) CHECK (improved_part IN ('CHEST', 'ARM', 'STOMACH', 'LEG', 'NOT_APPLICABLE')) NOT NULL,
    preferred_diet VARCHAR(20) CHECK (preferred_diet IN ('VEGETARIAM', 'VEGAN', 'KITO', 'MEDITERRANEAN', 'CANIBORE', 'NOT_APPLICABLE')) NOT NULL,
    sugar_intake VARCHAR(20) CHECK (sugar_intake IN ('DONT_OFTEN', 'WEEK_3TO5', 'EVERYDAY')) NOT NULL,
    water_intake VARCHAR(20) CHECK (water_intake IN ('COFFE_TEA', 'LESS_2', '2TO6', '7TO10', 'MORE_10')) NOT NULL,
    height TINYINT UNSIGNED NOT NULL,
    weight TINYINT UNSIGNED NOT NULL,
    weight_goal TINYINT UNSIGNED NOT NULL,
    pysical_level TINYINT UNSIGNED NOT NULL,
    exercising_problem VARCHAR(20) CHECK (exercising_problem IN ('MOTIVATION', 'EFFECT', 'HARD', 'PLAN', 'COACHING', 'NOT_APPLICABLE')) NOT NULL,
    pushup_level VARCHAR(20) CHECK (pushup_level IN ('LESS_5', '5TO10', 'MORE_10')) NOT NULL,
    pullup_level VARCHAR(20) CHECK (pullup_level IN ('LESS_5', '5TO10', 'MORE_10')) NOT NULL,
    exercise_frequency VARCHAR(20) CHECK (exercise_frequency IN ('NEVER', 'WEEK_1TO2', 'WEEK_3', 'MORE_WEEK_3')) NOT NULL,
    Investable_time VARCHAR(20) CHECK (Investable_time IN ('30MIN', '40MIN', '1HOUR', 'FREEDOM')) NOT NULL,
   FOREIGN KEY (user_id) REFERENCES `users`(user_id)
 );
 
 CREATE TABLE IF NOT EXISTS `trainer_files` (
    file_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT ,
    trainer_id BIGINT NOT NULL,
    -- file_name BLOB
    
    FOREIGN KEY (trainer_id) REFERENCES trainer_infos(trainer_id)
);

CREATE TABLE IF NOT EXISTS `fitmate_posts`(
    post_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    post_title VARCHAR(100) NOT NULL,
    post_content TEXT,
    user_id BIGINT NOT NULL,
    post_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    post_recommend_count INT UNSIGNED NOT NULL,
    post_view_count INT UNSIGNED NOT NULL,
    post_image BLOB,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `fitmate_post_comments`(
    comment_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT UNSIGNED NOT NULL,
	comment_content TEXT NOT NULL,
    user_id BIGINT NOT NULL,
    
    FOREIGN KEY (post_id) REFERENCES fitmate_posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS `reviews`(
    review_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    member_id BIGINT NOT NULL,
    review_content_text TEXT NOT NULL,
    review_content_image BLOB,
    review_write_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    review_score TINYINT UNSIGNED NOT NULL,
    
    FOREIGN KEY (trainer_id, member_id) REFERENCES matches(trainer_id, member_id)
);

CREATE TABLE IF NOT EXISTS `match_waiting_list` (
	member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    match_waiting_id BIGINT NOT NULL,
    match_application_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    match_admission BOOLEAN NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(member_id, trainer_id),
    FOREIGN KEY (member_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES users(user_id)
);
);