# 🔄 Migration từ Provider sang Bloc (Cubit)

## ✅ Đã hoàn thành

### 1. Dependencies
- ✅ Thêm `flutter_bloc: ^8.1.3` và `equatable: ^2.0.5`
- ✅ Xóa `provider: ^6.1.1`

### 2. Cubits & States
- ✅ AuthCubit + AuthState
- ✅ TableCubit + TableState  
- ✅ MemberCubit + MemberState
- ✅ ProductCubit + ProductState
- ✅ OrderCubit + OrderState
- ✅ InvoiceCubit + InvoiceCubit
- ✅ UserCubit + UserState

### 3. Main.dart
- ✅ Chuyển từ `MultiProvider` → `MultiBlocProvider`
- ✅ Chuyển từ `ChangeNotifierProvider` → `BlocProvider`

## 📋 Cần làm

### Cập nhật Screens

Cần update 8 screens để dùng BlocBuilder/BlocConsumer thay vì Consumer:

1. ✅ `login_screen.dart` - Example hoàn chỉnh
2. `home_screen.dart` - Cần update
3. `tables_screen.dart` - Cần update
4. `cashier_screen.dart` - Cần update
5. `members_screen.dart` - Cần update
6. `products_screen.dart` - Cần update
7. `employees_screen.dart` - Cần update
8. `settings_screen.dart` - Cần update

## 🔄 Pattern Migration

### Old (Provider):
```dart
// Import
import 'package:provider/provider.dart';
import '../providers/table_provider.dart';

// Sử dụng
Consumer<TableProvider>(
  builder: (context, tableProvider, child) {
    if (tableProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView.builder(...);
  },
)

// Gọi method
Provider.of<TableProvider>(context, listen: false).loadTables();

// Lắng nghe trong initState
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<TableProvider>(context, listen: false).loadTables();
  });
}
```

### New (Bloc/Cubit):
```dart
// Import
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/table/table_state.dart';

// Sử dụng - Option 1: BlocBuilder (chỉ rebuild)
BlocBuilder<TableCubit, TableState>(
  builder: (context, state) {
    if (state is TableLoading) {
      return CircularProgressIndicator();
    }
    if (state is TableLoaded) {
      return ListView.builder(
        itemCount: state.tables.length,
        ...
      );
    }
    if (state is TableError) {
      return Text('Error: ${state.message}');
    }
    return SizedBox();
  },
)

// Sử dụng - Option 2: BlocConsumer (rebuild + listen to changes)
BlocConsumer<TableCubit, TableState>(
  listener: (context, state) {
    if (state is TableError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    // Same as BlocBuilder
  },
)

// Gọi method
context.read<TableCubit>().loadTables();

// Lắng nghe trong initState
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<TableCubit>().loadTables();
  });
}
```

## 📝 Conversion Checklist

### Cho mỗi Screen:

#### 1. Update imports
```dart
// ❌ Xóa
import 'package:provider/provider.dart';
import '../providers/xxx_provider.dart';

// ✅ Thêm
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/xxx/xxx_cubit.dart';
import '../cubits/xxx/xxx_state.dart';
```

#### 2. Replace Consumer với BlocBuilder
```dart
// ❌ Old
Consumer<TableProvider>(
  builder: (context, provider, child) {
    return Text(provider.tables.length.toString());
  },
)

// ✅ New
BlocBuilder<TableCubit, TableState>(
  builder: (context, state) {
    if (state is TableLoaded) {
      return Text(state.tables.length.toString());
    }
    return SizedBox();
  },
)
```

#### 3. Replace Provider.of với context.read
```dart
// ❌ Old
Provider.of<TableProvider>(context, listen: false).loadTables()

// ✅ New
context.read<TableCubit>().loadTables()
```

#### 4. Handle states properly
```dart
BlocBuilder<TableCubit, TableState>(
  builder: (context, state) {
    if (state is TableInitial) {
      return Text('Initialize...');
    }
    if (state is TableLoading) {
      return CircularProgressIndicator();
    }
    if (state is TableLoaded) {
      // Show data
      return ListView(...);
    }
    if (state is TableError) {
      return Text('Error: ${state.message}');
    }
    return SizedBox();
  },
)
```

## 🎯 Quick Reference

### State Types by Module

**AuthCubit:**
- `AuthInitial`
- `AuthLoading`
- `AuthAuthenticated(user)`
- `AuthUnauthenticated`
- `AuthError(message)`

**TableCubit:**
- `TableInitial`
- `TableLoading`
- `TableLoaded(tables)` - có helpers: `availableTables`, `occupiedTables`, etc.
- `TableError(message)`

**MemberCubit:**
- `MemberInitial`
- `MemberLoading`
- `MemberLoaded(members)` - có helpers: `activeMembers`, `searchMembers()`, etc.
- `MemberError(message)`

**ProductCubit:**
- `ProductInitial`
- `ProductLoading`
- `ProductLoaded(products)` - có helpers: `availableProducts`, `getProductsByCategory()`, etc.
- `ProductError(message)`

**InvoiceCubit:**
- `InvoiceInitial`
- `InvoiceLoading`
- `InvoiceLoaded(invoices)` - có helpers: `getTodayRevenue()`, `getThisMonthRevenue()`, etc.
- `InvoiceError(message)`

**UserCubit:**
- `UserInitial`
- `UserLoading`
- `UserLoaded(users)` - có helpers: `activeUsers`, etc.
- `UserError(message)`

**OrderCubit:**
- `OrderState(currentOrders)` - Đặc biệt, không có loading/error states riêng
- Methods: `addItemToOrder()`, `removeItemFromOrder()`, `updateItemQuantity()`, etc.

## 💡 Tips

1. **BlocBuilder vs BlocConsumer:**
   - Dùng `BlocBuilder` khi chỉ cần rebuild UI
   - Dùng `BlocConsumer` khi cần cả rebuild UI và side-effects (show snackbar, navigate, etc.)

2. **context.read vs context.watch:**
   - `context.read<TableCubit>()` - Không rebuild, chỉ gọi method
   - `context.watch<TableCubit>()` - Auto rebuild khi state thay đổi (ít dùng, prefer BlocBuilder)

3. **Loading states:**
   - Luôn handle `Loading`, `Loaded`, và `Error` states
   - Có thể show loading spinner khi `is TableLoading`

4. **Error handling:**
   - Dùng `BlocConsumer` với `listener` để show error messages
   - Hoặc check `is TableError` trong builder

## 🚀 Testing

Sau khi update mỗi screen, test:
1. Screen hiển thị đúng data
2. Loading state hoạt động
3. Error state hiển thị (nếu có)
4. Các actions (add, update, delete) hoạt động
5. Không có memory leaks

## 📦 File Structure

```
lib/
├── cubits/
│   ├── auth/
│   │   ├── auth_cubit.dart
│   │   └── auth_state.dart
│   ├── table/
│   │   ├── table_cubit.dart
│   │   └── table_state.dart
│   ├── member/
│   │   ├── member_cubit.dart
│   │   └── member_state.dart
│   ├── product/
│   │   ├── product_cubit.dart
│   │   └── product_state.dart
│   ├── order/
│   │   ├── order_cubit.dart
│   │   └── order_state.dart
│   ├── invoice/
│   │   ├── invoice_cubit.dart
│   │   └── invoice_state.dart
│   └── user/
│       ├── user_cubit.dart
│       └── user_state.dart
├── providers/ (CÓ THỂ XÓA sau khi migration xong)
├── screens/ (CẦN UPDATE)
└── main.dart (✅ ĐÃ UPDATE)
```

## ⚠️ Breaking Changes

1. **Provider không còn hoạt động** - Đã thay bằng Bloc
2. **Consumer<T> không tồn tại** - Thay bằng BlocBuilder<T>
3. **ChangeNotifier không dùng nữa** - Cubits dùng Equatable
4. **notifyListeners() không cần** - Dùng emit() trong Cubits

## 🔗 Resources

- [Bloc Documentation](https://bloclibrary.dev)
- [Cubit vs Bloc](https://bloclibrary.dev/#/coreconcepts?id=cubit-vs-bloc)
- [Migration Guide](https://bloclibrary.dev/#/migration)

