# 허갱소프트 깃블로그 운영 설명서
> **herkss.github.io** | Minimal Mistakes 테마 | Jekyll

---

## 📁 폴더 구조 한눈에 보기

```
herkss.github.io/
├── _config.yml          ← 블로그 전체 설정 (테마, 댓글, 플러그인 등)
├── _data/
│   └── navigation.yml   ← 상단 메뉴 (Home / Apps / UserGuide / Info)
├── _pages/              ← 고정 페이지 (Apps, UserGuide, Info)
│   ├── apps.md
│   ├── userguide.md
│   └── info.md
├── _posts/              ← 블로그 포스트 (Home에 자동 나열됨)
│   └── YYYY-MM-DD-제목.md
├── assets/
│   ├── css/
│   └── image/           ← 이미지 저장 폴더
└── index.md             ← Home 페이지
```

---

## 🏠 Home 화면 — 포스트 최신순 나열

`index.md`에 `layout: home`이 설정되어 있어, **`_posts/` 폴더에 파일을 추가하기만 하면 자동으로 최신순으로 Home에 표시**됩니다.

### ✅ 포스트 작성 규칙

**1. 파일명 형식 (필수)**
```
_posts/YYYY-MM-DD-영문-제목.md
```
예: `_posts/2026-06-12-baedalgil-v2.md`

> ⚠️ 날짜 형식이 틀리거나 미래 날짜면 빌드 후에도 안 보일 수 있습니다.

**2. Front Matter (파일 맨 위에 반드시 작성)**
```yaml
---
title: "포스트 제목"
excerpt: "목록에 표시될 짧은 설명"
categories:
  - apps          # 카테고리 (소문자)
tags:
  - flutter
  - 배달
layout: single
author_profile: true
toc: true         # 우측 목차 표시 (선택)
toc_sticky: true  # 스크롤해도 목차 고정 (선택)
toc_label: "목차"
---
```

**3. 본문은 Front Matter 아래에 마크다운으로 작성**
```markdown
---
(front matter)
---

## 제목
내용을 여기에 씁니다.

![이미지설명](/assets/image/파일명.jpg)
```

### 현재 포스트 목록 (Home에 표시되는 순서)

| 날짜 | 제목 |
|------|------|
| 2026-06-06 | 배달길 (최신) |
| 2026-06-02 | 배달길 매뉴얼 V 1.0.9 |
| 2026-05-20 | 배달길 매뉴얼 V 1.0 |
| 2026-05-04 | 배달길앱출시 |

---

## 📱 Apps 페이지 (`/apps/`)

**파일 위치:** `_pages/apps.md`

현재 내용이 "앱스" 한 줄뿐입니다. 아래처럼 채워주세요.

### 활용 방법 2가지

#### 방법 1️⃣ — 직접 앱 소개 콘텐츠 작성

```markdown
---
title: "APPS"
layout: single
permalink: /apps/
---

## 배달길 (Baedalgil)

배달파트너를 위한 커뮤니티 앱입니다.

[![Google Play](https://img.shields.io/badge/Google_Play-다운로드-green)](플레이스토어링크)

### 주요 기능
- 주변 라이더 지도 표시 & 채팅
- 친구 지도 마커표시 & 채팅
- 커뮤니티 게시판
- 정산 기능
```

#### 방법 2️⃣ — 카테고리 자동 목록 (권장)

`categories/apps.md` 파일이 이미 있어서, `apps` 카테고리 포스트가 자동 나열됩니다.  
`_pages/apps.md`에서 이 페이지로 링크를 걸거나, layout을 바꿔서 활용 가능합니다.

```markdown
---
title: "APPS"
layout: single
permalink: /apps/
---

앱 관련 포스트 모아보기 → [바로가기](/categories/apps/)

---

## 🔗 앱 다운로드
- [배달길 - Google Play Store](플레이스토어URL)
```

---

## 📖 UserGuide 페이지 (`/userguide/`)

**파일 위치:** `_pages/userguide.md`

사용 설명서를 직접 이 페이지에 쓰거나, 매뉴얼 포스트로 연결합니다.

### 추천 구성

```markdown
---
title: "UserGuide"
layout: single
permalink: /userguide/
toc: true
toc_sticky: true
toc_label: "목차"
---

## 배달길 사용법

### 1. 설치 방법
Google Play Store에서 "배달길"을 검색하여 설치합니다.

### 2. 회원가입
카카오 또는 구글 계정으로 로그인합니다.

### 3. 주요 기능 안내

#### 레이더 탭
주변 라이더의 위치를 지도에서 확인하고 채팅할 수 있습니다.

#### 커뮤니티 탭
지역 배달 라이더들과 정보를 공유합니다.

---

📘 **상세 매뉴얼은 아래 포스트를 참고하세요:**
- [배달길 매뉴얼 V1.0](/posts/2026-05-20-baedalgil-v1.0-manual/)
- [배달길 매뉴얼 V1.0.9](/posts/2026-06-02-baedalgil-v1.09/)
```

---

## ℹ️ Info 페이지 (`/info/`)

**파일 위치:** `_pages/info.md`

개발자/앱 소개, 개인정보처리방침 링크, 문의처 등을 넣는 곳입니다.

### 추천 구성

```markdown
---
title: "Info"
layout: single
permalink: /info/
---

## 허갱소프트 (HERGANG SOFT)

Flutter 기반 모바일 앱을 개발합니다.

## 앱 목록
- **배달길** - 배달파트너 커뮤니티 앱

## 문의
- Email: your@email.com
- GitHub: [github.com/herkss](https://github.com/herkss)

## 개인정보처리방침
- [배달길 개인정보처리방침](/baedalgil-pri/)
```

> 💡 `baedalgil-pri.md` 파일이 이미 루트에 있으니 바로 링크로 연결 가능합니다.

---

## 🖼️ 이미지 사용법

이미지는 `assets/image/` 폴더에 넣고 포스트에서 아래처럼 사용합니다.

```markdown
![설명](/assets/image/파일명.jpg)
```

현재 매뉴얼 이미지는 `assets/image/man/` 폴더에 `0.jpg ~ 15.jpg` 형태로 저장되어 있습니다.

```markdown
![매뉴얼 1](/assets/image/man/1.jpg)
```

---

## ⚙️ 상단 메뉴 수정

**파일 위치:** `_data/navigation.yml`

```yaml
main:
  - title: "Home"
    url: /
  - title: "Apps"
    url: /apps/
  - title: "UserGuide"
    url: /userguide/
  - title: "Info"
    url: /info/
```

메뉴를 추가하려면 같은 형식으로 항목을 추가하면 됩니다.

---

## 🚀 작업 흐름 요약

```
새 포스트 쓰기
  → _posts/YYYY-MM-DD-제목.md 생성
  → front matter 작성 (title, categories 등)
  → 본문 마크다운 작성
  → git add . && git commit -m "포스트 추가" && git push
  → 1~2분 후 https://herkss.github.io 에 자동 반영

고정 페이지 수정
  → _pages/apps.md, userguide.md, info.md 직접 편집
  → git push → 자동 반영
```

---

## 💡 자주 쓰는 마크다운 요소

```markdown
## 제목 2단계
### 제목 3단계

**굵게** / *기울임* / `코드`

> 인용문 블록

- 목록 항목 1
- 목록 항목 2

[링크텍스트](URL)
![이미지](경로)

| 표 제목1 | 표 제목2 |
|----------|----------|
| 내용1    | 내용2    |
```
