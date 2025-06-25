import SwiftUI
import AppKit

struct CustomizeView: View {
    // 상태/로직은 추후 ViewModel로 이동 예정
    @Binding var selectedIconImage: NSImage?
    @Binding var selectedIconName: String?
    @Binding var selectedIconURL: URL?
    @Binding var selectedUserIcon: UserIcon?
    @Binding var userIcons: [UserIcon]
    @Binding var selectedFolderURLs: [URL]
    @Binding var applySuccessMessage: String?
    let defaultIcons: [(name: String, labelKey: String)]
    var selectFolders: () -> Void
    var applyIconToFolders: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Liquid Glass Icons")
                .font(.headline)
            GroupBox {
                VStack(spacing: 20) {
                    HStack(spacing: 48) {
                        ForEach(defaultIcons, id: \ .name) { icon in
                            Button(action: {
                                if let img = NSImage(named: icon.name) {
                                    selectedIconImage = img
                                    selectedIconName = icon.name
                                    selectedIconURL = nil
                                    selectedUserIcon = nil
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
    }
} 