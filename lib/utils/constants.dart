import 'package:flutter/material.dart';

// Text styles helper to replace GoogleFonts
class AppTextStyles {
  static TextStyle roboto({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFFFF9800);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
}

class TableStatus {
  static const String available = 'available';
  static const String occupied = 'occupied';
  static const String reserved = 'reserved';
  static const String maintenance = 'maintenance';

  static Color getStatusColor(String status) {
    switch (status) {
      case available:
        return AppColors.success;
      case occupied:
        return AppColors.danger;
      case reserved:
        return AppColors.warning;
      case maintenance:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case available:
        return 'Trống';
      case occupied:
        return 'Đang chơi';
      case reserved:
        return 'Đã đặt';
      case maintenance:
        return 'Bảo trì';
      default:
        return 'Không xác định';
    }
  }
}

class MembershipTypes {
  static const String standard = 'standard';
  static const String silver = 'silver';
  static const String gold = 'gold';
  static const String platinum = 'platinum';

  static Map<String, double> discountRates = {
    standard: 0,
    silver: 5,
    gold: 10,
    platinum: 15,
  };

  static String getTypeName(String type) {
    switch (type) {
      case standard:
        return 'Tiêu chuẩn';
      case silver:
        return 'Bạc';
      case gold:
        return 'Vàng';
      case platinum:
        return 'Bạch kim';
      default:
        return 'Tiêu chuẩn';
    }
  }
}

class ProductCategories {
  static const String food = 'food';
  static const String drink = 'drink';
  static const String equipment = 'equipment';
  static const String other = 'other';

  static String getCategoryName(String category) {
    switch (category) {
      case food:
        return 'Đồ ăn';
      case drink:
        return 'Đồ uống';
      case equipment:
        return 'Thiết bị';
      case other:
        return 'Khác';
      default:
        return 'Khác';
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case food:
        return Icons.restaurant;
      case drink:
        return Icons.local_drink;
      case equipment:
        return Icons.sports_baseball;
      case other:
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}

class PaymentMethods {
  static const String cash = 'cash';
  static const String card = 'card';
  static const String online = 'online';
  static const String memberAccount = 'member_account';

  static String getMethodName(String method) {
    switch (method) {
      case cash:
        return 'Tiền mặt';
      case card:
        return 'Thẻ';
      case online:
        return 'Chuyển khoản';
      case memberAccount:
        return 'Tài khoản thành viên';
      default:
        return 'Tiền mặt';
    }
  }
}

class TableTypes {
  static const List<String> types = [
    'Rasson',
    'MrSung',
    'Aliex Crown',
    'Predator Arc',
    'Dinamon',
    'Chinese Pool',
  ];
}

class TableZones {
  static const List<String> zones = [
    'Zone 1',
    'Zone 2',
    'Zone 3',
    'Zone 4',
    'VIP 1',
    'VIP 2',
    'VVIP',
  ];
}

