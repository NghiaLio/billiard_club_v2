# 🚀 Quick Start - Bloc Version

## ⚡ Chạy nhanh

```bash
cd /Users/mac/Documents/Working/FLutter/billiard_club
flutter clean
flutter pub get
flutter run -d macos
```

## 🔐 Đăng nhập

- **Username**: `admin`
- **Password**: `admin123`

## ✅ Đã hoàn thành

### ✨ State Management: Bloc/Cubit
- 7 Cubits
- 15+ States
- LoginScreen hoàn toàn functional

### 📦 Architecture
```
Cubit (Business Logic) 
    ↓ emit
State (Data)
    ↓ BlocBuilder
UI (Screens)
```

## 🎯 Sử dụng Cubits

### Quick Examples

#### 1. Load data
```dart
context.read<TableCubit>().loadTables();
```

#### 2. Display data
```dart
BlocBuilder<TableCubit, TableState>(
  builder: (context, state) {
    if (state is TableLoaded) {
      return Text('${state.tables.length} bàn');
    }
    return CircularProgressIndicator();
  },
)
```

#### 3. Handle actions
```dart
ElevatedButton(
  onPressed: () {
    context.read<TableCubit>().openTable(tableId);
  },
  child: Text('Mở bàn'),
)
```

## 📝 Migration Status

| Screen | Status |
|--------|--------|
| LoginScreen | ✅ Done |
| HomeScreen | ⚠️ Need update |
| TablesScreen | ⚠️ Need update |
| CashierScreen | ⚠️ Need update |
| MembersScreen | ⚠️ Need update |
| ProductsScreen | ⚠️ Need update |
| EmployeesScreen | ⚠️ Need update |
| SettingsScreen | ⚠️ Need update |

## 📚 Docs

- `README_BLOC.md` - Full documentation
- `BLOC_MIGRATION.md` - Migration guide
- `BLOC_SUMMARY.md` - Summary

## 🔥 Available Cubits

1. **AuthCubit** - Login/Logout
2. **TableCubit** - Manage tables
3. **MemberCubit** - Manage members
4. **ProductCubit** - Manage products
5. **OrderCubit** - Manage orders
6. **InvoiceCubit** - Manage invoices
7. **UserCubit** - Manage employees

## 💡 Tips

### Load data in initState
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<TableCubit>().loadTables();
  });
}
```

### Show loading
```dart
if (state is TableLoading) {
  return CircularProgressIndicator();
}
```

### Show error
```dart
if (state is TableError) {
  return Text('Error: ${state.message}');
}
```

### Access helpers
```dart
if (state is TableLoaded) {
  final available = state.availableTables;
  final occupied = state.occupiedTables;
}
```

## 🎓 Learn More

1. Open `LoginScreen` - See working example
2. Read `BLOC_MIGRATION.md` - Learn patterns
3. Check `README_BLOC.md` - Full API reference

## ⚠️ Important

- **LoginScreen works** - Test it first!
- **Other screens** - Still use Provider (need update)
- **All Cubits ready** - Just need to use them
- **No breaking changes** - Database & Models unchanged

## 🎉 Benefits

✅ Predictable states  
✅ Easy to test  
✅ Better architecture  
✅ Cleaner code  
✅ Debugging friendly  

---

**Ready to go! Chạy app ngay! 🚀**

