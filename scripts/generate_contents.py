import os
import random
import uuid

import mysql.connector
from dotenv import load_dotenv

# 환경변수 로드
load_dotenv()

TARGET_CONTENTS = 100

# 콘텐츠별 재생 시간 범위
DURATION_RANGES = {
    "music": (120, 360),
    "podcast": (600, 3600),
    "audiobook": (1800, 10800)
}

# MySQL 연결
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
        # 콘텐츠 수 조회
        cursor.execute("SELECT COUNT(*) FROM contents")
        current_count = cursor.fetchone()[0]

        # 부족한 콘텐츠 수 계산
        remaining = max(0, TARGET_CONTENTS - current_count)

        print(f"현재 콘텐츠 수: {current_count}")
        print(f"추가할 콘텐츠 수: {remaining}")

        if remaining > 0:
            contents = []

            for _ in range(remaining):
                # 콘텐츠 유형 선택
                category = random.choice(list(DURATION_RANGES.keys()))

                # 유형별 재생 시간 생성
                min_sec, max_sec = DURATION_RANGES[category]
                duration_sec = random.randint(min_sec, max_sec)

                # 고유 제목 생성
                unique_id = uuid.uuid4().hex[:12]
                title = f"{category.title()}_{unique_id}"

                # 서비스 제공 여부 설정
                is_available = random.random() < 0.9

                contents.append((
                    title,
                    category,
                    duration_sec,
                    is_available
                ))

            # 콘텐츠 일괄 등록
            sql = """
                INSERT INTO contents
                    (title, category, duration_sec, is_available)
                VALUES (%s, %s, %s, %s)
            """

            cursor.executemany(sql, contents)

            # 변경 확정
            connection.commit()

            print(f"콘텐츠 {cursor.rowcount}건 추가 완료")

        else:
            print("이미 목표 콘텐츠 수에 도달했습니다.")

    except mysql.connector.Error as e:
        # 오류 시 롤백
        connection.rollback()
        print(f"MySQL 오류 발생: {e}")
        raise

    finally:
        # 커서 종료
        cursor.close()

finally:
    # 연결 종료
    connection.close()
