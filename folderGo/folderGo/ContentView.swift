//
//  ContentView.swift
//  folderGo
//
//  Created by Gojaehyun on 6/25/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    // 상태 변수: 선택된 아이콘, 폴더들
    @State private var selectedIconURL: URL? = nil
    @State private var selectedIconImage: NSImage? = nil // 기본 아이콘용
    @State private var selectedIconName: String? = nil // 어떤 기본 아이콘인지
    @State private var selectedFolderURLs: [URL] = []
    @State private var statusMessage: String? = nil
    
    // 기본 제공 아이콘 목록
    let defaultIcons: [(name: String, labelKey: String)] = [
        ("folder1", "default_icon"),
        ("dark", "dark_icon"),
        ("transparent", "transparent_icon")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button(action: resetFoldersToDefaultIcon) {
                    Label(NSLocalizedString("reset_all", comment: "전체 초기화"), systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .disabled(selectedFolderURLs.isEmpty)
            }
            Text("Foldergo").font(.largeTitle).bold()
            Text(NSLocalizedString("subtitle", comment: "앱 서브타이틀")).font(.title3)
            Divider()
            
            // 기본 아이콘 선택 (여러 개)
            HStack(spacing: 16) {
                ForEach(defaultIcons, id: \ .name) { icon in
                    Button(action: {
                        if let img = NSImage(named: icon.name) {
                            selectedIconImage = img
                            selectedIconName = icon.name
                            selectedIconURL = nil // 파일 선택 해제
                        }
                    }) {
                        VStack(spacing: 2) {
                            Image(icon.name)
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(selectedIconImage != nil && selectedIconName == icon.name && selectedIconURL == nil ? Color.accentColor : Color.clear, lineWidth: 2))
                            Text(NSLocalizedString(icon.labelKey, comment: "기본 아이콘 라벨"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // 아이콘 파일 선택
            HStack {
                Button(NSLocalizedString("select_icon", comment: "아이콘 파일 선택")) {
                    selectIconFile()
                }
                if let iconURL = selectedIconURL {
                    Text(iconURL.lastPathComponent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 폴더 선택
            HStack {
                Button(NSLocalizedString("select_folders", comment: "폴더 선택")) {
                    selectFolders()
                }
                if !selectedFolderURLs.isEmpty {
                    Text(String(format: NSLocalizedString("folders_selected", comment: "폴더 선택됨"), selectedFolderURLs.count))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 선택된 폴더 리스트
            if !selectedFolderURLs.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(selectedFolderURLs, id: \.self) { url in
                        Text(url.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 8)
            }
            
            // 아이콘 적용 버튼
            Button(action: {
                applyIconToFolders()
            }) {
                Text(NSLocalizedString("apply_icon", comment: "아이콘 적용하기"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled((selectedIconURL == nil && selectedIconImage == nil) || selectedFolderURLs.isEmpty)
            
            // 상태 메시지
            if let msg = statusMessage {
                Text(msg)
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            Spacer()
        }
        .padding(32)
        .frame(minWidth: 400, minHeight: 500)
    }
    
    // MARK: - 파일/폴더 선택 래퍼
    private func selectIconFile() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "icns"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "아이콘 파일 선택"
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
        panel.title = "폴더 선택"
        if panel.runModal() == .OK {
            selectedFolderURLs = panel.urls
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
            statusMessage = NSLocalizedString("apply_fail", comment: "아이콘 적용 실패")
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
            statusMessage = String(format: NSLocalizedString("apply_success", comment: "적용 성공"), successCount)
        } else if successCount > 0 {
            statusMessage = String(format: NSLocalizedString("apply_partial", comment: "일부 성공"), successCount, failCount)
        } else {
            statusMessage = NSLocalizedString("apply_fail", comment: "적용 실패")
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
            statusMessage = String(format: NSLocalizedString("reset_success", comment: "복원 성공"), successCount)
        } else if successCount > 0 {
            statusMessage = String(format: NSLocalizedString("reset_partial", comment: "일부 복원 성공"), successCount, failCount)
        } else {
            statusMessage = NSLocalizedString("reset_fail", comment: "복원 실패")
        }
    }
}

#Preview {
    ContentView()
}
