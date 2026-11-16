-- PK / UNIQUE / NOT NULL / CHECK / FK 무결성 검증
-- 오류 유도 쿼리는 주석 처리됨: 각 항목을 하나씩 선택하여 실행
-- 예상 오류가 발생하면 해당 제약조건이 입력을 차단한 것
-- 실행 대상: 테스트 DB audiolog (운영 DB 사용 금지)

USE audiolog;

-- 검증 전 데이터 건수
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'contents', COUNT(*) FROM contents
UNION ALL SELECT 'listening_history', COUNT(*) FROM listening_history;

-- UNIQUE 위반 확인: 예상 오류 1062
-- INSERT INTO users (email, nickname, status)
-- VALUES ('user01@example.com', 'DuplicateUser', 'active');

-- NOT NULL 위반 확인: 예상 오류 1048
-- INSERT INTO users (email, nickname, status)
-- VALUES (NULL, 'NoEmailUser', 'active');

-- CHECK 위반 확인: 예상 오류 3819
-- INSERT INTO users (email, nickname, status)
-- VALUES ('invalid-status@example.com', 'InvalidUser', 'deleted');

-- FK 사용자 위반 확인: 예상 오류 1452
-- 999999가 실제 users.user_id에 없는지 먼저 확인
SELECT COUNT(*) AS user_999999_exists FROM users WHERE user_id = 999999;
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec)
-- SELECT 999999, c.content_id, NOW(), 100
-- FROM contents AS c ORDER BY c.content_id LIMIT 1;

-- FK 콘텐츠 위반 확인: 예상 오류 1452
-- 999999가 실제 contents.content_id에 없는지 먼저 확인
SELECT COUNT(*) AS content_999999_exists FROM contents WHERE content_id = 999999;
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec)
-- SELECT u.user_id, 999999, NOW(), 100
-- FROM users AS u ORDER BY u.user_id LIMIT 1;

-- CHECK 음수 청취 시간 확인: 예상 오류 3819
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec)
-- SELECT u.user_id, c.content_id, NOW(), -100
-- FROM (SELECT user_id FROM users ORDER BY user_id LIMIT 1) AS u
-- CROSS JOIN (SELECT content_id FROM contents ORDER BY content_id LIMIT 1) AS c;

-- FK 위반 데이터 존재 여부 검증
SELECT COUNT(*) AS invalid_user_count
FROM listening_history AS lh
LEFT JOIN users AS u ON lh.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS invalid_content_count
FROM listening_history AS lh
LEFT JOIN contents AS c ON lh.content_id = c.content_id
WHERE c.content_id IS NULL;

-- 음수 청취 시간 확인
SELECT COUNT(*) AS invalid_play_sec
FROM listening_history
WHERE play_sec < 0;

-- 테이블별 제약조건 확인
SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'audiolog'
ORDER BY table_name, constraint_type, constraint_name;
