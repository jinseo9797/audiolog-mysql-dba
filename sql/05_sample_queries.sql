-- 초기 데이터·JOIN·트랜잭션 예제
-- 초기 INSERT: 새 DB에서만 실행
USE audiolog;

-- 테스트 회원 3건 (새 DB 전용)
-- INSERT INTO users (email, nickname, status) VALUES
-- ('user01@example.com', 'AudioFan', 'active'),
-- ('user02@example.com', 'MusicLover', 'active'),
-- ('user03@example.com', 'PodcastFan', 'inactive');

-- 테스트 콘텐츠 5건 (새 DB 전용)
-- INSERT INTO contents (title, category, duration_sec, is_available) VALUES
-- ('Morning Podcast', 'podcast', 1800, TRUE),
-- ('Relaxing Music', 'music', 240, TRUE),
-- ('Database Basics', 'audiobook', 3600, TRUE),
-- ('Tech Talk', 'podcast', 2700, TRUE),
-- ('Old Music Track', 'music', 200, FALSE);

-- 청취 기록 5건 (실제 ID 확인)
-- INSERT INTO listening_history (user_id, content_id, listened_at, play_sec) VALUES
-- (1, 1, '2026-11-15 10:00:00', 1200),
-- (1, 2, '2026-11-15 11:00:00', 240),
-- (2, 1, '2026-11-15 12:00:00', 1800),
-- (2, 3, '2026-11-15 13:00:00', 1500),
-- (3, 4, '2026-11-15 14:00:00', 900);

-- 회원·콘텐츠 JOIN 조회
SELECT u.nickname, c.title, c.category, lh.listened_at, lh.play_sec
FROM listening_history AS lh
INNER JOIN users AS u ON lh.user_id = u.user_id
INNER JOIN contents AS c ON lh.content_id = c.content_id
ORDER BY lh.listened_at DESC
LIMIT 20;

-- 트랜잭션 예제 (ROLLBACK으로 종료)
-- START TRANSACTION;
-- UPDATE contents SET title = 'classic' WHERE content_id = 3;
-- SELECT content_id, title FROM contents WHERE content_id = 3;
-- ROLLBACK;

-- 서버 상태 조회
SHOW GLOBAL STATUS LIKE 'Uptime';
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW GLOBAL STATUS LIKE 'Connections';
