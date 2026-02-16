Hanyang Lab-Guardian (MVP)

실험실에서 시약을 폐액통에 버리기 전,
라벨(OCR) + 폐액통 QR 스캔으로 혼합 위험(발열/반응/화재) 가능성을 빠르게 안내하는 Flutter 앱(MVP)입니다.

주요 기능 (MVP 범위)
1) 시약 확인 (입력 / OCR)

사용자가 시약명을 직접 입력하거나

카메라로 라벨을 촬영해 OCR 후보(최대 3개) 를 제안합니다.

MVP에서는 시약을 3종(HCl, NaOH, Acetone) 만 지원합니다.

2) 폐액통 QR 스캔

폐액통 스티커 QR을 스캔해 폐액통 타입을 판별합니다.

Acid / Basic / Organic / Oxidizer / Other / Invalid

Invalid 인 경우:

화면 전환 없이 스캐너 화면에서 안내만 띄우고 계속 스캔합니다.

3) 혼합 안전 판정

간단한 룰 기반(MVP)으로 결과를 표시합니다.

OK: 같은 분류로 판단

STOP: 위험 조합

WARNING: 애매/불확실

4) 최근 기록(최근 5개)

시약 분석 결과를 최근 기록으로 저장하고 홈 화면에서 바로 접근할 수 있습니다.

실행 방법
1) 개발 환경

Flutter SDK 설치

Android Studio 또는 VS Code + Flutter extension

Android 에뮬레이터 또는 실제 기기

2) 의존성 설치
flutter pub get

3) 실행
flutter run

프로젝트 구조

lib/screens/

home_screen.dart : 홈 + 최근 기록

reagent_input_screen.dart : 시약 입력 + OCR 후보

reagent_result_screen.dart : 시약 결과 카드

waste_qr_screen.dart : 폐액통 QR 스캐너

verdict_screen.dart : 최종 판정 화면

lib/logic/

mixing_logic.dart : QR 파싱 + 혼합 판정 룰

lib/storage/

recent_store.dart : 최근 기록 저장(SharedPreferences)

lib/services/

ocr_service.dart : OCR 처리

groq_service.dart : (MVP 데모 모드) 시약 카드 생성/분석

MVP 지원 시약

HCl

NaOH

Acetone

그 외 입력 시에는 MVP 정책상 제한/안내하도록 구성할 수 있습니다.

보안/비밀키 관련

API Key 등 민감 정보는 레포에 포함하지 않습니다.

android/local.properties, key.properties, *.jks, *.keystore, .env 등은 커밋하지 마세요.

다음 개선 아이디어

더 많은 시약 데이터/DB 연동

실제 실험실 폐액통 QR 표준 포맷 정의

UI 디자인 정리(Material 3 기반 컴포넌트 통일)

위험 판정 매트릭스 확장 및 실험실 SOP 반영
