-- 제약조건 검증
-- 오류 테스트: 필요한 INSERT만 실행
-- 예상 오류 코드 확인
-- 로컬 실습 DB에서만 실행

USE audiolog;

-- 테이블별 건수
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'contents', COUNT(*) FROM contents
UNION ALL SELECT 'listening_history', COUNT(*) FROM listening_history;

-- UNIQUE 위반: 1062
-- INSERT INTO users (email, nickname, status)
-- VALUES ('user01@example.com', 'DuplicateUser', 'active');

-- NOT NULL 위반: 1048
-- INSERT INTO users (email, nickname, status)
-- VALUES (NULL, 'NoEmailUser', 'active');

-- CHECK 위반: 3819
-- INSERT INTO users (email, nickname, status)
-- VALUES ('invalid-status@example.com', 'InvalidUser', 'deleted');

-- 회원 FK 위반: 1452
-- 테스트 ID 999999 미존재 확인
SELECT COUNT(*) AS user_999999_exists FROM users WHERE user_id = 999999;
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec)
-- SELECT 999999, c.content_id, NOW(), 100
-- FROM contents AS c ORDER BY c.content_id LIMIT 1;

-- 콘텐츠 FK 위반: 1452
-- 테스트 ID 999999 미존재 확인
SELECT COUNT(*) AS content_999999_exists FROM contents WHERE content_id = 999999;
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec)
-- SELECT u.user_id, 999999, NOW(), 100
-- FROM users AS u ORDER BY u.user_id LIMIT 1;

-- 음수 청취 시간: 3819
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec)
-- SELECT u.user_id, c.content_id, NOW(), -100
-- FROM (SELECT user_id FROM users ORDER BY user_id LIMIT 1) AS u
-- CROSS JOIN (SELECT content_id FROM contents ORDER BY content_id LIMIT 1) AS c;

-- 잘못된 FK 참조 확인
SELECT COUNT(*) AS invalid_user_count
FROM listening_history AS lh
LEFT JOIN users AS u ON lh.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS invalid_content_count
FROM listening_history AS lh
LEFT JOIN contents AS c ON lh.content_id = c.content_id
WHERE c.content_id IS NULL;

-- 음수 청취 기록 확인
SELECT COUNT(*) AS invalid_play_sec
FROM listening_history
WHERE play_sec < 0;

-- 제약조건 목록
SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'audiolog'
ORDER BY table_name, constraint_type, constraint_name;
