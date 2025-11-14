# Hướng dẫn khởi chạy nhanh

## Chạy ứng dụng

### Trên macOS:
```bash
cd /Users/mac/Documents/Working/FLutter/billiard_club
flutter run -d macos
```

### Trên Windows:
```bash
cd /Users/mac/Documents/Working/FLutter/billiard_club
flutter run -d windows
```

## Đăng nhập lần đầu

Sử dụng tài khoản mặc định:
- **Username**: `admin`
- **Password**: `admin123`

## Demo quy trình hoàn chỉnh

### Bước 1: Thêm thành viên mới (tùy chọn)
1. Vào tab "Thành viên"
2. Nhấn "Thêm thành viên"
3. Điền thông tin:
   - Họ tên: Nguyễn Văn A
   - SĐT: 0123456789
   - Loại thẻ: Vàng (giảm 10%)
4. Lưu

### Bước 2: Mở bàn chơi
1. Vào tab "Quản lý bàn"
2. Chọn một bàn trống (màu xanh)
3. Nhấn "Mở bàn"
4. Bàn chuyển sang màu đỏ (đang chơi)
5. Hệ thống bắt đầu tính giờ tự động

### Bước 3: Thêm order đồ uống (tùy chọn)
1. Vào tab "Thu ngân"
2. Chọn bàn đang chơi từ dropdown
3. Chọn sản phẩm (ví dụ: Coca Cola, Sting)
4. Điều chỉnh số lượng nếu cần

### Bước 4: Thanh toán
1. Kiểm tra chi tiết hóa đơn:
   - Tiền bàn (tính theo giờ)
   - Đồ ăn & uống (nếu có)
2. Chọn thành viên (nếu có) để được giảm giá
3. Nhấn "THANH TOÁN"
4. Chọn phương thức: Tiền mặt / Thẻ / Chuyển khoản
5. Xác nhận
6. Bàn tự động đóng và trở về trạng thái trống

### Bước 5: Xem báo cáo doanh thu
1. Vào tab "Báo cáo & Cài đặt"
2. Xem doanh thu hôm nay / tháng này
3. Tab "Hóa đơn" để xem chi tiết các hóa đơn

## Các tính năng khác

### Quản lý hàng hóa
- Thêm sản phẩm mới
- Cập nhật tồn kho (nhập/xuất)
- Cảnh báo sắp hết hàng

### Quản lý nhân viên
- Thêm tài khoản nhân viên mới
- Phân quyền Quản lý / Nhân viên
- Kích hoạt/vô hiệu hóa tài khoản

### Đặt bàn trước
1. Vào "Quản lý bàn"
2. Chọn bàn trống
3. Nhấn "Đặt bàn"
4. Nhập tên khách hoặc SĐT
5. Bàn chuyển sang màu vàng (đã đặt)

## Dữ liệu mẫu có sẵn

Ứng dụng đã có sẵn:
- ✅ 1 tài khoản admin
- ✅ 10 bàn billiard (các loại Pool, Snooker, Carom)
- ✅ 8 sản phẩm mẫu (Coca, Pepsi, Sting, Red Bull, nước suối, mì tôm, snack, thuốc lá)

## Lưu ý

- **Database**: Lưu tại thư mục Documents của hệ thống
- **Backup**: Nên backup file `billiard_club.db` định kỳ
- **Multi-user**: Có thể tạo nhiều tài khoản nhân viên để quản lý
- **Real-time**: Thời gian chơi và chi phí cập nhật real-time

## Khắc phục sự cố

### Lỗi không thể kết nối database
```bash
# Xóa cache và build lại
flutter clean
flutter pub get
flutter run -d macos  # hoặc windows
```

### Muốn reset dữ liệu
1. Tìm file `billiard_club.db` trong thư mục Documents
2. Xóa file
3. Khởi động lại app (sẽ tự tạo database mới với dữ liệu mẫu)

## Build file thực thi

### macOS (.app)
```bash
flutter build macos --release
# File output: build/macos/Build/Products/Release/billiard_club.app
```

### Windows (.exe)
```bash
flutter build windows --release
# File output: build\windows\x64\runner\Release\
```

## Tính năng nâng cao

### Keyboard shortcuts (có thể mở rộng)
- `Ctrl/Cmd + 1`: Tổng quan
- `Ctrl/Cmd + 2`: Quản lý bàn
- `Ctrl/Cmd + 3`: Thu ngân
- `Ctrl/Cmd + Q`: Đăng xuất

### Tips sử dụng hiệu quả
1. **Đăng ký thành viên**: Khuyến khích khách thường xuyên đăng ký để được giảm giá
2. **Quản lý tồn kho**: Check tab Hàng hóa hàng ngày để kịp thời nhập hàng
3. **Báo cáo**: Xem doanh thu cuối ngày để đối chiếu tiền mặt
4. **Backup**: Export báo cáo Excel (tính năng có thể mở rộng)

## Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. Flutter SDK đã cài đặt đúng
2. Dependencies đã được cài (`flutter pub get`)
3. File log tại Console khi chạy app

