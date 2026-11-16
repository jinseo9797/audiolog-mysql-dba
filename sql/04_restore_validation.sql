-- 원본·복원본 데이터 비교
-- audiolog_restore 복원 후 실행
-- 비교 중 원본 데이터 변경 주의
-- 조회 전용 SQL

-- 1. 테이블 건수
SELECT 'users' AS table_name,
       (SELECT COUNT(*) FROM audiolog.users) AS original_count,
       (SELECT COUNT(*) FROM audiolog_restore.users) AS restored_count
UNION ALL
SELECT 'contents',
       (SELECT COUNT(*) FROM audiolog.contents),
       (SELECT COUNT(*) FROM audiolog_restore.contents)
UNION ALL
SELECT 'listening_history',
       (SELECT COUNT(*) FROM audiolog.listening_history),
       (SELECT COUNT(*) FROM audiolog_restore.listening_history);

-- 2. 회원 데이터 양방향 비교
SELECT COUNT(*) AS users_mismatch_count
FROM (
    SELECT o.user_id
    FROM audiolog.users AS o
    LEFT JOIN audiolog_restore.users AS r ON o.user_id = r.user_id
    WHERE r.user_id IS NULL
       OR NOT (BINARY o.email <=> BINARY r.email)
       OR NOT (BINARY o.nickname <=> BINARY r.nickname)
       OR NOT (o.created_at <=> r.created_at)
       OR NOT (BINARY o.status <=> BINARY r.status)
    UNION ALL
    SELECT r.user_id
    FROM audiolog_restore.users AS r
    LEFT JOIN audiolog.users AS o ON r.user_id = o.user_id
    WHERE o.user_id IS NULL
) AS differences;

-- 3. 콘텐츠 데이터 양방향 비교
SELECT COUNT(*) AS contents_mismatch_count
FROM (
    SELECT o.content_id
    FROM audiolog.contents AS o
    LEFT JOIN audiolog_restore.contents AS r ON o.content_id = r.content_id
    WHERE r.content_id IS NULL
       OR NOT (BINARY o.title <=> BINARY r.title)
       OR NOT (BINARY o.category <=> BINARY r.category)
       OR NOT (o.duration_sec <=> r.duration_sec)
       OR NOT (o.created_at <=> r.created_at)
       OR NOT (o.is_available <=> r.is_available)
    UNION ALL
    SELECT r.content_id
    FROM audiolog_restore.contents AS r
    LEFT JOIN audiolog.contents AS o ON r.content_id = o.content_id
    WHERE o.content_id IS NULL
) AS differences;

-- 4. 청취 기록 양방향 비교
SELECT COUNT(*) AS listening_history_mismatch_count
FROM (
    SELECT o.history_id
    FROM audiolog.listening_history AS o
    LEFT JOIN audiolog_restore.listening_history AS r
        ON o.history_id = r.history_id
    WHERE r.history_id IS NULL
       OR NOT (o.user_id <=> r.user_id)
       OR NOT (o.content_id <=> r.content_id)
       OR NOT (o.listened_at <=> r.listened_at)
       OR NOT (o.play_sec <=> r.play_sec)
    UNION ALL
    SELECT r.history_id
    FROM audiolog_restore.listening_history AS r
    LEFT JOIN audiolog.listening_history AS o
        ON r.history_id = o.history_id
    WHERE o.history_id IS NULL
) AS differences;

-- 5. 복원본 FK 확인
SELECT COUNT(*) AS invalid_user_count
FROM audiolog_restore.listening_history AS lh
LEFT JOIN audiolog_restore.users AS u ON lh.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS invalid_content_count
FROM audiolog_restore.listening_history AS lh
LEFT JOIN audiolog_restore.contents AS c ON lh.content_id = c.content_id
WHERE c.content_id IS NULL;

-- 6. 제약조건 비교
SELECT table_schema, table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema IN ('audiolog', 'audiolog_restore')
ORDER BY table_name, constraint_type, constraint_name, table_schema;

-- 7. 인덱스 비교
SELECT table_schema, table_name, index_name, non_unique,
       seq_in_index, column_name, collation, is_visible
FROM information_schema.statistics
WHERE table_schema IN ('audiolog', 'audiolog_restore')
ORDER BY table_name, index_name, seq_in_index, table_schema;

-- 8. 테이블 정의 확인
SHOW CREATE TABLE audiolog.listening_history;
SHOW CREATE TABLE audiolog_restore.listening_history;
