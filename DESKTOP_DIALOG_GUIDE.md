# Desktop Dialog Migration Guide

## Summary
Đã tạo widget `DesktopDialog` và `DesktopFormLayout` để format các dialog theo chuẩn desktop (Windows/macOS) với chiều rộng hợp lý và layout 2 cột.

## Completed
✅ `lib/widgets/desktop_dialog.dart` - Helper widgets
✅ `lib/screens/employees_screen.dart` - Add và Edit dialogs  
✅ `lib/screens/members_screen.dart` - Add và Edit dialogs
✅ `lib/screens/tables_screen.dart` - Add và Reserve dialogs

## Remaining Work
⚠️ **products_screen.dart** - Cần update 3 dialogs:
- `_showAddProductDialog` (line ~168)
- `_showEditProductDialog` (line ~291)
- `_showUpdateStockDialog` (line ~425)

⚠️ **cashier_screen.dart** - Check nếu có dialog cần update

## How to Use DesktopDialog

### Basic Pattern (Single Column)
```dart
showDialog(
  context: context,
  builder: (context) => DesktopDialog(
    title: 'Dialog Title',
    maxWidth: 500,  // Điều chỉnh theo nhu cầu
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(...),
        SizedBox(height: 16),
        TextField(...),
      ],
    ),
    actions: [
      TextButton(...),
      ElevatedButton(...),
    ],
  ),
);
```

### Two-Column Layout Pattern
```dart
showDialog(
  context: context,
  builder: (context) => DesktopDialog(
    title: 'Dialog Title',
    maxWidth: 700,  // Rộng hơn cho 2 cột
    content: DesktopFormLayout(
      columns: 2,
      spacing: 16,
      children: [
        TextField(...),  // Left column
        TextField(...),  // Right column
        TextField(...),  // Next row left
        DropdownButton(...),  // Next row right
      ],
    ),
    actions: [...],
  ),
);
```

### Full Width Elements in 2-Column Layout
Nếu cần 1 field chiếm full width (như address textarea), wrap trong Column:
```dart
DesktopFormLayout(
  columns: 2,
  children: [
    TextField(...),  // Regular field
    TextField(...),  // Regular field
    // Full width
    Column(
      children: [
        TextField(
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Address'),
        ),
      ],
    ),
  ],
)
```

## Parameters

### DesktopDialog
- `title` (String) - Dialog title
- `content` (Widget) - Main content
- `actions` (List<Widget>?) - Action buttons
- `maxWidth` (double?) - Max width (default 600)
- `maxHeight` (double?) - Max height (default 85% screen height)

### DesktopFormLayout
- `children` (List<Widget>) - Form fields
- `spacing` (double) - Space between fields (default 16)
- `columns` (int) - Number of columns (default 2, auto-collapse to 1 on mobile)

## Migration Checklist
For each dialog to migrate:
1. Replace `AlertDialog` with `DesktopDialog`
2. Remove `SingleChildScrollView` wrapping (DesktopDialog handles scroll)
3. Replace `Column` with `DesktopFormLayout` for multi-field forms
4. Set appropriate `maxWidth` (500 for simple, 700 for complex forms)
5. Add `*` to required field labels
6. Remove `const Text(...)` from title, use String directly
7. Test on macOS/desktop to verify layout

## Example Comparison

### Before (Mobile style)
```dart
AlertDialog(
  title: const Text('Add Item'),
  content: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(...),
        SizedBox(height: 16),
        TextField(...),
      ],
    ),
  ),
  actions: [...],
)
```

### After (Desktop style)
```dart
DesktopDialog(
  title: 'Add Item',
  maxWidth: 700,
  content: DesktopFormLayout(
    columns: 2,
    spacing: 16,
    children: [
      TextField(...),
      TextField(...),
    ],
  ),
  actions: [...],
)
```

## Notes
- Dialogs tự động responsive (collapse to 1 column on screens < 600px)
- Dialog có divider tách title/content/actions rõ ràng
- Padding và spacing đã được tối ưu cho desktop
- Actions luôn align right theo chuẩn macOS/Windows

