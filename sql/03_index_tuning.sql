-- 최근 청취 기록 인덱스 비교
-- 청취 기록 100,000건 기준
-- 기존 인덱스 확인 후 실행
-- 인덱스 변경 SQL은 선택 실행

USE audiolog;

-- 인덱스 목록 확인
SHOW INDEX FROM listening_history;

-- 최근 기록 20건 조회
SELECT history_id, user_id, content_id, listened_at, play_sec
FROM listening_history
WHERE user_id = 100
ORDER BY listened_at DESC
LIMIT 20;

-- 실행 계획 확인
-- 복합 인덱스 생성 후 기존 FK 인덱스 확인
-- SHOW INDEX 결과 확인
EXPLAIN
SELECT history_id, user_id, content_id, listened_at, play_sec
FROM listening_history
WHERE user_id = 100
ORDER BY listened_at DESC
LIMIT 20;

-- 복합 인덱스 생성 (없을 때만 실행)
-- CREATE INDEX idx_listening_user_date
-- ON listening_history (user_id, listened_at DESC);

-- 단일 인덱스 생성 (없을 때만 실행)
-- CREATE INDEX idx_listening_user_only
-- ON listening_history (user_id);

-- 단일 인덱스 측정 (생성 후 실행)
-- EXPLAIN ANALYZE
-- SELECT history_id, user_id, content_id, listened_at, play_sec
-- FROM listening_history FORCE INDEX (idx_listening_user_only)
-- WHERE user_id = 100
-- ORDER BY listened_at DESC
-- LIMIT 20;

-- 복합 인덱스 측정 (VISIBLE 확인)
-- EXPLAIN ANALYZE
-- SELECT history_id, user_id, content_id, listened_at, play_sec
-- FROM listening_history FORCE INDEX (idx_listening_user_date)
-- WHERE user_id = 100
-- ORDER BY listened_at DESC
-- LIMIT 20;

-- 각 인덱스 5회 측정
-- 실측 시간 (ms)
-- 단일: 0.209, 0.202, 0.211, 0.198, 0.211 / 평균 0.2062
-- 복합: 0.189, 0.193, 0.196, 0.191, 0.197 / 평균 0.1932
-- 평균 차이 약 6.3% (실습 환경 기준)

-- 복합 인덱스 숨김 (DDL 자동 커밋 주의)
-- ALTER TABLE listening_history
-- ALTER INDEX idx_listening_user_date INVISIBLE;

-- 복합 인덱스 VISIBLE 복구
-- ALTER TABLE listening_history
-- ALTER INDEX idx_listening_user_date VISIBLE;

-- 단일 인덱스 삭제 (FK 확인 후 실행)
-- DROP INDEX idx_listening_user_only ON listening_history;

-- 인덱스·FK 확인
SHOW INDEX FROM listening_history;
SHOW CREATE TABLE listening_history;

-- 저장 공간 조회 (table_rows는 추정치)
SELECT table_name, table_rows,
       ROUND(data_length / 1024 / 1024, 2) AS data_mb,
       ROUND(index_length / 1024 / 1024, 2) AS index_mb,
       ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb
FROM information_schema.tables
WHERE table_schema = 'audiolog'
ORDER BY table_name;
