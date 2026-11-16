-- 읽기 전용 계정 실습 (미검증 예제)
-- 계정 변경 SQL: 관리자 계정에서 실행

-- 1. 계정 생성 (최초 1회)
-- CREATE USER 'audiolog_reader'@'%'
-- IDENTIFIED BY 'REPLACE_WITH_STRONG_PASSWORD';

-- 2. SELECT 권한 부여
-- GRANT SELECT ON audiolog.* TO 'audiolog_reader'@'%';

-- 3. 권한 확인 (관리자)
-- SHOW GRANTS FOR 'audiolog_reader'@'%';

-- 4. 읽기 전용 계정으로 조회
-- SELECT COUNT(*) AS user_count FROM audiolog.users;

-- 5. INSERT 거부 확인
-- 예상: ERROR 1142 (INSERT command denied)
-- 읽기 전용 계정에서만 실행
-- INSERT INTO audiolog.users (email, nickname)
-- VALUES ('permission-test@example.com', 'PermissionTest');

-- 6. 실습 계정 삭제 (관리자)
-- DROP USER 'audiolog_reader'@'%';

-- 실행 결과 미검증
