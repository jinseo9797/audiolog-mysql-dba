
import os
import random
from datetime import datetime, timedelta

import mysql.connector
from dotenv import load_dotenv

# 환경변수 불러오기
load_dotenv()

TARGET_COUNT = 100000
BATCH_SIZE = 5000

START_DATE = datetime(2026, 1, 1)
END_DATE = datetime(2026, 11, 15)

# MySQL 접속
connection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT")),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

try:
    cursor = connection.cursor()

    try:
        # 기존 청취 기록 건수 확인
        cursor.execute("SELECT COUNT(*) FROM listening_history")
        current_count = cursor.fetchone()[0]

        remaining = max(0, TARGET_COUNT - current_count)

        print(f"현재 청취 기록: {current_count}")
        print(f"추가할 청취 기록: {remaining}")

        # 실제 회원 ID 조회
        cursor.execute("SELECT user_id FROM users")
        user_ids = [row[0] for row in cursor.fetchall()]

        # 실제 콘텐츠 ID와 재생 시간 조회
        cursor.execute("""
            SELECT content_id, duration_sec
            FROM contents
        """)
        content_data = cursor.fetchall()

        if remaining > 0 and (not user_ids or not content_data):
            raise ValueError("회원 또는 콘텐츠 데이터가 없습니다.")

        # 청취 기록 INSERT 쿼리
        sql = """
            INSERT INTO listening_history
                (user_id, content_id, listened_at, play_sec)
            VALUES (%s, %s, %s, %s)
        """

        inserted = 0

        while inserted < remaining:
            batch = []

            # 이번 배치의 데이터 건수
            batch_count = min(BATCH_SIZE, remaining - inserted)

            for _ in range(batch_count):
                # 회원과 콘텐츠 무작위 선택
                user_id = random.choice(user_ids)
                content_id, duration_sec = random.choice(content_data)

                # 청취 일시 생성
                time_range = int(
                    (END_DATE - START_DATE).total_seconds()
                )
                random_seconds = random.randint(0, time_range)
                listened_at = START_DATE + timedelta(
                    seconds=random_seconds
                )

                # 실제 청취 시간 생성
                play_sec = random.randint(0, duration_sec)

                batch.append((
                    user_id,
                    content_id,
                    listened_at,
                    play_sec
                ))

            try:
                # 배치 단위 데이터 삽입
                cursor.executemany(sql, batch)

                # 배치 단위 변경 확정
                connection.commit()

                inserted += batch_count

                print(f"추가 완료: {inserted}/{remaining}")

            except mysql.connector.Error:
                # 현재 미커밋 배치 취소
                connection.rollback()
                raise

        print("청취 기록 생성 완료")

    finally:
        # 커서 종료
        cursor.close()

finally:
    # DB 연결 종료
    connection.close()
