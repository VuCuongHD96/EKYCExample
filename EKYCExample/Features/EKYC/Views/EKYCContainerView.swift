//
//  EKYCContainerView.swift
//  EKYCExample
//
//  Created by sun on 26/8/26.
//

import SwiftUI

// MARK: - EKYCContainerView (Placeholder)
struct EKYCContainerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Xác thực eKYC")
                    .font(.title2.bold())

                Text("Màn hình xác thực eKYC (Placeholder cho nhánh độc lập)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Đóng") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 12)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    EKYCContainerView()
}
