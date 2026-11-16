-- AudioLog 가상 오디오 서비스 DB 스키마
-- 신규 환경에서 1회 실행용 / 기존 테이블 삭제하지 않음
-- 주의: IF NOT EXISTS는 기존 테이블 구조를 수정하지 않음

CREATE DATABASE IF NOT EXISTS audiolog
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE audiolog;

-- 회원 테이블
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    nickname VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_users_status
        CHECK (status IN ('active', 'inactive', 'banned'))
) ENGINE = InnoDB;

-- 콘텐츠 테이블
CREATE TABLE IF NOT EXISTS contents (
    content_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    category VARCHAR(20) NOT NULL,
    duration_sec INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_contents_category
        CHECK (category IN ('podcast', 'music', 'audiobook')),
    CONSTRAINT chk_contents_duration
        CHECK (duration_sec > 0),
    CONSTRAINT chk_contents_available
        CHECK (is_available IN (0, 1))
) ENGINE = InnoDB;

-- 청취 기록 테이블
CREATE TABLE IF NOT EXISTS listening_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    content_id BIGINT NOT NULL,
    listened_at DATETIME NOT NULL,
    play_sec INT NOT NULL,
    CONSTRAINT chk_listening_play_sec
        CHECK (play_sec >= 0),
    CONSTRAINT fk_listening_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_listening_content
        FOREIGN KEY (content_id) REFERENCES contents(content_id)
) ENGINE = InnoDB;

-- 생성된 테이블 및 제약조건 확인
SHOW TABLES;
SHOW CREATE TABLE users;
SHOW CREATE TABLE contents;
SHOW CREATE TABLE listening_history;
