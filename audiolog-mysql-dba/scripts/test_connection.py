import os

import mysql.connector
from dotenv import load_dotenv

# 환경변수 불러오기
load_dotenv()

# MySQL 접속
connection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT")),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

try:
    # SQL 실행
    cursor = connection.cursor()

    try:
        cursor.execute("SELECT VERSION(), DATABASE()")
        result = cursor.fetchone()

        print("MySQL 연결 성공")
        print(f"MySQL 버전: {result[0]}")
        print(f"데이터베이스: {result[1]}")

    finally:
        cursor.close()

finally:
    # DB 연결 종료
    connection.close()
