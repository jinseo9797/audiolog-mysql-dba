-- 회원별 최근 청취 기록 조회의 인덱스 비교
-- 기준 데이터: 가상 청취 기록 100,000건
-- 현재 프로젝트에는 복합 인덱스가 생성되어 있을 수 있음
-- CREATE/DROP/ALTER 명령은 주석 처리: 상태 확인 후 개별 실행

USE audiolog;

-- 인덱스 목록 및 가시성 확인
SHOW INDEX FROM listening_history;

-- 튜닝 대상 쿼리
SELECT history_id, user_id, content_id, listened_at, play_sec
FROM listening_history
WHERE user_id = 100
ORDER BY listened_at DESC
LIMIT 20;

-- 기존 FK 단일 인덱스가 존재했던 초기 상태의 실행 계획 확인
-- MySQL은 복합 인덱스 생성 시 자동 생성 FK 인덱스를 제거할 수 있음
-- 사용 가능한 인덱스는 반드시 SHOW INDEX로 확인
EXPLAIN
SELECT history_id, user_id, content_id, listened_at, play_sec
FROM listening_history
WHERE user_id = 100
ORDER BY listened_at DESC
LIMIT 20;

-- 복합 인덱스 최초 생성 시에만 사용 (이미 있으면 실행하지 않음)
-- CREATE INDEX idx_listening_user_date
-- ON listening_history (user_id, listened_at DESC);

-- 단일 인덱스 비교용 최초 생성 시에만 사용 (이미 있으면 실행하지 않음)
-- CREATE INDEX idx_listening_user_only
-- ON listening_history (user_id);

-- 단일 인덱스 비교: 반드시 idx_listening_user_only 생성 후 실행
-- EXPLAIN ANALYZE
-- SELECT history_id, user_id, content_id, listened_at, play_sec
-- FROM listening_history FORCE INDEX (idx_listening_user_only)
-- WHERE user_id = 100
-- ORDER BY listened_at DESC
-- LIMIT 20;

-- 복합 인덱스 비교: idx_listening_user_date가 존재하고 VISIBLE이어야 함
-- EXPLAIN ANALYZE
-- SELECT history_id, user_id, content_id, listened_at, play_sec
-- FROM listening_history FORCE INDEX (idx_listening_user_date)
-- WHERE user_id = 100
-- ORDER BY listened_at DESC
-- LIMIT 20;

-- 각 쿼리를 5회 반복 측정하여 actual time 종료값 기록
-- 프로젝트에서 관측한 5회 실측값(ms)
-- 단일: 0.209, 0.202, 0.211, 0.198, 0.211 / 평균 0.2062
-- 복합: 0.189, 0.193, 0.196, 0.191, 0.197 / 평균 0.1932
-- 5회 평균 차이 약 6.3%; 환경에 따른 편차가 있으므로 일반화 금지

-- 옵티마이저에서 복합 인덱스 숨김 (실습 시에만, DDL 암묵적 커밋 주의)
-- ALTER TABLE listening_history
-- ALTER INDEX idx_listening_user_date INVISIBLE;

-- 복합 인덱스 복구 (숨김 실습 후 반드시 실행)
-- ALTER TABLE listening_history
-- ALTER INDEX idx_listening_user_date VISIBLE;

-- 비교용 단일 인덱스 정리 (복합 인덱스 가시성과 FK 확인 후 실행)
-- DROP INDEX idx_listening_user_only ON listening_history;

-- 인덱스 및 FK 최종 확인
SHOW INDEX FROM listening_history;
SHOW CREATE TABLE listening_history;

-- 저장 공간 확인: InnoDB table_rows는 추정치
SELECT table_name, table_rows,
       ROUND(data_length / 1024 / 1024, 2) AS data_mb,
       ROUND(index_length / 1024 / 1024, 2) AS index_mb,
       ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb
FROM information_schema.tables
WHERE table_schema = 'audiolog'
ORDER BY table_name;
