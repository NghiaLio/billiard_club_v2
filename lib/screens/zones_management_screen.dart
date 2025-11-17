import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../cubits/zone/zone_cubit.dart';
import '../cubits/zone/zone_state.dart';
import '../models/zone.dart';
import '../utils/constants.dart';
import '../widgets/desktop_dialog.dart';

class ZonesManagementScreen extends StatefulWidget {
  const ZonesManagementScreen({super.key});

  @override
  State<ZonesManagementScreen> createState() => _ZonesManagementScreenState();
}

class _ZonesManagementScreenState extends State<ZonesManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ZoneCubit>().loadZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý khu vực',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddZoneDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm khu vực'),
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
        child: BlocBuilder<ZoneCubit, ZoneState>(
          builder: (context, state) {
            if (state is ZoneLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ZoneError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      'Lỗi: ${state.message}',
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is! ZoneLoaded || state.zones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 80,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      'Chưa có khu vực nào',
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
              itemCount: state.zones.length,
              itemBuilder: (context, index) {
                final zone = state.zones[index];
                return _ZoneCard(
                  zone: zone,
                  onEdit: () => _showEditZoneDialog(context, zone),
                  onDelete: () => _confirmDeleteZone(context, zone),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddZoneDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final orderController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => DesktopDialog(
        title: 'Thêm khu vực mới',
        maxWidth: 500,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên khu vực *',
                border: OutlineInputBorder(),
                hintText: 'VD: Zone 5, VIP 3',
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
                hintText: 'Mô tả về khu vực này',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Thứ tự sắp xếp *',
                border: OutlineInputBorder(),
                hintText: '0, 1, 2...',
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên khu vực'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              final zone = Zone(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                description: descController.text.isNotEmpty
                    ? descController.text.trim()
                    : null,
                sortOrder: int.tryParse(orderController.text) ?? 0,
                createdAt: DateTime.now(),
              );

              await context.read<ZoneCubit>().addZone(zone);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thêm khu vực thành công'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditZoneDialog(BuildContext context, Zone zone) {
    final nameController = TextEditingController(text: zone.name);
    final descController = TextEditingController(text: zone.description ?? '');
    final orderController = TextEditingController(text: zone.sortOrder.toString());
    bool isActive = zone.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DesktopDialog(
          title: 'Sửa khu vực',
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên khu vực *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Thứ tự sắp xếp *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              SwitchListTile(
                title: const Text('Kích hoạt'),
                subtitle: const Text('Khu vực này có thể sử dụng'),
                value: isActive,
                onChanged: (value) {
                  setState(() => isActive = value);
                },
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên khu vực'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                  return;
                }

                final updatedZone = zone.copyWith(
                  name: nameController.text.trim(),
                  description: descController.text.isNotEmpty
                      ? descController.text.trim()
                      : null,
                  sortOrder: int.tryParse(orderController.text) ?? 0,
                  isActive: isActive,
                );

                await context.read<ZoneCubit>().updateZone(updatedZone);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật khu vực thành công'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteZone(BuildContext context, Zone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa khu vực "${zone.name}"?\n\n'
          'Lưu ý: Các bàn thuộc khu vực này sẽ không bị xóa nhưng cần cập nhật lại khu vực.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ZoneCubit>().deleteZone(zone.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa khu vực'),
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

class _ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ZoneCard({
    required this.zone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: zone.isActive
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            zone.isActive ? Icons.location_city : Icons.location_off,
            color: zone.isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Row(
          children: [
            Text(
              zone.name,
              style: AppTextStyles.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (!zone.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Vô hiệu hóa',
                  style: AppTextStyles.roboto(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (zone.description != null && zone.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                zone.description!,
                style: AppTextStyles.roboto(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Thứ tự: ${zone.sortOrder}',
              style: AppTextStyles.roboto(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: onEdit,
              tooltip: 'Sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.danger),
              onPressed: onDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }
}

