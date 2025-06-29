# 📂 Foldergo

**macOS용 폴더 아이콘 일괄 변경 앱**

커스텀 `.png` 또는 `.icns` 아이콘을 여러 폴더에 한 번에 적용하세요.  
깔끔한 데스크탑, 나만의 폴더 스타일을 유지하는 가장 간단한 방법입니다.

---

## ✨ 주요 기능

- **폴더 아이콘 일괄 적용**: 선택한 아이콘을 여러 폴더에 한 번에 적용
- **아이콘 마스킹**: 원형, 별, 하트 등 다양한 마스크로 아이콘 모양 커스터마이즈
- **직관적인 UI**: 아이콘 파일과 폴더를 선택하는 간단한 인터페이스
- **Finder 친화적**: 폴더 정리 습관을 시각적으로 즐겁게 만들어줍니다
- **다국어 지원**: 10개 이상의 언어로 현지화

---

## 🖼️ 사용 예시

<img src="150055A3-BA9F-487C-9A5A-D60D633EDA25.png" width="400" />

---

## 🧑‍💻 사용 방법

1. 앱 실행
2. 아이콘으로 사용할 `.png` 또는 `.icns` 파일 선택
3. 원하는 마스크(모양) 선택 (라운드, 원, 별, 하트 등)
4. 변경하고 싶은 **여러 개의 폴더** 선택
5. **[아이콘 적용]** 버튼 클릭
6. 완료 후 Finder에서 변경된 아이콘 확인

---

## ⚙️ 기술 스택

- Swift 5, SwiftUI
- AppKit (`NSWorkspace`, `NSImage`, `NSOpenPanel`, `FileManager`)
- macOS App Sandbox (App Store 정책 완전 대응)
- 다국어 지원(Localizable.strings)

---

## 🔐 App Store 배포 및 권한 안내

- **샌드박스 완전 대응**:  
  - 사용자가 직접 선택한 폴더/파일에만 접근
  - 시스템 폴더(예: /System, /Applications 등) 접근/변경 불가
- **권한 안내**
  - `NSAppleEventsUsageDescription`: Finder 제어 권한 안내(폴더 아이콘 변경 시 필요)
  - `App Sandbox`: 활성화
  - `User Selected File Access`: 활성화 (read/write)
- **루트 권한, 외부 네트워크, 추가 설치 없음**

---

## ⚠️ 유의 사항

- 자동으로 Finder를 재시작하지 않습니다 (App Store 정책 준수)
- 변경된 아이콘은 macOS 캐시에 따라 잠시 후 반영될 수 있습니다
- 아이콘 적용은 사용자가 직접 선택한 폴더에 한해서만 작동합니다
- 시스템 폴더, 권한 없는 폴더에는 아이콘 변경이 불가합니다

---

## ❓ FAQ

- **Q. 시스템 폴더 아이콘도 바꿀 수 있나요?**  
  A. 아니요. 사용자가 직접 선택한 일반 폴더에만 아이콘을 적용할 수 있습니다. 시스템 폴더는 macOS 정책상 접근/변경이 불가합니다.

- **Q. 아이콘이 바로 안 바뀌어요!**  
  A. Finder 캐시로 인해 반영이 지연될 수 있습니다. Finder를 재실행하거나 잠시 기다려 주세요.

- **Q. 앱이 외부 서버와 통신하나요?**  
  A. 아니요. 모든 기능은 오프라인에서 동작합니다.

---


## 🤝 기여 방법

1. 이 저장소를 fork 후 PR을 보내주세요.
2. 버그/개선 제안은 Issue로 남겨주세요.
3. 번역(Localization) 기여도 환영합니다!

---

**Foldergo — 폴더에도 나만의 감성을.**