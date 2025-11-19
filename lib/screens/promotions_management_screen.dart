// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../cubits/promotion/promotion_cubit.dart';
import '../cubits/promotion/promotion_state.dart';
import '../models/promotion.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class PromotionsManagementScreen extends StatefulWidget {
  const PromotionsManagementScreen({super.key});

  @override
  State<PromotionsManagementScreen> createState() =>
      _PromotionsManagementScreenState();
}

class _PromotionsManagementScreenState
    extends State<PromotionsManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PromotionCubit>().loadPromotions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý chương trình ưu đãi',
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
              onPressed: () => _showAddPromotionDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm ưu đãi'),
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
        child: BlocBuilder<PromotionCubit, PromotionState>(
          builder: (context, state) {
            if (state is PromotionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PromotionError) {
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

            if (state is! PromotionLoaded || state.promotions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 80,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      'Chưa có chương trình ưu đãi nào',
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
              itemCount: state.promotions.length,
              itemBuilder: (context, index) {
                final promotion = state.promotions[index];
                return _PromotionCard(
                  promotion: promotion,
                  onEdit: () => _showEditPromotionDialog(context, promotion),
                  onDelete: () => _confirmDeletePromotion(context, promotion),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddPromotionDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _PromotionFormScreen(),
      ),
    );
  }

  void _showEditPromotionDialog(BuildContext context, Promotion promotion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PromotionFormScreen(promotion: promotion),
      ),
    );
  }

  void _confirmDeletePromotion(BuildContext context, Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa chương trình ưu đãi "${promotion.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<PromotionCubit>().deletePromotion(promotion.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa chương trình ưu đãi'),
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

class _PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PromotionCard({
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: promotion.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: promotion.isActive
                        ? AppColors.success
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promotion.name,
                              style: AppTextStyles.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!promotion.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tạm ngưng',
                                style: AppTextStyles.roboto(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promotion.description,
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.discount,
                  label: promotion.type == 'fixed_price'
                      ? 'Giá cố định: ${AppFormatters.formatCurrency(promotion.value)}'
                      : 'Giảm ${promotion.value}%',
                  color: AppColors.warning,
                ),
                if (promotion.startTime != null && promotion.endTime != null)
                  _InfoChip(
                    icon: Icons.access_time,
                    label: '${promotion.startTime} - ${promotion.endTime}',
                    color: AppColors.info,
                  ),
                if (promotion.validFrom != null || promotion.validTo != null)
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDateRange(
                        promotion.validFrom, promotion.validTo),
                    color: AppColors.primary,
                  ),
                if (promotion.minAmount != null)
                  _InfoChip(
                    icon: Icons.attach_money,
                    label:
                        'Tối thiểu ${AppFormatters.formatCurrency(promotion.minAmount!)}',
                    color: AppColors.success,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    if (from != null && to != null) {
      return '${AppFormatters.formatDate(from)} - ${AppFormatters.formatDate(to)}';
    } else if (from != null) {
      return 'Từ ${AppFormatters.formatDate(from)}';
    } else if (to != null) {
      return 'Đến ${AppFormatters.formatDate(to)}';
    }
    return '';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.roboto(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Form screen for add/edit promotion
class _PromotionFormScreen extends StatefulWidget {
  final Promotion? promotion;

  const _PromotionFormScreen({this.promotion});

  @override
  State<_PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends State<_PromotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _valueController;
  late TextEditingController _minAmountController;
  late TextEditingController _minHoursController;

  String _type = 'percentage';
  bool _isActive = true;
  int _priority = 0;
  
  // Time conditions
  String? _dayOfWeek;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  // Date range
  DateTime? _validFrom;
  DateTime? _validTo;

  @override
  void initState() {
    super.initState();
    final promo = widget.promotion;
    _nameController = TextEditingController(text: promo?.name ?? '');
    _descController = TextEditingController(text: promo?.description ?? '');
    _valueController =
        TextEditingController(text: promo?.value.toString() ?? '');
    _minAmountController =
        TextEditingController(text: promo?.minAmount?.toString() ?? '');
    _minHoursController =
        TextEditingController(text: promo?.minPlayingHours?.toString() ?? '');

    if (promo != null) {
      _type = promo.type;
      _isActive = promo.isActive;
      _priority = promo.priority;
      _dayOfWeek = promo.dayOfWeek;
      _validFrom = promo.validFrom;
      _validTo = promo.validTo;
      
      if (promo.startTime != null) {
        final parts = promo.startTime!.split(':');
        _startTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      if (promo.endTime != null) {
        final parts = promo.endTime!.split(':');
        _endTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _valueController.dispose();
    _minAmountController.dispose();
    _minHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? 'Thêm ưu đãi mới' : 'Sửa ưu đãi',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildDiscountSettings(),
            const SizedBox(height: 24),
            _buildTimeConditions(),
            const SizedBox(height: 24),
            _buildMinimumConditions(),
            const SizedBox(height: 24),
            _buildOtherSettings(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePromotion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(widget.promotion == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: AppTextStyles.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên chương trình *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Vui lòng nhập mô tả' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt ưu đãi',
              style: AppTextStyles.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Loại ưu đãi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'percentage',
                  child: Text('Giảm theo phần trăm (%)'),
                ),
                DropdownMenuItem(
                  value: 'fixed_price',
                  child: Text('Giá cố định (VNĐ)'),
                ),
              ],
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: _type == 'percentage' ? 'Giá trị (%) *' : 'Giá (VNĐ) *',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Vui lòng nhập giá trị' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeConditions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điều kiện thời gian',
              style: AppTextStyles.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Từ ngày'),
                    subtitle: Text(_validFrom == null
                        ? 'Chưa chọn'
                        : AppFormatters.formatDate(_validFrom!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _validFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _validFrom = date);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Đến ngày'),
                    subtitle: Text(_validTo == null
                        ? 'Chưa chọn'
                        : AppFormatters.formatDate(_validTo!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _validTo ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _validTo = date);
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Từ giờ'),
                    subtitle: Text(_startTime == null
                        ? 'Chưa chọn'
                        : _startTime!.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _startTime = time);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Đến giờ'),
                    subtitle: Text(
                        _endTime == null ? 'Chưa chọn' : _endTime!.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _endTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimumConditions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điều kiện tối thiểu',
              style: AppTextStyles.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minAmountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền tối thiểu (VNĐ)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minHoursController,
              decoration: const InputDecoration(
                labelText: 'Số giờ chơi tối thiểu',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt khác',
              style: AppTextStyles.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Kích hoạt'),
              subtitle: const Text('Chương trình có thể áp dụng'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            ListTile(
              title: const Text('Độ ưu tiên'),
              subtitle: Text('$_priority (càng cao càng ưu tiên)'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () =>
                        setState(() => _priority = (_priority - 1).clamp(0, 10)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        setState(() => _priority = (_priority + 1).clamp(0, 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePromotion() {
    if (!_formKey.currentState!.validate()) return;

    final promotion = Promotion(
      id: widget.promotion?.id ?? const Uuid().v4(),
      name: _nameController.text,
      description: _descController.text,
      type: _type,
      value: double.parse(_valueController.text),
      applicableTableTypes: null, // Can be extended
      applicableZones: null, // Can be extended
      applicableMembershipType: null, // Can be extended
      dayOfWeek: _dayOfWeek,
      startTime: _startTime != null
          ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      endTime: _endTime != null
          ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      validFrom: _validFrom,
      validTo: _validTo,
      minAmount: _minAmountController.text.isNotEmpty
          ? double.parse(_minAmountController.text)
          : null,
      minPlayingHours: _minHoursController.text.isNotEmpty
          ? double.parse(_minHoursController.text)
          : null,
      isActive: _isActive,
      priority: _priority,
      createdAt: widget.promotion?.createdAt ?? DateTime.now(),
    );

    if (widget.promotion == null) {
      context.read<PromotionCubit>().addPromotion(promotion);
    } else {
      context.read<PromotionCubit>().updatePromotion(promotion);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.promotion == null
            ? 'Đã thêm chương trình ưu đãi'
            : 'Đã cập nhật chương trình ưu đãi'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

