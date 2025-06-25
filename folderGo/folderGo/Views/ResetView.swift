import SwiftUI

struct ResetView: View {
    // 상태/로직은 추후 ViewModel로 이동 예정
    @Binding var selectedFolderURLs: [URL]
    @Binding var applySuccessMessage: String?
    @Binding var showResetAllAlert: Bool
    var selectFolders: () -> Void
    var resetAllSelectedFolders: () -> Void
    var selectFoldersForResetAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                Button(action: {
                    if selectedFolderURLs.isEmpty {
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
        }
    }
} 