import SwiftUI
import AppKit

struct MakeIconView: View {
    @Binding var makeIconImage: NSImage?
    @Binding var makeIconImageURL: URL?
    @Binding var userIcons: [UserIcon]
    @Binding var showEditModal: Bool
    @Binding var editMaskType: IconMaskType
    var addUserIcon: (NSImage, URL) -> Void
    var showEdit: () -> Void
    var applyMask: (IconMaskType) -> Void
    var resetMakeIcon: () -> Void
    var moveToCustomize: () -> Void

    var body: some View {
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
                                addUserIcon(img, url)
                                resetMakeIcon()
                                moveToCustomize()
                            }) {
                                Text(NSLocalizedString("add_now", comment: "바로 추가하기"))
                                    .font(.title3).bold()
                                    .frame(width: 140, height: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            /*
                            Button(action: {
                                showEdit()
                            }) {
                                Text(NSLocalizedString("edit", comment: "편집하기"))
                                    .font(.title3).bold()
                                    .frame(width: 140, height: 44)
                            }
                            .buttonStyle(.bordered)
                            */
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: 600)
        .sheet(isPresented: $showEditModal) {
            VStack(spacing: 24) {
                Text("아이콘 모양 선택")
                    .font(.headline)
                if let img = makeIconImage {
                    let maskShape: AnyShape = {
                        switch editMaskType {
                        case .roundedSquare: return AnyShape(RoundedRectangle(cornerRadius: 24))
                        case .circle:        return AnyShape(Circle())
                        case .star:          return AnyShape(StarShape())
                        case .heart:         return AnyShape(HeartShape())
                        }
                    }()
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 180, maxHeight: 180)
                        .clipShape(maskShape)
                        .shadow(radius: 4)
                }
                Picker("마스크 모양", selection: $editMaskType) {
                    ForEach(IconMaskType.allCases) { type in
                        Text(type.label).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                HStack(spacing: 24) {
                    Button("취소") { showEditModal = false }
                    Button("적용") {
                        applyMask(editMaskType)
                        resetMakeIcon()
                        showEditModal = false
                        moveToCustomize()
                    }
                }
            }
            .padding(32)
            .frame(width: 340)
        }
    }
}

// AnyShape 타입 정의 (Shape 타입 통일용)
struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path
    init<S: Shape>(_ shape: S) {
        self.pathBuilder = { rect in shape.path(in: rect) }
    }
    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
} 