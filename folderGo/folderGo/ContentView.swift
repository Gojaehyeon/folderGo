//
//  ContentView.swift
//  folderGo
//
//  Created by Gojaehyun on 6/25/25.
//

import SwiftUI
import AppKit

enum Tab: String, CaseIterable, Identifiable, Hashable {
    case customize = "Customize"
    case makeIcon = "Make Icon"
    case reset = "Reset"
    var id: String { self.rawValue }
    var iconName: String {
        switch self {
        case .customize: return "slider.horizontal.3"
        case .makeIcon: return "wand.and.stars"
        case .reset: return "arrow.counterclockwise"
        }
    }
}

struct UserIcon: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let image: NSImage
}

struct ContentView: View {
    @State private var selectedTab: Tab = .customize
    // 상태 변수: 선택된 아이콘, 폴더들
    @State private var selectedIconURL: URL? = nil
    @State private var selectedIconImage: NSImage? = nil // 기본 아이콘용
    @State private var selectedIconName: String? = nil // 어떤 기본 아이콘인지
    @State private var selectedFolderURLs: [URL] = []
    @State private var statusMessage: String? = nil
    // Make Icon 탭 전용 상태
    @State private var makeIconImageURL: URL? = nil
    @State private var makeIconImage: NSImage? = nil
    // 사용자 업로드 아이콘 목록
    @State private var userIcons: [UserIcon] = []
    @State private var selectedUserIcon: UserIcon? = nil
    // Reset 탭: 바꾼 내역이 있는 폴더들 (예시)
    @State private var modifiedFolders: [URL] = []
    @State private var showResetAllAlert = false
    @State private var applySuccessMessage: String? = nil
    @State private var applySuccessTimer: Timer? = nil
    @State private var resetSelectedMessage: String? = nil
    @State private var resetSelectedTimer: Timer? = nil
    
    // 기본 제공 아이콘 목록
    let defaultIcons: [(name: String, labelKey: String)] = [
        ("folder1", "default_icon"),
        ("dark", "dark_icon"),
        ("transparent", "transparent_icon"),
        ("download", "download_icon")
    ]
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.iconName)
                        .tag(tab)
                }
            }
            .listStyle(.sidebar)
        } detail: {
            VStack(alignment: .center, spacing: 24) {
                // 커스텀 헤더
                HStack {
                    Text(selectedTab.rawValue)
                        .font(.title2).bold()
                        .padding(.top, 24)
                    Spacer()
                }
                Divider()
                switch selectedTab {
                case .customize:
                    VStack(alignment: .leading, spacing: 16) {
                        // 기본 아이콘 레이블
                        Text("Liquid Glass Icons")
                            .font(.headline)
                        GroupBox {
                            VStack(spacing: 20) {
                                // Glass 아이콘 선택
                                HStack(spacing: 48) {
                                    ForEach(defaultIcons, id: \ .name) { icon in
                                        Button(action: {
                                            if let img = NSImage(named: icon.name) {
                                                selectedIconImage = img
                                                selectedIconName = icon.name
                                                selectedIconURL = nil // 파일 선택 해제
                                                selectedUserIcon = nil // 사용자 아이콘 선택 해제
                                            }
                                        }) {
                                            VStack(spacing: 2) {
                                                Image(icon.name)
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedIconImage != nil && selectedIconName == icon.name && selectedIconURL == nil && selectedUserIcon == nil ? Color.accentColor : Color.clear, lineWidth: 2))
                                                Text(NSLocalizedString(icon.labelKey, comment: "기본 아이콘 라벨"))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                            }
                            .padding(.bottom, 8)
                        }
                        .groupBoxStyle(.automatic)
                        .frame(maxWidth: 1000)
                        // My Icons 레이블 및 그룹박스
                        if !userIcons.isEmpty {
                            Text("My Icons")
                                .font(.headline)
                            GroupBox {
                                VStack(alignment: .leading, spacing: 12) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 24) {
                                            ForEach(userIcons) { userIcon in
                                                ZStack(alignment: .topTrailing) {
                                                    Button(action: {
                                                        selectedUserIcon = userIcon
                                                        selectedIconImage = userIcon.image
                                                        selectedIconName = nil
                                                        selectedIconURL = userIcon.url
                                                    }) {
                                                        Image(nsImage: userIcon.image)
                                                            .resizable()
                                                            .frame(width: 100, height: 100)
                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedUserIcon == userIcon ? Color.accentColor : Color.clear, lineWidth: 2))
                                                    }
                                                    .buttonStyle(.plain)
                                                    if selectedUserIcon == userIcon {
                                                        Button(action: {
                                                            if let idx = userIcons.firstIndex(of: userIcon) {
                                                                userIcons.remove(at: idx)
                                                                if selectedUserIcon == userIcon {
                                                                    selectedUserIcon = nil
                                                                    selectedIconImage = nil
                                                                    selectedIconURL = nil
                                                                }
                                                            }
                                                        }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .foregroundColor(.red)
                                                                .background(Color.white.opacity(0.8))
                                                                .clipShape(Circle())
                                                        }
                                                        .buttonStyle(.plain)
                                                        .offset(x: 8, y: -8)
                                                    }
                                                }
                                                .frame(width: 100, height: 100)
                                                .padding(.vertical, 12)
                                            }
                                        }
                                    }
                                }
                            }
                            .groupBoxStyle(.automatic)
                            .frame(maxWidth: 1000)
                        }
                        // Select Folders 버튼 (중앙, 큼직하게)
                        Button(action: { selectFolders() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text(selectedFolderURLs.isEmpty ? "Select Folders" : "Add Folders")
                                    .font(.title3).bold()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        // 상태 메시지 (선택적으로 유지)
                        if let msg = statusMessage {
                            Text(msg)
                                .foregroundColor(.blue)
                                .font(.footnote)
                                .padding(.top, 8)
                        }
                        Spacer()
                        // Apply 버튼 (우측 하단)
                        HStack {
                            if let msg = applySuccessMessage {
                                Text(msg)
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else if !selectedFolderURLs.isEmpty {
                                HStack(spacing: 8) {
                                    Button(action: { selectedFolderURLs = [] }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    Text("\(selectedFolderURLs.count) folders selected: " + selectedFolderURLs.map { $0.lastPathComponent }.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            Spacer()
                            Button(action: { applyIconToFolders() }) {
                                Text("Apply")
                                    .font(.title3).bold()
                                    .frame(width: 120, height: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled((selectedIconURL == nil && selectedIconImage == nil) || selectedFolderURLs.isEmpty)
                        }
                        .padding(.top, 24)
                    }
                case .makeIcon:
                    VStack(spacing: 24) {
                        if makeIconImage == nil {
                            Button(action: {
                                let panel = NSOpenPanel()
                                panel.allowedFileTypes = ["png", "icns"]
                                panel.allowsMultipleSelection = false
                                panel.canChooseDirectories = false
                                panel.canChooseFiles = true
                                panel.title = NSLocalizedString("select_icon", comment: "아이콘 파일 선택")
                                if panel.runModal() == .OK, let url = panel.url {
                                    makeIconImageURL = url
                                    makeIconImage = NSImage(contentsOf: url)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text(NSLocalizedString("select_icon", comment: "아이콘 파일 선택"))
                                        .font(.title3).bold()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            if let img = makeIconImage, let url = makeIconImageURL {
                                VStack(spacing: 16) {
                                    Image(nsImage: img)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 240, maxHeight: 240)
                                        .cornerRadius(16)
                                        .shadow(radius: 6)
                                    HStack(spacing: 24) {
                                        Button(action: {
                                            // 바로 추가하기: userIcons에 추가, 초기화, Customize 탭 이동
                                            if let img = makeIconImage, let url = makeIconImageURL {
                                                let userIcon = UserIcon(url: url, image: img)
                                                if !userIcons.contains(userIcon) {
                                                    userIcons.append(userIcon)
                                                }
                                            }
                                            makeIconImage = nil
                                            makeIconImageURL = nil
                                            selectedTab = .customize
                                        }) {
                                            Text(NSLocalizedString("add_now", comment: "바로 추가하기"))
                                                .font(.title3).bold()
                                                .frame(width: 140, height: 44)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        Button(action: {
                                            // 편집하기: 추후 구현
                                        }) {
                                            Text(NSLocalizedString("edit", comment: "편집하기"))
                                                .font(.title3).bold()
                                                .frame(width: 140, height: 44)
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: 600)
                case .reset:
                    VStack(alignment: .leading, spacing: 16) {
                        // Select Folders 버튼 (중앙, 큼직하게)
                        Button(action: { selectFolders() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text(selectedFolderURLs.isEmpty ? "Select Folders" : "Add Folders")
                                    .font(.title3).bold()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                        // 하단 버튼 영역
                        HStack {
                            if let msg = applySuccessMessage {
                                Text(msg)
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else if !selectedFolderURLs.isEmpty {
                                HStack(spacing: 8) {
                                    Button(action: { selectedFolderURLs = [] }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    Text("\(selectedFolderURLs.count) folders selected: " + selectedFolderURLs.map { $0.lastPathComponent }.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            Spacer()
                            // 전체 리셋
                            Button(action: {
                                if selectedFolderURLs.isEmpty {
                                    // 폴더 선택 패널 먼저 띄우기
                                    selectFoldersForResetAll()
                                } else {
                                    showResetAllAlert = true
                                }
                            }) {
                                Text("Reset All")
                                    .font(.title3).bold()
                                    .frame(width: 120, height: 44)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 24)
                        .alert(isPresented: $showResetAllAlert) {
                            Alert(
                                title: Text("정말 모든 선택 폴더를 리셋하시겠습니까?"),
                                message: Text("이 선택은 돌이킬 수 없습니다."),
                                primaryButton: .destructive(Text("리셋")) {
                                    resetAllSelectedFolders()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        // 상태 메시지
                        if let msg = statusMessage {
                            Text(msg)
                                .foregroundColor(.blue)
                                .font(.footnote)
                                .padding(.top, 8)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 32)
            .navigationTitle("Foldergo")
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    // MARK: - 파일/폴더 선택 래퍼
    private func selectIconFile() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "icns"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = NSLocalizedString("select_icon", comment: "아이콘 파일 선택")
        if panel.runModal() == .OK, let url = panel.url {
            selectedIconURL = url
            selectedIconImage = nil // 기본 아이콘 선택 해제
            selectedIconName = nil
        }
    }
    
    private func selectFolders() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.title = NSLocalizedString("select_folders", comment: "폴더 선택")
        if panel.runModal() == .OK {
            // 기존 폴더 + 새로 선택한 폴더를 합쳐 중복 없이 유지
            let newFolders = panel.urls
            let allFolders = selectedFolderURLs + newFolders
            // 중복 제거 (URL의 path 기준)
            selectedFolderURLs = Array(Set(allFolders.map { $0.path })).map { URL(fileURLWithPath: $0) }
            // 순서 보존 (기존 + 새로 추가된 순서)
            selectedFolderURLs = allFolders.reduce(into: [URL]()) { acc, url in
                if !acc.contains(where: { $0.path == url.path }) {
                    acc.append(url)
                }
            }
        }
    }
    
    // MARK: - 아이콘 적용 로직
    private func applyIconToFolders() {
        let iconImage: NSImage?
        if let url = selectedIconURL {
            iconImage = NSImage(contentsOf: url)
        } else {
            iconImage = selectedIconImage
        }
        guard let icon = iconImage else {
            showTimedMessage(NSLocalizedString("apply_fail", comment: "아이콘 적용 실패"))
            return
        }
        var successCount = 0
        var failCount = 0
        for folderURL in selectedFolderURLs {
            let result = NSWorkspace.shared.setIcon(icon, forFile: folderURL.path, options: [])
            if result {
                NSWorkspace.shared.noteFileSystemChanged(folderURL.path)
                successCount += 1
            } else {
                failCount += 1
            }
        }
        if successCount > 0 && failCount == 0 {
            showApplySuccessMessage(String(format: NSLocalizedString("apply_success", comment: "적용 성공"), successCount))
        } else if successCount > 0 {
            showApplySuccessMessage(String(format: NSLocalizedString("apply_partial", comment: "일부 성공"), successCount, failCount))
        } else {
            showTimedMessage(NSLocalizedString("apply_fail", comment: "아이콘 적용 실패"))
        }
    }
    
    private func showApplySuccessMessage(_ msg: String) {
        applySuccessMessage = msg
        applySuccessTimer?.invalidate()
        applySuccessTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            applySuccessMessage = nil
            selectedFolderURLs = []
        }
    }
    
    // MARK: - 전체 초기화(폴더 아이콘 원복)
    private func resetFoldersToDefaultIcon() {
        var successCount = 0
        var failCount = 0
        for folderURL in selectedFolderURLs {
            let result = NSWorkspace.shared.setIcon(nil, forFile: folderURL.path, options: [])
            if result {
                NSWorkspace.shared.noteFileSystemChanged(folderURL.path)
                successCount += 1
            } else {
                failCount += 1
            }
        }
        if successCount > 0 && failCount == 0 {
            showTimedMessage(String(format: NSLocalizedString("reset_success", comment: "복원 성공"), successCount))
        } else if successCount > 0 {
            showTimedMessage(String(format: NSLocalizedString("reset_partial", comment: "일부 복원 성공"), successCount, failCount))
        } else {
            showTimedMessage(NSLocalizedString("reset_fail", comment: "복원 실패"))
        }
    }
    
    // Reset All: 선택된 모든 폴더 초기화
    private func resetAllSelectedFolders() {
        var successCount = 0
        var failCount = 0
        for folderURL in selectedFolderURLs {
            let result = NSWorkspace.shared.setIcon(nil, forFile: folderURL.path, options: [])
            if result {
                NSWorkspace.shared.noteFileSystemChanged(folderURL.path)
                successCount += 1
            } else {
                failCount += 1
            }
        }
        if successCount > 0 && failCount == 0 {
            showApplySuccessMessage(String(format: NSLocalizedString("reset_success", comment: "복원 성공"), successCount))
        } else if successCount > 0 {
            showApplySuccessMessage(String(format: NSLocalizedString("reset_partial", comment: "일부 복원 성공"), successCount, failCount))
        } else {
            showTimedMessage(NSLocalizedString("reset_fail", comment: "복원 실패"))
        }
    }
    
    // Reset All: 폴더 선택 패널
    private func selectFoldersForResetAll() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.title = NSLocalizedString("select_folders", comment: "폴더 선택")
        if panel.runModal() == .OK {
            selectedFolderURLs = panel.urls
            if !selectedFolderURLs.isEmpty {
                showResetAllAlert = true
            }
        }
    }
    
    private func showTimedMessage(_ msg: String) {
        statusMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            statusMessage = nil
        }
    }
}

#Preview {
    ContentView()
}
