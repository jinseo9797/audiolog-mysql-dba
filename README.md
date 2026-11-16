# AudioLog MySQL DBA Lab

> 가상 오디오 콘텐츠 서비스의 **MySQL 데이터베이스 설계·검증·성능 비교·백업 및 복원** 개인 실습

MySQL을 활용해 테이블 설계, 데이터 검증, 인덱스 성능 비교, 백업·복원 과정을 직접 실습하고 결과를 기록했습니다. 실제 기업의 내부 시스템이나 운영 환경을 재현한 프로젝트는 아닙니다.

## 한눈에 보는 결과

| 항목 | 결과 |
|---|---|
| 가상 데이터 | 회원 1,000건 · 콘텐츠 100건 · 청취 기록 100,000건 |
| 인덱스 비교 | 단일 0.2062ms → 복합 0.1932ms (5회 평균, 약 6.3% 감소) |
| 백업·복원 검증 | 복원 후 데이터 불일치 0건 |
| 서버 상태 점검 | Python으로 연결·가동 시간·연결 수·데이터 건수 확인 |

> 조회 시간은 로컬 실습에서 측정한 값이며, 다른 환경에서 같은 성능을 보장하지 않습니다.

## 상세 실습 보고서

| 주제 | 주요 내용 |
|---|---|
| [01. 데이터베이스 설계](docs/01_database_design.md) | 테이블 3개 구성과 ERD |
| [02. 데이터 무결성 검증](docs/02_data_integrity.md) | 잘못된 입력이 차단되는지 확인 |
| [03. Python 데이터 생성](docs/03_data_generation.md) | 청취 기록 10만 건, 5천 건씩 나누어 저장 |
| [04. 인덱스 성능 비교](docs/04_index_tuning.md) | 실행 계획과 5회 측정 결과 |
| [05. 백업·복원 검증](docs/05_backup_restore.md) | 별도 DB 복원 후 원본과 비교 |
| [06. Python 상태 점검](docs/06_health_check.md) | MySQL 연결과 기본 상태 확인 |
| [07. 문제 해결 기록](docs/07_troubleshooting.md) | 잠금 대기 오류, 인덱스 비교 과정 |

## 사용 기술

**MySQL 8.4.13 (InnoDB)** · Docker Desktop · MySQL Workbench · SQL · Python · mysqldump

Python 라이브러리: `mysql-connector-python`, `Faker`, `python-dotenv`

## 프로젝트 구성

```text
audiolog-mysql-dba/
├── docs/             # 주제별 실습 보고서
├── sql/              # 테이블 생성·검증·인덱스·복원 비교 SQL
├── scripts/          # Python 데이터 생성 및 점검 코드
├── screenshots/      # 실행 결과 이미지 8장
├── requirements.txt
├── .gitignore
└── README.md
```

## 실습 환경 준비

1. 로컬 Docker에서 MySQL 8.4를 실행합니다.
2. [테이블 생성 SQL](sql/01_create_tables.sql)을 실행합니다.
3. `pip install -r requirements.txt`로 Python 패키지를 설치합니다.
4. 프로젝트 폴더에 `.env` 파일을 만들고 `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`을 설정합니다. **이 파일은 공개 저장소에 올리지 않습니다.**
5. [scripts 폴더](scripts/)의 회원 → 콘텐츠 → 청취 기록 생성 스크립트를 순서대로 실행합니다.

일부 SQL은 기존 데이터나 인덱스 상태를 확인한 후 개별 실행해야 하는 **실습 기록**입니다. 누구나 한 번에 실행할 수 있는 자동 설치 프로그램은 아닙니다.

---

**학습 내용:** 데이터가 잘 저장되는지 확인하는 것에서 나아가, 잘못된 입력 차단, 조회 계획 비교, 백업 후 실제 복원 확인까지 연습했습니다.
