//
//  ContentView.swift
//  folderGo
//
//  Created by Gojaehyun on 6/25/25.
//

import SwiftUI
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

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

struct ContentView: View {
    @State private var selectedTab: Tab = .customize
    // 상태 변수: 선택된 아이콘, 폴더들
    @State private var selectedIconURL: URL? = nil
    @State private var selectedIconImage: NSImage? = nil
    @State private var selectedIconName: String? = nil
    @State private var selectedFolderURLs: [URL] = []
    @State private var statusMessage: String? = nil
    // Make Icon 탭 전용 상태
    @State private var makeIconImageURL: URL? = nil
    @State private var makeIconImage: NSImage? = nil
    @State private var showResetAllAlert = false
    @State private var applySuccessMessage: String? = nil
    @State private var applySuccessTimer: Timer? = nil
    @State private var showEditModal = false
    @State private var editMaskType: IconMaskType = .roundedSquare
    @State private var userIcons: [UserIcon] = []
    @State private var selectedUserIcon: UserIcon? = nil

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
                HStack {
                    Text(selectedTab.rawValue)
                        .font(.title2).bold()
                        .padding(.top, 24)
                    Spacer()
                }
                Divider()
                switch selectedTab {
                case .customize:
                    CustomizeView(
                        selectedIconImage: $selectedIconImage,
                        selectedIconName: $selectedIconName,
                        selectedIconURL: $selectedIconURL,
                        selectedUserIcon: $selectedUserIcon,
                        userIcons: $userIcons,
                        selectedFolderURLs: $selectedFolderURLs,
                        applySuccessMessage: $applySuccessMessage,
                        defaultIcons: defaultIcons,
                        selectFolders: selectFolders,
                        applyIconToFolders: applyIconToFolders
                    )
                case .makeIcon:
                    MakeIconView(
                        makeIconImage: $makeIconImage,
                        makeIconImageURL: $makeIconImageURL,
                        userIcons: $userIcons,
                        showEditModal: $showEditModal,
                        editMaskType: $editMaskType,
                        addUserIcon: { img, url in
                            let square = cropToSquare(image: img)
                            let userIcon = UserIcon(url: url, image: square)
                            if !userIcons.contains(userIcon) {
                                userIcons.append(userIcon)
                            }
                        },
                        showEdit: { showEditModal = true },
                        applyMask: { maskType in
                            if let img = makeIconImage, let url = makeIconImageURL {
                                let square = cropToSquare(image: img)
                                if let masked = maskImageWithShape(image: square, maskType: maskType) {
                                    let userIcon = UserIcon(url: url, image: masked)
                                    if !userIcons.contains(userIcon) {
                                        userIcons.append(userIcon)
                                    }
                                }
                            }
                        },
                        resetMakeIcon: {
                            makeIconImage = nil
                            makeIconImageURL = nil
                        },
                        moveToCustomize: { selectedTab = .customize }
                    )
                case .reset:
                    ResetView(
                        selectedFolderURLs: $selectedFolderURLs,
                        applySuccessMessage: $applySuccessMessage,
                        showResetAllAlert: $showResetAllAlert,
                        selectFolders: selectFolders,
                        resetAllSelectedFolders: resetAllSelectedFolders,
                        selectFoldersForResetAll: selectFoldersForResetAll
                    )
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
    private func selectFolders() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.title = NSLocalizedString("select_folders", comment: "폴더 선택")
        if panel.runModal() == .OK {
            let newFolders = panel.urls
            let allFolders = selectedFolderURLs + newFolders
            selectedFolderURLs = Array(Set(allFolders.map { $0.path })).map { URL(fileURLWithPath: $0) }
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
        if let userIcon = selectedUserIcon {
            iconImage = userIcon.image // 마스킹된 이미지 우선 적용
        } else if let url = selectedIconURL {
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

    // 마스킹 함수: NSImage + Shape → NSImage
    private func maskImageWithShape(image: NSImage, maskType: IconMaskType) -> NSImage? {
        let size = image.size
        let rect = CGRect(origin: .zero, size: size)
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
        rep?.size = size
        guard let rep = rep else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        let path: NSBezierPath
        switch maskType {
        case .roundedSquare:
            path = NSBezierPath(roundedRect: rect, xRadius: size.width/6, yRadius: size.height/6)
        case .circle:
            path = NSBezierPath(ovalIn: rect)
        case .star:
            path = NSBezierPath()
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let points = 5
            let r1 = min(size.width, size.height)/2
            let r2 = r1/2.5
            for i in 0..<(points*2) {
                let angle = CGFloat(i) * .pi / CGFloat(points)
                let radius = i % 2 == 0 ? r1 : r2
                let pt = CGPoint(x: center.x + cos(angle - .pi/2)*radius, y: center.y + sin(angle - .pi/2)*radius)
                if i == 0 { path.move(to: pt) } else { path.line(to: pt) }
            }
            path.close()
        case .heart:
            path = NSBezierPath()
            let w = size.width, h = size.height
            path.move(to: CGPoint(x: w/2, y: h))
            path.curve(to: CGPoint(x: 0, y: h/4), controlPoint1: CGPoint(x: w/2, y: h*3/4), controlPoint2: CGPoint(x: 0, y: h/2))
            path.appendArc(withCenter: CGPoint(x: w/4, y: h/4), radius: w/4, startAngle: 180, endAngle: 0, clockwise: false)
            path.appendArc(withCenter: CGPoint(x: w*3/4, y: h/4), radius: w/4, startAngle: 180, endAngle: 0, clockwise: false)
            path.curve(to: CGPoint(x: w/2, y: h), controlPoint1: CGPoint(x: w, y: h/2), controlPoint2: CGPoint(x: w/2, y: h*3/4))
            path.close()
        }
        path.addClip()
        image.draw(in: rect)
        NSGraphicsContext.restoreGraphicsState()
        let masked = NSImage(size: size)
        masked.addRepresentation(rep)
        return masked
    }

    // NSImage를 중앙 기준 정사각형으로 크롭
    private func cropToSquare(image: NSImage) -> NSImage {
        let size = min(image.size.width, image.size.height)
        let x = (image.size.width - size) / 2
        let y = (image.size.height - size) / 2
        let rect = CGRect(x: x, y: y, width: size, height: size)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let cropped = cgImage.cropping(to: rect) else { return image }
        let nsImage = NSImage(cgImage: cropped, size: NSSize(width: size, height: size))
        return nsImage
    }
}

// 별, 하트 Shape 정의
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let starExtrusion: CGFloat = rect.width / 2.5
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var points: [CGPoint] = []
        let pointsOnStar = 5
        for i in 0..<pointsOnStar * 2 {
            let angle = (Double(i) * (360.0 / Double(pointsOnStar * 2))) * Double.pi / 180
            let radius = i % 2 == 0 ? rect.width / 2 : starExtrusion / 2
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            points.append(pt)
        }
        var path = Path()
        path.move(to: points[0])
        for pt in points.dropFirst() { path.addLine(to: pt) }
        path.closeSubpath()
        return path
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width/2, y: height))
        path.addCurve(to: CGPoint(x: 0, y: height/4),
                      control1: CGPoint(x: width/2, y: height*3/4),
                      control2: CGPoint(x: 0, y: height/2))
        path.addArc(center: CGPoint(x: width/4, y: height/4), radius: width/4, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: CGPoint(x: width*3/4, y: height/4), radius: width/4, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addCurve(to: CGPoint(x: width/2, y: height),
                      control1: CGPoint(x: width, y: height/2),
                      control2: CGPoint(x: width/2, y: height*3/4))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ContentView()
}
