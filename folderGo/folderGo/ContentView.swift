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
    let defaultIcons: [(name: String, label: String)] = [
        ("folder1", "기본"),
        ("dark", "다크"),
        ("transparent", "투명")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button(action: resetFoldersToDefaultIcon) {
                    Label("전체 초기화", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .disabled(selectedFolderURLs.isEmpty)
            }
            Text("📁 Foldergo").font(.largeTitle).bold()
            Text("폴더 아이콘 일괄 변경 앱").font(.title3)
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
                            Text(icon.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // 아이콘 파일 선택
            HStack {
                Button("아이콘 파일 선택 (.png, .icns)") {
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
                Button("폴더 선택 (여러 개)") {
                    selectFolders()
                }
                if !selectedFolderURLs.isEmpty {
                    Text("\(selectedFolderURLs.count)개 선택됨")
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
                Text("아이콘 적용하기")
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
            statusMessage = "아이콘 이미지를 불러올 수 없습니다."
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
            statusMessage = "\(successCount)개 폴더에 아이콘이 성공적으로 적용되었습니다."
        } else if successCount > 0 {
            statusMessage = "일부 폴더(\(successCount)개)는 성공, \(failCount)개는 실패했습니다."
        } else {
            statusMessage = "아이콘 적용에 실패했습니다. 권한 또는 파일 형식을 확인하세요."
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
            statusMessage = "\(successCount)개 폴더가 macOS 기본 아이콘으로 복원되었습니다."
        } else if successCount > 0 {
            statusMessage = "일부 폴더(\(successCount)개)는 복원 성공, \(failCount)개는 실패했습니다."
        } else {
            statusMessage = "기본 아이콘 복원에 실패했습니다."
        }
    }
}

#Preview {
    ContentView()
}
