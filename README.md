# 📂 Foldergo

**macOS용 폴더 아이콘 일괄 변경 앱**

커스텀한 `.png` 또는 `.icns` 아이콘을 선택한 여러 폴더에 한 번에 적용하세요.  
깔끔한 데스크탑, 나만의 폴더 스타일을 유지하는 가장 간단한 방법입니다.

---

## ✨ 주요 기능

- ✅ **폴더 아이콘 일괄 적용**: 선택한 아이콘을 여러 폴더에 한 번에 적용
- ✅ **직관적인 UI**: 아이콘 파일과 폴더를 선택하는 간단한 인터페이스
- ✅ **macOS 샌드박스 완전 대응**: App Store 등록 기준에 맞춘 구조
- ✅ **Finder 친화적**: 폴더 정리 습관을 시각적으로 즐겁게 만들어줍니다

---

## 🖼️ 사용 예시

<img src="150055A3-BA9F-487C-9A5A-D60D633EDA25.png" width="400" />

---

## 🧑‍💻 사용 방법

1. 앱 실행
2. 아이콘으로 사용할 `.png` 또는 `.icns` 파일 선택
3. 변경하고 싶은 **여러 개의 폴더** 선택
4. **[아이콘 적용] 버튼 클릭**
5. 완료 후 Finder에서 변경된 아이콘 확인

---

## ⚙️ 기술 스택

- Swift 5
- SwiftUI
- AppKit (`NSWorkspace`, `NSImage`, `NSOpenPanel`, `FileManager`)
- macOS App Sandbox (App Store 기준 완전 대응)

---

## 🔐 앱스토어 배포를 위한 권한 설정

- `NSAppleEventsUsageDescription`: 아이콘 변경 시 Finder 접근 안내
- `App Sandbox`: ✅ ON
- `User Selected File Access`: ✅ ON (read/write)

---

## ⚠️ 유의 사항

- 자동으로 Finder를 재시작하지 않습니다 (App Store 정책 준수)
- 변경된 아이콘은 macOS 캐시에 따라 잠시 후 반영될 수 있습니다
- 아이콘 적용은 사용자가 직접 선택한 폴더에 한해서만 작동합니다

---

## 📦 앞으로의 계획 (To-do)

- [ ] 드래그 앤 드롭 인터페이스 지원
- [ ] `.png → .icns` 자동 변환 기능
- [ ] 아이콘 미리보기 지원
- [ ] 복원 기능 (원래 아이콘으로 되돌리기)

---

**Foldergo — 폴더에도 나만의 감성을.**