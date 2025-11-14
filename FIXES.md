# 🔧 Lỗi đã sửa

## 1. ✅ Google Fonts - Network Connection Error

**Lỗi:**
```
Exception: Failed to load font with url https://fonts.gstatic.com/s/a/...
SocketException: Connection failed (OS Error: Operation not permitted)
```

**Nguyên nhân:**
- Ứng dụng cố tải Google Fonts từ internet
- Không có quyền truy cập mạng trong sandbox

**Giải pháp:**
- Xóa dependency `google_fonts` khỏi `pubspec.yaml`
- Tạo `AppTextStyles` helper trong `utils/constants.dart`
- Thay thế tất cả `GoogleFonts.roboto()` → `AppTextStyles.roboto()`
- Sử dụng font mặc định của Flutter

**Files đã sửa:**
- `pubspec.yaml`
- `lib/main.dart`
- `lib/utils/constants.dart`
- Tất cả 8 files trong `lib/screens/`

---

## 2. ✅ setState() called during build

**Lỗi:**
```
setState() or markNeedsBuild() called during build.
This _InheritedProviderScope<TableProvider?> widget cannot be marked as needing to build
```

**Nguyên nhân:**
- Gọi `Provider.of<...>().loadData()` trực tiếp trong `initState()`
- `loadData()` gọi `notifyListeners()` trong khi widget tree đang build
- Flutter không cho phép update state trong quá trình build

**Giải pháp:**
- Dùng `WidgetsBinding.instance.addPostFrameCallback()`
- Đảm bảo load data sau khi frame đầu tiên được build xong

**Code cũ:**
```dart
@override
void initState() {
  super.initState();
  _loadData();  // ❌ Gọi ngay lập tức
}
```

**Code mới:**
```dart
@override
void initState() {
  super.initState();
  // ✅ Load data sau khi build xong
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}
```

**Files đã sửa:**
- `lib/screens/home_screen.dart`

---

## 🚀 Cách chạy sau khi sửa

```bash
# Clean build
flutter clean
flutter pub get

# Chạy app
flutter run -d macos
```

---

## 💡 Best Practices

### 1. Tránh gọi Provider methods trong initState
```dart
// ❌ Sai
@override
void initState() {
  super.initState();
  Provider.of<MyProvider>(context).loadData();
}

// ✅ Đúng
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<MyProvider>(context, listen: false).loadData();
  });
}
```

### 2. Tránh phụ thuộc external resources
```dart
// ❌ Cần internet
google_fonts: ^6.1.0

// ✅ Offline hoàn toàn
// Dùng font mặc định của Flutter
```

### 3. Listen = false khi không cần rebuild
```dart
// ❌ Widget sẽ rebuild khi provider thay đổi
Provider.of<MyProvider>(context).loadData();

// ✅ Chỉ gọi method, không rebuild
Provider.of<MyProvider>(context, listen: false).loadData();
```

---

## 📊 Trạng thái hiện tại

- ✅ Google Fonts error: **Fixed**
- ✅ setState during build: **Fixed**
- ✅ All linter errors: **Resolved**
- ✅ App can run offline: **Yes**
- ✅ No network dependencies: **Yes**

---

## 🔍 Kiểm tra lỗi

```bash
# Kiểm tra analysis
flutter analyze

# Kiểm tra linter
flutter analyze lib/

# Xem warnings
flutter analyze --watch
```

---

## 📝 Notes

- Các warnings về `withOpacity` và `deprecated_member_use` là **info**, không ảnh hưởng hoạt động
- Có thể bỏ qua hoặc update sau khi Flutter stable hơn
- App hoạt động hoàn toàn offline, không cần internet

