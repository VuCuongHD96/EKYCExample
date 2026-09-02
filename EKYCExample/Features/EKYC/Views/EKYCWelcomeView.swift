//
//  EKYCWelcomeView.swift
//  EKYCExample
//

import SwiftUI

public struct EKYCWelcomeView: View {
    @ObservedObject var viewModel: EKYCFlowViewModel

    public init(viewModel: EKYCFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header Banner
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)

                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 16)

                    Text("Xác thực Danh tính (eKYC)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Hoàn tất xác thực chỉ trong 2 phút để bảo mật tài khoản và mở khóa đầy đủ tính năng.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // Document Selection Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("CHỌN LOẠI GIẤY TỜ TUỲ THÂN")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(spacing: 10) {
                        ForEach(DocumentType.allCases) { doc in
                            Button(action: {
                                withAnimation(.spring()) {
                                    viewModel.documentType = doc
                                }
                            }) {
                                HStack(spacing: 14) {
                                    Image(systemName: doc.iconName)
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.documentType == doc ? .blue : .secondary)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(doc.rawValue)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text(doc.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: viewModel.documentType == doc ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.documentType == doc ? .blue : .gray.opacity(0.4))
                                        .font(.system(size: 20))
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(viewModel.documentType == doc ? Color.blue.opacity(0.08) : Color(UIColor.secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(viewModel.documentType == doc ? Color.blue : Color.clear, lineWidth: 1.5)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Preparation Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("LƯU Ý KHI THỰC HIỆN")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(spacing: 10) {
                        TipRow(icon: "sun.max.fill", color: .orange, text: "Chuẩn bị nơi có đủ ánh sáng, tránh chói loá")
                        TipRow(icon: "doc.text.fill", color: .blue, text: "Sử dụng giấy tờ gốc, còn hạn sử dụng, không mờ nhoè")
                        TipRow(icon: "face.smiling", color: .green, text: "Không đeo kính râm, khẩu trang khi xác thực khuôn mặt")
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
                .padding(.horizontal, 20)

                // Action Button
                PrimaryButton(title: "Bắt đầu Xác thực", iconName: "arrow.right") {
                    Task {
                        await viewModel.proceedFromWelcome()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

private struct TipRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    EKYCWelcomeView(viewModel: EKYCFlowViewModel())
}
