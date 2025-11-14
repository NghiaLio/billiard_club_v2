# 🎱 Billiard Club - Bloc/Cubit Version

## ✅ Đã chuyển đổi hoàn tất

Ứng dụng đã được chuyển từ **Provider** sang **Bloc/Cubit** pattern.

### 🎯 Lợi ích của Bloc/Cubit

1. **Predictable State**: States rõ ràng (Initial, Loading, Loaded, Error)
2. **Testable**: Dễ dàng unit test các Cubits
3. **Separation of Concerns**: Business logic tách biệt khỏi UI
4. **Time Travel Debugging**: Có thể track được mọi state change (với Bloc Inspector)
5. **Immutable States**: States không thể thay đổi sau khi tạo

## 📦 Cấu trúc Project

```
lib/
├── cubits/                 # State Management với Cubit
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
├── models/                 # Data Models
├── services/               # Database Service
├── screens/                # UI Screens
│   └── login_screen.dart  # ✅ Đã update
├── utils/                  # Utilities
└── main.dart              # ✅ Đã update (MultiBlocProvider)
```

## 🚀 Chạy ứng dụng

```bash
cd /Users/mac/Documents/Working/FLutter/billiard_club

# Clean và get dependencies
flutter clean
flutter pub get

# Chạy app
flutter run -d macos
```

## 💡 Sử dụng Cubits trong Screens

### 1. Đọc State (BlocBuilder)

```dart
BlocBuilder<TableCubit, TableState>(
  builder: (context, state) {
    if (state is TableLoading) {
      return CircularProgressIndicator();
    }
    
    if (state is TableLoaded) {
      return ListView.builder(
        itemCount: state.tables.length,
        itemBuilder: (context, index) {
          final table = state.tables[index];
          return ListTile(title: Text(table.tableName));
        },
      );
    }
    
    if (state is TableError) {
      return Text('Error: ${state.message}');
    }
    
    return SizedBox();
  },
)
```

### 2. Gọi Methods

```dart
// Trong button onPressed hoặc method
context.read<TableCubit>().loadTables();
context.read<TableCubit>().openTable(tableId);
context.read<TableCubit>().closeTable(tableId);
```

### 3. Lắng nghe Changes + Rebuild (BlocConsumer)

```dart
BlocConsumer<TableCubit, TableState>(
  listener: (context, state) {
    // Side effects: Show snackbar, navigate, etc.
    if (state is TableError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    // UI rebuild
    if (state is TableLoaded) {
      return ListView(...);
    }
    return SizedBox();
  },
)
```

### 4. Init State với Cubit

```dart
@override
void initState() {
  super.initState();
  // Load data sau khi build xong
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<TableCubit>().loadTables();
    context.read<InvoiceCubit>().loadInvoices();
  });
}
```

## 📊 Available Cubits & States

### 1. AuthCubit
```dart
// States
AuthInitial()
AuthLoading()
AuthAuthenticated(user)
AuthUnauthenticated()
AuthError(message)

// Methods
await authCubit.login(username, password)
authCubit.logout()
```

### 2. TableCubit
```dart
// States
TableInitial()
TableLoading()
TableLoaded(tables)  // Has helpers: availableTables, occupiedTables, etc.
TableError(message)

// Methods
await tableCubit.loadTables()
await tableCubit.openTable(tableId)
await tableCubit.closeTable(tableId)
await tableCubit.reserveTable(tableId, reservedBy)
await tableCubit.cancelReservation(tableId)
await tableCubit.addTable(table)
await tableCubit.updateTable(table)
await tableCubit.deleteTable(id)

// Access helpers from TableLoaded state
final state = context.read<TableCubit>().state;
if (state is TableLoaded) {
  final available = state.availableTables;
  final occupied = state.occupiedTables;
  final table = state.getTableById(id);
}
```

### 3. MemberCubit
```dart
// States
MemberInitial()
MemberLoading()
MemberLoaded(members)  // Has helpers: activeMembers, searchMembers()
MemberError(message)

// Methods
await memberCubit.loadMembers()
await memberCubit.addMember(member)
await memberCubit.updateMember(member)
await memberCubit.deleteMember(id)
```

### 4. ProductCubit
```dart
// States
ProductInitial()
ProductLoading()
ProductLoaded(products)  // Has helpers: availableProducts, etc.
ProductError(message)

// Methods
await productCubit.loadProducts()
await productCubit.addProduct(product)
await productCubit.updateProduct(product)
await productCubit.deleteProduct(id)
await productCubit.updateStock(productId, quantity)
```

### 5. OrderCubit
```dart
// State (single state with data)
OrderState(currentOrders)

// Methods
orderCubit.addItemToOrder(tableId, product, quantity)
orderCubit.removeItemFromOrder(tableId, itemId)
orderCubit.updateItemQuantity(tableId, itemId, newQuantity)
await orderCubit.saveOrder(tableId, sessionId)
orderCubit.clearOrderForTable(tableId)

// Helpers from state
final items = state.getOrderItemsForTable(tableId);
final total = state.getOrderTotalForTable(tableId);
```

### 6. InvoiceCubit
```dart
// States
InvoiceInitial()
InvoiceLoading()
InvoiceLoaded(invoices)  // Has helpers for revenue calculations
InvoiceError(message)

// Methods
await invoiceCubit.loadInvoices()
await invoiceCubit.createInvoice(invoice)

// Access helpers from InvoiceLoaded state
if (state is InvoiceLoaded) {
  final todayRevenue = state.getTodayRevenue();
  final monthRevenue = state.getThisMonthRevenue();
  final totalRevenue = state.getTotalRevenue();
  final todayCount = state.getTodayInvoiceCount();
}
```

### 7. UserCubit
```dart
// States
UserInitial()
UserLoading()
UserLoaded(users)  // Has helpers: activeUsers
UserError(message)

// Methods
await userCubit.loadUsers()
await userCubit.addUser(user)
await userCubit.updateUser(user)
await userCubit.deleteUser(id)
```

## 🔍 Debug Bloc

### 1. Bloc Observer (Optional)

Để track tất cả state changes, tạo file `lib/bloc_observer.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
}
```

Trong `main.dart`:
```dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
```

### 2. Flutter DevTools

- Mở DevTools khi chạy app
- Tab "Inspector" để xem widget tree
- Tab "Network" để xem database queries
- Console để xem state changes (nếu dùng BlocObserver)

## 📝 Migration Status

### ✅ Completed
- [x] Add flutter_bloc & equatable dependencies
- [x] Create all Cubits (7 total)
- [x] Create all States
- [x] Update main.dart with MultiBlocProvider
- [x] Update LoginScreen (example)
- [x] Create migration guide

### 🔄 In Progress / To Do
- [ ] Update HomeScreen
- [ ] Update TablesScreen
- [ ] Update CashierScreen
- [ ] Update MembersScreen
- [ ] Update ProductsScreen
- [ ] Update EmployeesScreen
- [ ] Update SettingsScreen

**Note**: LoginScreen đã được update hoàn toàn và có thể dùng làm reference cho các screens khác.

## 🎯 Next Steps

1. **Update remaining screens**: Theo pattern trong `BLOC_MIGRATION.md`
2. **Test thoroughly**: Mỗi screen sau khi update
3. **Remove old providers**: Sau khi tất cả screens đã migrate
4. **Add BlocObserver**: Để debug dễ hơn (optional)
5. **Write tests**: Unit tests cho Cubits

## ⚠️ Important Notes

- **Provider code không còn hoạt động** - Đã thay thế hoàn toàn bằng Bloc
- **LoginScreen đã update** - Có thể chạy ngay
- **Screens khác cần update** - Follow BLOC_MIGRATION.md guide
- **Database không thay đổi** - Vẫn dùng SQLite như cũ
- **Models không thay đổi** - Chỉ thay đổi state management layer

## 📚 Resources

- [Bloc Documentation](https://bloclibrary.dev)
- [Flutter Bloc Package](https://pub.dev/packages/flutter_bloc)
- [Bloc Examples](https://github.com/felangel/bloc/tree/master/examples)
- [BLOC_MIGRATION.md](./BLOC_MIGRATION.md) - Chi tiết migration guide

## 🆘 Troubleshooting

### Lỗi: Cannot find Provider
**Solution**: Thay `Provider.of<>` bằng `context.read<>` hoặc `BlocBuilder`

### Lỗi: Consumer not found
**Solution**: Thay `Consumer<>` bằng `BlocBuilder<>` hoặc `BlocConsumer<>`

### State không update
**Solution**: Đảm bảo dùng `BlocBuilder` và check đúng state type (`is TableLoaded`)

### Memory leak
**Solution**: Không cần dispose Cubit, BlocProvider tự động handle

## 🎉 Benefits Achieved

✅ **Better Architecture**: Clear separation of concerns  
✅ **Easier Testing**: Cubits are pure Dart classes  
✅ **Predictable States**: Always know what state you're in  
✅ **Debugging**: Can track every state change  
✅ **Scalability**: Easy to add new features  

