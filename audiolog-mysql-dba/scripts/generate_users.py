
import os
import uuid

import mysql.connector
# 가상의 데이터 생성을 위한 라이브러리 사용
from faker import Faker
from dotenv import load_dotenv

# 환경변수 불러오기
load_dotenv()

fake = Faker()

TARGET_USERS = 1000

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
        # 현재 회원 수 확인
        cursor.execute("SELECT COUNT(*) FROM users")
        current_count = cursor.fetchone()[0]

        # 추가 생성할 회원 수 계산
        remaining = max(0, TARGET_USERS - current_count)

        print(f"현재 회원 수: {current_count}")
        print(f"추가할 회원 수: {remaining}")

        if remaining > 0:
            users = []

            for _ in range(remaining):
                # 중복 가능성을 낮춘 테스트 이메일
                unique_id = uuid.uuid4().hex

                email = f"test_{unique_id}@example.com"
                nickname = fake.user_name()

                users.append((email, nickname, "active"))

            # 회원 데이터 일괄 등록
            sql = """
                INSERT INTO users (email, nickname, status)
                VALUES (%s, %s, %s)
            """

            cursor.executemany(sql, users)

            # 변경사항 확정
            connection.commit()

            print(f"회원 {cursor.rowcount}건 추가 완료")

        else:
            print("이미 목표 회원 수에 도달했습니다.")

    except mysql.connector.Error as e:
        # 오류 발생 시 변경 취소
        connection.rollback()
        print(f"MySQL 오류 발생: {e}")
        raise

    finally:
        # 커서 종료
        cursor.close()

finally:
    # DB 연결 종료
    connection.close()
