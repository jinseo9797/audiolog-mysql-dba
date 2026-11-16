import os
import mysql.connector

from dotenv import load_dotenv

# 환경변수 로드
load_dotenv()

connection = None

try:
    # MySQL 연결
    connection = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT")),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME"),
        connection_timeout=5
    )

    print("=== MySQL Health Check ===")

    if connection.is_connected():
        print("DB 연결 상태: 정상")

    cursor = connection.cursor()

    try:
        # 버전 조회
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()[0]
        print(f"MySQL 버전: {version}")

        # 가동 시간 조회
        cursor.execute("SHOW GLOBAL STATUS LIKE 'Uptime'")
        uptime = int(cursor.fetchone()[1])
        print(f"서버 가동 시간: {uptime}초")

        # 연결 수 조회
        cursor.execute("SHOW GLOBAL STATUS LIKE 'Threads_connected'")
        connected = int(cursor.fetchone()[1])
        print(f"현재 연결 수: {connected}")

        # 테이블 건수 조회
        tables = ["users", "contents", "listening_history"]

        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM `{table}`")
            count = cursor.fetchone()[0]
            print(f"{table}: {count}건")

        print("기본 상태 점검 완료")

    finally:
        # 커서 종료
        cursor.close()

except mysql.connector.Error as e:
    # 오류 출력
    print(f"MySQL 상태 점검 실패: {e}")
    raise

finally:
    # 연결 종료
    if connection is not None and connection.is_connected():
        connection.close()
