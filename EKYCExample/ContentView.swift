//
//  ContentView.swift
//  EKYCExample
//
//  Created by sun on 26/8/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showEKYC: Bool = false
    @State private var isKYCVerified: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // KYC Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: isKYCVerified ? [Color.green.opacity(0.2), Color.teal.opacity(0.2)] : [Color.orange.opacity(0.2), Color.red.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)

                                Image(systemName: isKYCVerified ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(isKYCVerified ? .green : .orange)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(isKYCVerified ? "Đã định danh eKYC" : "Chưa xác thực danh tính")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.primary)

                                Text(isKYCVerified ? "Tài khoản đã đạt mức bảo mật cao nhất" : "Cần hoàn tất eKYC để nâng hạn mức giao dịch")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()
                        }

                        Divider()

                        HStack {
                            Label(isKYCVerified ? "Hạn mức: Không giới hạn" : "Hạn mức hiện tại: 5,000,000 đ", systemImage: "creditcard")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            Spacer()

                            if !isKYCVerified {
                                Button(action: { showEKYC = true }) {
                                    Text("Xác thực ngay")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isKYCVerified ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    // Hero Banner / Feature Showcase
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TÍNH NĂNG NỔI BẬT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "camera.viewfinder",
                                color: .blue,
                                title: "Quét CCCD & OCR Tự động",
                                description: "Apple Vision bóc tách tự động thông tin từ CCCD gắn chip và CMND."
                            )

                            FeatureRow(
                                icon: "faceid",
                                color: .green,
                                title: "Active Liveness Detection",
                                description: "Thử thách nhận diện người thật thông minh (chớp mắt, quay đầu, mỉm cười)."
                            )

                            FeatureRow(
                                icon: "lock.shield.fill",
                                color: .purple,
                                title: "Bảo mật Dữ liệu Cao cấp",
                                description: "Xử lý trên thiết bị với độ an toàn cao, chuẩn hoá dữ liệu theo quy định."
                            )
                        }
                        .padding(.horizontal, 20)
                    }

                    // Start eKYC Button
                    PrimaryButton(
                        title: isKYCVerified ? "Thực hiện lại eKYC" : "Bắt đầu Xác thực eKYC",
                        iconName: "person.badge.shield.checkmark.fill"
                    ) {
                        showEKYC = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .padding(.top, 12)
            }
            .navigationTitle("Ví Điện Tử & eKYC")
            .fullScreenCover(isPresented: $showEKYC) {
                EKYCContainerView()
            }
        }
    }
}

#Preview {
    ContentView()
}
