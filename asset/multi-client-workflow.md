---
title: "여러 고객 프로젝트 동시 운영 가이드"
layout: single
author_profile: true
toc: true
toc_label: "목차"
permalink: /asset/multi-client-workflow/
---

> **대상**: 홈페이지 제작업체 (여러 고객사의 사이트를 동시에 제작·배포)
> **도구**: Claude Code · Git · GitHub · Cloudflare (Pages / Workers) · direnv
> **목표**: 고객 정보를 안전하게 분리하면서 **작업 → 커밋 → 빌드 → 배포**를 최대한 손쉽게

---

## 1. 핵심 원칙 5가지

| # | 원칙 | 이유 |
|---|------|------|
| 1 | **고객 비밀번호는 절대 받지 않는다** | 유출 시 책임 소재가 업체로 넘어옴. 초대(멤버) 또는 범위 제한 토큰만 사용 |
| 2 | **고객 1곳 = 폴더 1개 = 토큰 세트 1개** | 다른 고객 계정에 잘못 배포하는 사고 원천 차단 |
| 3 | **토큰은 채팅·코드에 쓰지 않는다** | `.envrc` / 비밀번호 관리자 / GitHub Secrets 에만 보관 |
| 4 | **최소 권한 + 만료일 설정** | 토큰이 새어도 피해 범위가 작고, 자동으로 무효화됨 |
| 5 | **배포는 자동화(CI), 승인은 사람** | 로컬에서 실수로 배포하는 일을 줄이고 기록이 남음 |

---

## 2. 전체 구조 한눈에 보기

```
[고객사 계정]                         [업체 PC]                          [배포]
 GitHub 저장소  ── Collaborator 초대 ──▶ ~/clients/a-company/  ── git push ──▶ GitHub Actions
 Cloudflare    ── 제한 API 토큰 ──────▶   .envrc (direnv)                       │
                                         CLAUDE.md                             ▼
                                         .claude/settings.json          Cloudflare Pages
                                                                       (고객 계정에 배포)
```

---

## 3. 고객 계정 접근 받는 방법

### 3-1. GitHub — 업체 계정을 초대받기 (권장)

고객에게 아래 절차를 안내합니다.

1. 고객 저장소 → **Settings → Collaborators → Add people**
2. 업체 GitHub 아이디 입력 → 권한 **Write** 선택
3. 업체가 초대 메일 수락

> 이렇게 하면 업체 PC에서 `ssh` 또는 `gh auth login` **한 번만** 로그인해도 모든 고객 저장소에 접근할 수 있습니다. 고객별 토큰이 필요 없습니다.

**고객이 저장소가 없는 경우**: 업체 Organization에서 만들고, 완료 후 **Settings → Transfer ownership**으로 고객에게 이전.

### 3-2. Cloudflare — 멤버 초대 또는 제한 토큰

**방법 A. 멤버 초대 (대시보드 작업용)**
- 고객: **Manage Account → Members → Invite** → 업체 이메일, 역할은 필요한 것만 (예: *Cloudflare Pages* 관련 역할)

**방법 B. API 토큰 (CLI·자동 배포용)** — 고객이 발급하여 전달
- **My Profile → API Tokens → Create Token → Custom token**
- 권한 예시 (Pages 배포 기준):
  - `Account` → `Cloudflare Pages` → `Edit`
  - (DNS 수정이 필요할 때만) `Zone` → `DNS` → `Edit` → **해당 도메인만** 지정
- **Account Resources**: 해당 고객 계정만
- **TTL(만료일)**: 프로젝트 종료 예정일 + 1개월
- ⚠️ **Global API Key는 절대 받지 않기**

**토큰 전달 방법**: 카톡·메일 본문 ❌ → 1Password / Bitwarden 공유 항목, 또는 1회용 비밀 링크(예: Bitwarden Send) ✅

---

## 4. 업체 PC 초기 세팅 (최초 1회)

### 4-1. 필수 도구 설치 (Ubuntu 기준)

```bash
# Git, direnv
sudo apt install -y git direnv

# GitHub CLI
sudo apt install -y gh
gh auth login            # 업체 계정으로 1회 로그인

# Node.js + Wrangler (Cloudflare CLI)
npm install -g wrangler

# Claude Code
npm install -g @anthropic-ai/claude-code
```

### 4-2. direnv 활성화

`~/.bashrc` 맨 아래에 추가:

```bash
eval "$(direnv hook bash)"
```

→ 이제 폴더에 `cd` 하면 그 폴더의 `.envrc`가 자동 적용되고, 폴더를 나가면 자동 해제됩니다.

### 4-3. 전역 gitignore (토큰 파일 실수 커밋 방지)

```bash
cat >> ~/.gitignore_global <<'EOF'
.env
.env.*
.envrc
*.pem
*.key
EOF
git config --global core.excludesfile ~/.gitignore_global
```

> 모든 저장소에 공통 적용되므로 프로젝트마다 깜빡해도 안전합니다.

---

## 5. 고객별 폴더 구조

```
~/clients/
├── _template/                 ← 새 고객 시작 시 복사할 템플릿
├── a-company/
│   ├── .envrc                 ← A사 토큰 (git 제외)
│   ├── CLAUDE.md              ← A사 프로젝트 정보 (Claude가 자동으로 읽음)
│   ├── .claude/
│   │   └── settings.json      ← 위험 명령 승인 규칙
│   ├── .github/workflows/
│   │   └── deploy.yml         ← 자동 빌드·배포
│   ├── wrangler.toml          ← 배포 대상 계정 고정
│   └── src/ ...
├── b-company/
├── c-company/
├── d-company/
└── e-company/
```

### 5-1. `.envrc` — 고객별 비밀 정보

```bash
# ~/clients/a-company/.envrc
export CLIENT_NAME="A사"
export CLOUDFLARE_API_TOKEN="A사_전용_토큰"
export CLOUDFLARE_ACCOUNT_ID="A사_계정ID"
# 저장소 초대를 못 받은 경우에만:
# export GH_TOKEN="A사_저장소_전용_fine-grained_토큰"
```

처음 만들거나 수정한 뒤 1회 승인:

```bash
cd ~/clients/a-company
direnv allow
```

> **더 강한 보안**: 토큰을 파일에 평문으로 두지 않고 비밀번호 관리자 CLI에서 불러오기
> ```bash
> export CLOUDFLARE_API_TOKEN="$(bw get password cf-a-company)"   # Bitwarden CLI
> ```

### 5-2. `wrangler.toml` — 배포 계정 고정

```toml
name = "a-company-site"
account_id = "A사_계정ID"          # 다른 계정 토큰으로는 배포 실패 → 사고 방지
pages_build_output_dir = "./dist"
compatibility_date = "2026-11-01"
```

### 5-3. `CLAUDE.md` — Claude Code용 프로젝트 설명서

```markdown
# A사 홈페이지

## 기본 정보
- 고객: A사 (담당: 김OO 과장)
- 도메인: a-company.co.kr
- 저장소: github.com/a-company/website
- 배포: Cloudflare Pages (main 브랜치 push 시 자동)

## 기술 스택
- Astro + Tailwind CSS
- 빌드: npm run build → dist/

## 작업 규칙
- 작업은 항상 새 브랜치에서 (feature/작업명)
- main에 직접 push 금지 → PR로 병합
- 배포 명령(wrangler deploy) 직접 실행 금지 — CI가 처리
- 고객 개인정보(연락처, 주소 등)를 코드·커밋에 넣지 말 것

## 디자인
- 메인 컬러: #1E4FA3 / 서브: #F5F7FA
- 폰트: Pretendard
```

### 5-4. `.claude/settings.json` — 위험 명령 차단·승인

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm run dev)",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(gh pr merge:*)"
    ],
    "deny": [
      "Bash(wrangler deploy:*)",
      "Bash(wrangler pages deploy:*)",
      "Bash(git push --force:*)",
      "Read(./.envrc)",
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```

- `allow`: 묻지 않고 실행 (빌드, 커밋 등 일상 작업)
- `ask`: 실행 전 매번 확인 (push, 병합)
- `deny`: 금지 (로컬 직접 배포, 강제 push, **토큰 파일 읽기**)

> `Read(./.envrc)`를 금지해 두면 Claude가 토큰 내용 자체를 볼 일이 없습니다. 환경변수로는 정상 동작합니다.

---

## 6. 자동 빌드·배포 (GitHub Actions → Cloudflare Pages)

로컬에서는 **커밋·push만** 하고, 빌드와 배포는 GitHub가 처리합니다.

### 6-1. 고객 저장소에 Secret 등록 (고객 또는 업체가 1회)

저장소 → **Settings → Secrets and variables → Actions → New repository secret**

| 이름 | 값 |
|------|----|
| `CLOUDFLARE_API_TOKEN` | 고객 Cloudflare 토큰 |
| `CLOUDFLARE_ACCOUNT_ID` | 고객 계정 ID |

> 가장 좋은 방식은 **고객이 직접 Secret을 등록**하는 것입니다. 이 경우 업체는 Cloudflare 토큰을 아예 몰라도 배포가 됩니다.

### 6-2. `.github/workflows/deploy.yml`

{% raw %}
```yaml
name: Build & Deploy

on:
  push:
    branches: [main]          # main 병합 시 실서버 배포
  pull_request:               # PR마다 미리보기 배포

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npm run build

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy dist --project-name=a-company-site --branch=${{ github.head_ref || github.ref_name }}
```
{% endraw %}

**결과**
- PR을 올리면 → `https://<브랜치>.a-company-site.pages.dev` 미리보기 주소 생성 → **고객 확인용으로 전달**
- 고객 OK → PR 병합 → 실서버 자동 배포

> **더 간단한 대안**: Cloudflare 대시보드에서 Pages 프로젝트를 GitHub 저장소와 직접 연결(Git integration)하면 워크플로 파일 없이도 push 시 자동 빌드됩니다. 이 경우 고객이 Cloudflare에서 1회 연결만 해 주면 업체는 토큰이 전혀 필요 없습니다.

---

## 7. 하루 작업 흐름 (5개 고객 동시 진행)

### 7-1. 터미널 탭 5개 열기

```bash
# 탭 1
cd ~/clients/a-company && claude
# 탭 2
cd ~/clients/b-company && claude
# 탭 3~5 동일
```

- 각 Claude 세션은 **완전히 독립** — 대화, 토큰, 작업이 섞이지 않습니다.
- 탭 이름을 고객명으로 바꿔 두면 헷갈리지 않습니다.
- 한 탭에 작업을 맡겨 두고 다른 탭으로 넘어가 병행하면 됩니다.

### 7-2. 고객 1곳의 작업 사이클

```
① 브랜치 생성     → Claude: "메인 배너 교체 작업 브랜치 만들어줘"
② 작업            → Claude: "히어로 섹션을 첨부 시안대로 바꿔줘"
③ 로컬 확인       → npm run dev 로 브라우저 확인
④ 빌드 확인       → Claude: "빌드 돌려서 에러 없는지 확인해줘"
⑤ 커밋            → Claude: "변경사항 커밋해줘"
⑥ push + PR       → Claude: "push하고 PR 만들어줘"  (← 승인 요청 뜸)
⑦ 미리보기 전달    → CI가 만든 pages.dev 주소를 고객에게 전달
⑧ 고객 승인 후 병합 → 자동 실서버 배포
```

### 7-3. 자주 쓰는 Claude Code 요청 예시

| 상황 | 요청 문장 |
|------|----------|
| 시작 | "CLAUDE.md 읽고 현재 프로젝트 상태 요약해줘" |
| 수정 | "문의하기 페이지에 카카오맵 넣어줘, 주소는 ○○" |
| 점검 | "모바일에서 깨지는 부분 있는지 확인해줘" |
| 커밋 | "지금까지 변경사항 의미 단위로 나눠서 커밋해줘" |
| 배포 | "push하고 PR 만들어줘, 제목은 '메인 배너 교체'" |
| 확인 | "마지막 GitHub Actions 결과 알려줘" (`gh run list`) |

---

## 8. 새 고객 추가 체크리스트

```bash
# 1) 템플릿 복사
cp -r ~/clients/_template ~/clients/f-company
cd ~/clients/f-company

# 2) 고객 저장소 연결
git init && git remote add origin git@github.com:f-company/website.git

# 3) 값 채우기
#    .envrc / CLAUDE.md / wrangler.toml / deploy.yml 의 고객명·계정ID·프로젝트명

# 4) 토큰 적용
direnv allow

# 5) 토큰 확인 (내용 노출 없이 유효성만)
wrangler whoami
```

- [ ] GitHub Collaborator 초대 수락
- [ ] Cloudflare 토큰: 권한 최소화 + 만료일 확인
- [ ] 저장소 Secrets 등록 완료
- [ ] `wrangler.toml`의 `account_id`가 **이 고객** 것인지 재확인
- [ ] 토큰 관리표에 기록

---

## 9. 토큰 관리표 (예시)

비밀번호 관리자 또는 사내 문서에 보관 (**토큰 값 자체는 적지 않음**)

| 고객 | 서비스 | 토큰 이름 | 권한 범위 | 발급일 | 만료일 | 보관 위치 |
|------|--------|----------|----------|--------|--------|----------|
| A사 | Cloudflare | a-company-pages | Pages:Edit | 2026-11-01 | 2027-02-28 | Bitwarden |
| A사 | GitHub | (초대 방식) | Write | 2026-11-01 | - | - |
| B사 | Cloudflare | b-company-pages+dns | Pages:Edit, DNS:Edit(b.co.kr) | 2026-11-10 | 2027-03-31 | Bitwarden |

---

## 10. 프로젝트 종료 시 정리

1. 고객에게 **토큰 폐기 요청** (또는 고객 계정에서 업체가 직접 Roll/Delete)
2. GitHub Collaborator / Cloudflare 멤버 **초대 해제 요청**
3. 업체 PC: `~/clients/고객명/.envrc` 삭제
4. 필요 시 폴더 전체를 암호화 압축 후 보관, 원본 삭제
5. 토큰 관리표에 "폐기 완료" 기록

---

## 11. 사고 예방 & 대응

| 상황 | 예방 | 대응 |
|------|------|------|
| 다른 고객 계정에 배포 | `wrangler.toml`에 `account_id` 고정, 로컬 배포 금지 | 잘못 생성된 Pages 프로젝트 삭제 |
| 토큰을 실수로 커밋 | 전역 gitignore, `Read(.envrc)` 금지 | **즉시 토큰 폐기·재발급** (히스토리 삭제보다 우선) |
| 토큰을 채팅/메일에 노출 | 비밀번호 관리자로만 전달 | 즉시 폐기·재발급 |
| 업체 PC 분실 | 디스크 암호화, 화면 잠금 | 모든 고객 토큰 일괄 폐기, GitHub 세션 로그아웃 |
| 실서버 오류 배포 | PR 미리보기로 사전 확인 | Cloudflare Pages → Deployments → 이전 버전 **Rollback** |

> GitHub 저장소에는 **Secret scanning / Push protection** (Settings → Code security)을 켜 두면 토큰이 포함된 push를 GitHub가 자동으로 막아 줍니다.

---

## 12. 작업 화면 좌우 분할 + 코드 타이핑 화면

왼쪽에는 **Claude Code**, 오른쪽에는 Claude가 수정한 코드가 **한 글자씩 타이핑되듯** 표시되는 작업 화면입니다. 고객 미팅·시연 중에 작업 과정을 보여주기 좋습니다.

```
┌──────────────────────────────┬─────────────────────────────┐
│ Claude Code                  │ ▸ src/index.html  +12 -3     │
│                              │  14 │ <section class="hero"> │
│ > 메인 배너를 시안대로 바꿔줘 │  15 │   <h1>안녕하세요</h1>▌  │
│                              │                             │
└──────────────────────────────┴─────────────────────────────┘
```

### 12-1. 토큰(사용량) 추가 차감 여부

**추가 차감 없음.** 오른쪽 화면은 PC에서만 동작하는 작은 파이썬 프로그램으로, 파일 변경을 읽어 화면에 그리기만 합니다. Claude·인터넷과 연결되지 않으며, 사용량은 기존처럼 왼쪽 Claude Code 대화만 계산됩니다.

### 12-2. 보안 처리

- `.envrc`, `.env*`, `*.key`, `*.pem`, `*.jks` 등 **토큰·키 파일은 변경되어도 화면에 표시하지 않음**
- `.git`, `node_modules`, `dist`, `build`, `.claude` 폴더와 `*.log`, `*.lock`, `*.map` 파일은 감시 제외
- 시연 중 고객 비밀정보가 화면에 노출될 위험을 줄임

### 12-3. 설치 (최초 1회)

필요 도구: `tmux`, `python3`, `pygments` (문법 색상)

```bash
sudo apt install -y tmux python3-pygments
mkdir -p ~/bin
# 아래 두 파일을 ~/bin/codetype.py, ~/bin/work 로 저장
chmod +x ~/bin/codetype.py ~/bin/work
source ~/.profile     # ~/bin 을 PATH에 반영 (재로그인 후에는 자동)
```

### 12-4. 실행

```bash
work ~/clients/a-company        # 폴더 지정
cd ~/clients/b-company && work  # 현재 폴더
```

- 왼쪽: Claude Code 자동 실행 → 평소처럼 지시
- 오른쪽: 파일이 바뀔 때마다 변경된 줄을 색상과 함께 타이핑 효과로 표시
- 고객마다 별도 tmux 세션(폴더 이름)으로 열리므로 5개 고객을 동시에 띄워도 섞이지 않음

| 동작 | 방법 |
|------|------|
| 좌우 창 이동 | 마우스 클릭 |
| 잠시 나가기 (작업 유지) | `Ctrl+b` → `d` |
| 다시 들어가기 | 같은 폴더로 `work` 재실행 |
| 실행 중인 세션 목록 | `tmux ls` |
| 완전 종료 | 왼쪽 Claude 종료 + 오른쪽 `Ctrl+c` |

**타이핑 속도 조절**: `~/bin/work` 안의 `codetype.py` 실행 부분에 `--speed 0.03` (느리게) / `--speed 0.005` (빠르게) 추가. 기본값 `0.012`.

### 12-5. 스크립트 ① `~/bin/work` (좌우 분할 실행기)

```bash
#!/usr/bin/env bash
# 사용법: work [폴더]   — 왼쪽: Claude Code / 오른쪽: 코드 타이핑 화면
DIR="$(cd "${1:-.}" && pwd)" || exit 1
NAME="$(basename "$DIR" | tr -c 'a-zA-Z0-9_-' '_')"

if tmux has-session -t "$NAME" 2>/dev/null; then
  exec tmux attach -t "$NAME"
fi

tmux new-session -d -s "$NAME" -c "$DIR" -x "$(tput cols)" -y "$(tput lines)"
tmux set -t "$NAME" mouse on
tmux split-window -h -t "$NAME" -c "$DIR" -l 45% "python3 $HOME/bin/codetype.py '$DIR'; read"
tmux select-pane -t "$NAME".0
tmux send-keys -t "$NAME".0 "claude" Enter
exec tmux attach -t "$NAME"
```

### 12-6. 스크립트 ② `~/bin/codetype.py` (타이핑 표시기)

```python
#!/usr/bin/env python3
"""현재 폴더의 파일 변경을 감시해서, 새로 추가된 코드를 타이핑 효과로 보여준다.

사용법: codetype.py [폴더] [--speed 초/글자]
"""
import argparse
import difflib
import os
import random
import sys
import time
from collections import deque

from pygments.formatters import Terminal256Formatter
from pygments.lexers import TextLexer, guess_lexer_for_filename
from pygments.util import ClassNotFound

SKIP_DIRS = {".git", "node_modules", "dist", "build", ".next", ".astro",
             ".cache", "__pycache__", ".venv", "venv", ".claude"}
# 토큰·키가 들어있을 수 있는 파일은 화면에 절대 표시하지 않음
SECRET_NAMES = {".envrc", ".env", ".npmrc", ".netrc", "id_rsa", "id_ed25519"}
SECRET_EXTS = {".pem", ".key", ".p12", ".jks", ".keystore"}
SKIP_EXTS = {".log", ".lock", ".map", ".min.js"}
MAX_SIZE = 300_000

DIM, RESET, BOLD = "\033[2m", "\033[0m", "\033[1m"
CYAN, GREEN, RED = "\033[36m", "\033[32m", "\033[31m"

formatter = Terminal256Formatter(style="monokai")


def is_secret(name):
    return (name in SECRET_NAMES or name.startswith(".env.")
            or os.path.splitext(name)[1] in SECRET_EXTS)


def scan(root):
    files = {}
    for d, dirs, names in os.walk(root):
        dirs[:] = [x for x in dirs if x not in SKIP_DIRS]
        for n in names:
            if is_secret(n) or n.endswith(tuple(SKIP_EXTS)):
                continue
            p = os.path.join(d, n)
            try:
                st = os.stat(p)
            except OSError:
                continue
            if st.st_size <= MAX_SIZE:
                files[p] = st.st_mtime
    return files


def read_text(path):
    try:
        with open(path, "rb") as f:
            data = f.read()
    except OSError:
        return None
    if b"\0" in data:
        return None
    return data.decode("utf-8", errors="replace").splitlines()


def color_for(ttype):
    while ttype is not None:
        s = formatter.style_string.get(str(ttype))
        if s:
            return s[0]
        ttype = ttype.parent
    return ""


def typewrite(text, delay):
    for ch in text:
        sys.stdout.write(ch)
        sys.stdout.flush()
        if ch.strip():
            time.sleep(delay * random.uniform(0.4, 1.6))


def type_block(path, lines, start_no, delay):
    try:
        lexer = guess_lexer_for_filename(path, "\n".join(lines))
    except ClassNotFound:
        lexer = TextLexer()
    width = len(str(start_no + len(lines)))
    line_no = start_no
    sys.stdout.write(f"{DIM}{str(line_no).rjust(width)} │ {RESET}")
    for ttype, value in lexer.get_tokens("\n".join(lines) + "\n"):
        col = color_for(ttype)
        parts = value.split("\n")
        for i, part in enumerate(parts):
            if i > 0:
                sys.stdout.write(RESET + "\n")
                line_no += 1
                if line_no >= start_no + len(lines):
                    break
                sys.stdout.write(f"{DIM}{str(line_no).rjust(width)} │ {RESET}")
                time.sleep(delay * 6)
            sys.stdout.write(col)
            typewrite(part, delay)
            sys.stdout.write(RESET)


def header(path, root, added, removed):
    rel = os.path.relpath(path, root)
    stamp = time.strftime("%H:%M:%S")
    bar = "─" * max(4, 50 - len(rel))
    print(f"\n{CYAN}{BOLD}▸ {rel}{RESET} {DIM}{bar} {stamp}{RESET}  "
          f"{GREEN}+{added}{RESET} {RED}-{removed}{RESET}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("root", nargs="?", default=".")
    ap.add_argument("--speed", type=float, default=0.012, help="글자당 지연(초)")
    args = ap.parse_args()
    root = os.path.abspath(args.root)

    mtimes = scan(root)
    contents = {p: read_text(p) for p in mtimes}
    queue = deque()

    os.system("clear")
    print(f"{GREEN}{BOLD}● codetype{RESET} {DIM}감시 중: {root}{RESET}")
    print(f"{DIM}  Claude가 코드를 수정하면 여기에 실시간으로 입력됩니다...{RESET}")

    while True:
        now = scan(root)
        for p, m in now.items():
            if mtimes.get(p) == m:
                continue
            new = read_text(p)
            old = contents.get(p) or []
            contents[p] = new
            if new is None:
                continue
            sm = difflib.SequenceMatcher(None, old, new, autojunk=False)
            removed = sum(i2 - i1 for op, i1, i2, _, _ in sm.get_opcodes()
                          if op in ("replace", "delete"))
            hunks = [(j1, new[j1:j2]) for op, _, _, j1, j2 in sm.get_opcodes()
                     if op in ("replace", "insert")]
            if hunks or removed:
                queue.append((p, hunks, removed))
        mtimes = now

        if queue:
            p, hunks, removed = queue.popleft()
            added = sum(len(h) for _, h in hunks)
            header(p, root, added, removed)
            # 밀린 변경이 많으면 빠르게 타이핑
            delay = args.speed / (1 + len(queue)) if added < 400 else args.speed / 8
            for j, (start, lines) in enumerate(hunks):
                if j:
                    print(f"{DIM}    ⋮{RESET}")
                type_block(p, lines, start + 1, delay)
            if not hunks:
                print(f"{DIM}  (삭제만 있음){RESET}")
        else:
            time.sleep(0.5)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(RESET)
```

---

## 13. 요약

```
✔ 비밀번호 대신 → 초대 + 최소 권한 토큰
✔ 고객별 폴더 + direnv  → 토큰 자동 전환, 섞임 방지
✔ CLAUDE.md             → Claude가 고객별 맥락 자동 인지
✔ .claude/settings.json → 토큰 읽기·직접 배포 차단, push는 승인
✔ GitHub Actions        → push만 하면 빌드·배포 자동, 미리보기 URL로 고객 확인
✔ 종료 시 토큰 폐기     → 책임 범위 깔끔하게 종료
✔ work 명령            → 좌: Claude / 우: 코드 타이핑 화면 (추가 비용 없음)
```

*작성: 허갱소프트 · 2026-11-25*
