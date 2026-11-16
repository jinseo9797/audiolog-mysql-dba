-- MySQL 최소 권한 계정 실습 (실행 전 문서 확인)
-- 신규 로컬 실습 DB에서 관리자 계정으로 실행
-- 비밀번호 예시 문구를 실제 강력한 비밀번호로 변경
-- 실제 서비스나 공용 DB에서는 실행 금지

-- 1. 읽기 전용 계정 생성: 한 번만 실행
-- CREATE USER 'audiolog_reader'@'%'
-- IDENTIFIED BY 'REPLACE_WITH_STRONG_PASSWORD';

-- 2. audiolog DB의 SELECT만 허용
-- GRANT SELECT ON audiolog.* TO 'audiolog_reader'@'%';

-- 3. 관리자 계정에서 부여한 권한 확인
-- SHOW GRANTS FOR 'audiolog_reader'@'%';

-- 4. 새 Workbench 연결에서 audiolog_reader 계정으로 로그인한 후 실행
-- SELECT COUNT(*) AS user_count FROM audiolog.users;

-- 5. 동일한 읽기 전용 계정에서 INSERT가 거부되는지 확인
-- 예상: ERROR 1142 (INSERT command denied)
-- 주의: 읽기 전용 권한이 확인된 별도 계정에서만 실행
-- INSERT INTO audiolog.users (email, nickname)
-- VALUES ('permission-test@example.com', 'PermissionTest');

-- 6. 실습 계정 정리 (필요한 경우 관리자 계정에서 실행)
-- DROP USER 'audiolog_reader'@'%';

-- 주의: 이 파일은 실습용 예제이며 아직 실행/검증 결과는 포함하지 않음
