# Ứng dụng Quản lý Câu lạc bộ Billiard

Ứng dụng desktop (Windows & macOS) được xây dựng bằng Flutter để quản lý toàn diện một câu lạc bộ billiard.

## Tính năng chính

### 1. Quản lý Bàn
- Xem trạng thái tất cả bàn (trống, đang chơi, đã đặt, bảo trì)
- Mở bàn và tính thời gian chơi tự động
- Đặt bàn trước
- Hủy đặt bàn
- Theo dõi thời gian và chi phí real-time
- Phân loại bàn theo loại (Pool, Snooker, Carom)

### 2. Thu Ngân (POS)
- Chọn bàn đang chơi để thanh toán
- Thêm order đồ ăn & uống vào bàn
- Tính toán tự động: tiền bàn + order
- Áp dụng giảm giá cho thành viên
- Nhiều phương thức thanh toán (tiền mặt, thẻ, chuyển khoản)
- Tạo hóa đơn tự động
- In hóa đơn (có thể mở rộng)

### 3. Quản lý Thành viên
- Đăng ký thành viên mới
- Các loại thẻ thành viên: Tiêu chuẩn, Bạc, Vàng, Bạch kim
- Mức giảm giá theo loại thẻ (0%, 5%, 10%, 15%)
- Tìm kiếm thành viên theo tên/số điện thoại
- Cập nhật thông tin thành viên
- Kích hoạt/vô hiệu hóa thành viên

### 4. Quản lý Hàng hóa
- Thêm/sửa/xóa sản phẩm
- Phân loại: Đồ ăn, Đồ uống, Thiết bị, Khác
- Quản lý tồn kho
- Nhập/xuất kho
- Cảnh báo tồn kho thấp
- Cập nhật giá sản phẩm

### 5. Quản lý Nhân viên
- Thêm nhân viên mới
- Phân quyền: Quản lý / Nhân viên
- Quản lý tài khoản đăng nhập
- Kích hoạt/vô hiệu hóa tài khoản
- Lưu thông tin liên hệ

### 6. Báo cáo & Thống kê
- Doanh thu theo ngày/tháng
- Xem danh sách hóa đơn chi tiết
- Lọc hóa đơn theo khoảng thời gian
- Thống kê số lượng hóa đơn
- Dashboard tổng quan

## Công nghệ sử dụng

- **Framework**: Flutter (Desktop)
- **Database**: SQLite (sqflite_common_ffi)
- **State Management**: Provider
- **UI**: Material Design 3, Google Fonts
- **Platform**: Windows & macOS

## Cài đặt

### Yêu cầu
- Flutter SDK 3.9.2 hoặc cao hơn
- Dart SDK
- Windows 10/11 hoặc macOS 10.14+

### Cài đặt dependencies
```bash
flutter pub get
```

### Chạy ứng dụng

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

### Build ứng dụng

#### Windows
```bash
flutter build windows
```

#### macOS
```bash
flutter build macos
```

## Cấu trúc dự án

```
lib/
├── models/              # Data models
│   ├── user.dart
│   ├── member.dart
│   ├── billiard_table.dart
│   ├── product.dart
│   ├── order.dart
│   └── invoice.dart
├── services/            # Business logic & Database
│   └── database_service.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── table_provider.dart
│   ├── member_provider.dart
│   ├── product_provider.dart
│   ├── order_provider.dart
│   ├── invoice_provider.dart
│   └── user_provider.dart
├── screens/            # UI Screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── tables_screen.dart
│   ├── cashier_screen.dart
│   ├── members_screen.dart
│   ├── products_screen.dart
│   ├── employees_screen.dart
│   └── settings_screen.dart
├── utils/              # Utilities
│   ├── constants.dart
│   └── formatters.dart
└── main.dart           # Entry point
```

## Hướng dẫn sử dụng

### Đăng nhập
- **Tài khoản mặc định**:
  - Username: `admin`
  - Password: `admin123`

### Quy trình nghiệp vụ cơ bản

#### 1. Mở bàn
1. Vào màn hình "Quản lý bàn"
2. Chọn bàn trống
3. Nhấn "Mở bàn"
4. Hệ thống bắt đầu tính giờ tự động

#### 2. Thêm order
1. Vào màn hình "Thu ngân"
2. Chọn bàn đang chơi
3. Chọn sản phẩm cần order
4. Điều chỉnh số lượng nếu cần

#### 3. Thanh toán
1. Kiểm tra hóa đơn
2. Chọn thành viên (nếu có) để được giảm giá
3. Nhấn "THANH TOÁN"
4. Chọn phương thức thanh toán
5. Xác nhận

#### 4. Quản lý thành viên
1. Vào màn hình "Thành viên"
2. Nhấn "Thêm thành viên"
3. Điền thông tin
4. Chọn loại thẻ thành viên
5. Lưu

## Database Schema

### Tables
- `users` - Nhân viên & quản lý
- `members` - Thành viên
- `billiard_tables` - Bàn billiard
- `products` - Hàng hóa
- `orders` - Đơn hàng
- `order_items` - Chi tiết đơn hàng
- `invoices` - Hóa đơn

## Logic nghiệp vụ

### Vai trò Quản lý
- Quản lý toàn diện tất cả tài khoản
- Quản lý hàng hóa trong kho
- Quản lý doanh thu
- Thực hiện mọi nghiệp vụ vận hành (mở/đóng bàn, order, hóa đơn)
- Xử lý yêu cầu khách hàng (đăng ký thành viên, đặt/hủy đặt bàn)
- Xử lý thanh toán (online hoặc trực tiếp)

### Tính năng nổi bật
- **Tự động tính tiền**: Tính toán thời gian chơi và chi phí real-time
- **Hệ thống thành viên**: Giảm giá tự động theo loại thẻ
- **Quản lý tồn kho**: Cảnh báo khi sắp hết hàng
- **Báo cáo doanh thu**: Thống kê theo ngày/tháng/khoảng thời gian
- **Giao diện thân thiện**: Modern UI với Material Design 3

## Mở rộng trong tương lai

- [ ] In hóa đơn
- [ ] Backup/Restore database
- [ ] Export báo cáo Excel
- [ ] Biểu đồ doanh thu
- [ ] Lịch sử giao dịch chi tiết
- [ ] Quản lý ca làm việc
- [ ] Tích hợp camera giám sát
- [ ] Mobile app đồng bộ

## License

MIT License - Tự do sử dụng và chỉnh sửa

## Liên hệ & Hỗ trợ

Nếu có bất kỳ câu hỏi hoặc vấn đề nào, vui lòng tạo issue trên GitHub repository.
