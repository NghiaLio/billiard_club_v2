import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/product/product_cubit.dart';
import '../cubits/product/product_state.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý hàng hóa',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm hàng hóa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // Filter tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tất cả',
                      icon: Icons.category,
                      isSelected: _filterCategory == 'all',
                      onTap: () => setState(() => _filterCategory = 'all'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Đồ ăn',
                      icon: Icons.restaurant,
                      isSelected: _filterCategory == 'food',
                      onTap: () => setState(() => _filterCategory = 'food'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Đồ uống',
                      icon: Icons.local_drink,
                      isSelected: _filterCategory == 'drink',
                      onTap: () => setState(() => _filterCategory = 'drink'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Thiết bị',
                      icon: Icons.sports_baseball,
                      isSelected: _filterCategory == 'equipment',
                      onTap: () => setState(() => _filterCategory = 'equipment'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Khác',
                      icon: Icons.more_horiz,
                      isSelected: _filterCategory == 'other',
                      onTap: () => setState(() => _filterCategory = 'other'),
                    ),
                  ],
                ),
              ),
            ),
            // Products list
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is! ProductLoaded) return const SizedBox();
                    var products = state.products;

                  if (_filterCategory != 'all') {
                    products = products
                        .where((p) => p.category == _filterCategory)
                        .toList();
                  }

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Text(
                            'Không có hàng hóa nào',
                            style: AppTextStyles.roboto(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        onEdit: () => _showEditProductDialog(context, product),
                        onDelete: () => _confirmDelete(context, product),
                        onUpdateStock: () =>
                            _showUpdateStockDialog(context, product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '0');
    final unitController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = 'drink';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm hàng hóa mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hàng hóa *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Đồ ăn')),
                  DropdownMenuItem(value: 'drink', child: Text('Đồ uống')),
                  DropdownMenuItem(value: 'equipment', child: Text('Thiết bị')),
                  DropdownMenuItem(value: 'other', child: Text('Khác')),
                ],
                onChanged: (value) => category = value!,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng tồn kho *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Đơn vị (lon, chai, gói, ...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  stockController.text.isNotEmpty) {
                final product = Product(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  category: category,
                  price: double.parse(priceController.text),
                  stockQuantity: int.parse(stockController.text),
                  unit: unitController.text.isEmpty ? null : unitController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  createdAt: DateTime.now(),
                );

                await context.read<ProductCubit>()
                    .addProduct(product);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thêm hàng hóa thành công'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());
    final stockController =
        TextEditingController(text: product.stockQuantity.toString());
    final unitController = TextEditingController(text: product.unit ?? '');
    final descriptionController =
        TextEditingController(text: product.description ?? '');
    String category = product.category;
    bool isAvailable = product.isAvailable;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh sửa hàng hóa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên hàng hóa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'food', child: Text('Đồ ăn')),
                    DropdownMenuItem(value: 'drink', child: Text('Đồ uống')),
                    DropdownMenuItem(value: 'equipment', child: Text('Thiết bị')),
                    DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    setState(() => category = value!);
                  },
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Giá (VNĐ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng tồn kho',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Đơn vị',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                SwitchListTile(
                  title: const Text('Có sẵn'),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() => isAvailable = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedProduct = product.copyWith(
                  name: nameController.text,
                  category: category,
                  price: double.parse(priceController.text),
                  stockQuantity: int.parse(stockController.text),
                  unit: unitController.text.isEmpty ? null : unitController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  isAvailable: isAvailable,
                );

                await context.read<ProductCubit>()
                    .updateProduct(updatedProduct);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật hàng hóa thành công'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, Product product) {
    final quantityController = TextEditingController();
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Cập nhật tồn kho - ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tồn kho hiện tại',
                      style: AppTextStyles.roboto(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      '${product.stockQuantity} ${product.unit ?? ''}',
                      style: AppTextStyles.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Nhập thêm'),
                      value: true,
                      groupValue: isAdding,
                      onChanged: (value) {
                        setState(() => isAdding = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Xuất kho'),
                      value: false,
                      groupValue: isAdding,
                      onChanged: (value) {
                        setState(() => isAdding = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (quantityController.text.isNotEmpty) {
                  int quantity = int.parse(quantityController.text);
                  if (!isAdding) quantity = -quantity;

                  await context.read<ProductCubit>()
                      .updateStock(product.id, quantity);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật tồn kho thành công'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa hàng hóa ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProductCubit>()
                  .deleteProduct(product.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa hàng hóa thành công'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdateStock;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stockQuantity < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: isLowStock
            ? BorderSide(color: AppColors.danger.withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                ProductCategories.getCategoryIcon(product.category),
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ProductCategories.getCategoryName(product.category),
                          style: AppTextStyles.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    AppFormatters.formatCurrency(product.price),
                    style: AppTextStyles.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 14,
                        color: isLowStock ? AppColors.danger : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tồn kho: ${product.stockQuantity} ${product.unit ?? ''}',
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          color:
                              isLowStock ? AppColors.danger : AppColors.textSecondary,
                          fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sắp hết',
                            style: AppTextStyles.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (!product.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Không khả dụng',
                            style: AppTextStyles.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.success),
                  onPressed: onUpdateStock,
                  tooltip: 'Cập nhật tồn kho',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.info),
                  onPressed: onEdit,
                  tooltip: 'Chỉnh sửa',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.danger),
                  onPressed: onDelete,
                  tooltip: 'Xóa',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

