# Project Guidelines & Rules for AI Agents

## 1. iOS Deployment Target Constraint
- **Target OS Version:** `iOS 17.0`
- **STRICT RULE:** **KHÔNG ĐƯỢC TỰ Ý NÂNG VERSION IOS LÊN CAO HƠN iOS 17** (Ví dụ: Không nâng lên iOS 18, và tuyệt đối không để Xcode tự đặt các version beta/unreleased như 26.5).
- Mọi thiết lập trong `project.pbxproj` hoặc build configurations liên quan đến `IPHONEOS_DEPLOYMENT_TARGET` phải giữ ở mức **iOS 17.0** (hoặc 17.x).

## 2. API & Framework Compatibility
- Toàn bộ mã nguồn Swift, SwiftUI Views, ViewModels, Services và Components phải tương thích hoàn toàn với **iOS 17.0**.
- **Không sử dụng** các API, ViewModifier, Macro hoặc Framework chỉ hỗ trợ từ iOS 18 trở lên trừ khi có fallback hoặc kiểm tra phiên bản đầy đủ.
- Duy trì cấu trúc tương thích chuẩn:
  - Sử dụng `@StateObject` / `@ObservedObject` kết hợp với `ObservableObject` hoặc `@Observable` tương thích iOS 17.
  - Sử dụng `NavigationStack`, `fullScreenCover` chuẩn của SwiftUI iOS 17.
