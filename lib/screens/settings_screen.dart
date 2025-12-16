// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/invoice/invoice_cubit.dart';
import '../cubits/invoice/invoice_state.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/member/member_cubit.dart';
import '../cubits/product/product_cubit.dart';
import '../cubits/user/user_cubit.dart';
import '../cubits/promotion/promotion_cubit.dart';
import '../cubits/zone/zone_cubit.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/desktop_dialog.dart';
import 'zones_management_screen.dart';
import 'promotions_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Báo cáo & Cài đặt',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: Row(
          children: [
            // Sidebar tabs
            Container(
              width: 200,
              color: Colors.white,
              child: ListView(
                children: [
                  _TabItem(
                    icon: Icons.bar_chart,
                    label: 'Doanh thu',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  _TabItem(
                    icon: Icons.receipt_long,
                    label: 'Hóa đơn',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                  _TabItem(
                    icon: Icons.flag,
                    label: 'Khu vực',
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                  _TabItem(
                    icon: Icons.local_offer,
                    label: 'Ưu đãi',
                    isSelected: _selectedTab == 3,
                    onTap: () => setState(() => _selectedTab = 3),
                  ),
                  _TabItem(
                    icon: Icons.info,
                    label: 'Thông tin',
                    isSelected: _selectedTab == 4,
                    onTap: () => setState(() => _selectedTab = 4),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // Content
            Expanded(child: _getTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return const _RevenueTab();
      case 1:
        return const _InvoicesTab();
      case 2:
        return const _ZonesTab();
      case 3:
        return const _PromotionsTab();
      case 4:
        return const _InfoTab();
      default:
        return const _RevenueTab();
    }
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              label,
              style: AppTextStyles.roboto(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueTab extends StatefulWidget {
  const _RevenueTab();

  @override
  State<_RevenueTab> createState() => _RevenueTabState();
}

class _RevenueTabState extends State<_RevenueTab> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        final todayRevenue = state is InvoiceLoaded
            ? state.getTodayRevenue()
            : 0.0;
        final monthRevenue = state is InvoiceLoaded
            ? state.getThisMonthRevenue()
            : 0.0;
        final totalRevenue = state is InvoiceLoaded
            ? state.getTotalRevenue()
            : 0.0;
        final todayCount = state is InvoiceLoaded
            ? state.getTodayInvoiceCount()
            : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Báo cáo doanh thu',
                style: AppTextStyles.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Doanh thu hôm nay',
                      value: AppFormatters.formatCurrency(todayRevenue),
                      subtitle: '$todayCount hóa đơn',
                      icon: Icons.today,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: _StatCard(
                      title: 'Doanh thu tháng này',
                      value: AppFormatters.formatCurrency(monthRevenue),
                      // ignore: prefer_interpolation_to_compose_strings
                      subtitle:
                          DateTime.now().month.toString() +
                          '/' +
                          DateTime.now().year.toString(),
                      icon: Icons.calendar_month,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: _StatCard(
                      title: 'Tổng doanh thu',
                      value: AppFormatters.formatCurrency(totalRevenue),
                      subtitle:
                          '${state is InvoiceLoaded ? state.invoices : [].length} hóa đơn',
                      icon: Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingLarge * 2),
              // Date range filter
              Card(
                elevation: AppSizes.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lọc theo khoảng thời gian',
                        style: AppTextStyles.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Từ ngày'),
                              subtitle: Text(
                                AppFormatters.formatDate(_startDate),
                              ),
                              leading: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _startDate = date);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Đến ngày'),
                              subtitle: Text(
                                AppFormatters.formatDate(_endDate),
                              ),
                              leading: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _endDate = date);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Doanh thu trong khoảng',
                                style: AppTextStyles.roboto(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingSmall),
                              Text(
                                AppFormatters.formatCurrency(
                                  state is InvoiceLoaded
                                      ? state.getRevenueByDateRange(
                                          _startDate,
                                          _endDate.add(const Duration(days: 1)),
                                        )
                                      : 0.0,
                                ),
                                style: AppTextStyles.roboto(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InvoicesTab extends StatelessWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        if (state is InvoiceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final invoices = state is InvoiceLoaded ? state.invoices : [];
        if (invoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  'Chưa có hóa đơn nào',
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
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
              elevation: AppSizes.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  child: const Icon(Icons.receipt, color: AppColors.success),
                ),
                title: Text(
                  '${invoice.tableName} - ${AppFormatters.formatCurrency(invoice.totalAmount)}',
                  style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  AppFormatters.formatDateTime(invoice.createdAt),
                  style: AppTextStyles.roboto(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _InvoiceDetailRow(
                          label: 'Mã hóa đơn',
                          value: invoice.id.substring(0, 8).toUpperCase(),
                        ),
                        if (invoice.memberName != null)
                          _InvoiceDetailRow(
                            label: 'Thành viên',
                            value: invoice.memberName!,
                          ),
                        _InvoiceDetailRow(
                          label: 'Thời gian chơi',
                          value: AppFormatters.formatDuration(
                            invoice.playingHours,
                          ),
                        ),
                        _InvoiceDetailRow(
                          label: 'Tiền bàn',
                          value: AppFormatters.formatCurrency(
                            invoice.tableCharge,
                          ),
                        ),
                        _InvoiceDetailRow(
                          label: 'Đồ ăn & uống',
                          value: AppFormatters.formatCurrency(
                            invoice.orderTotal,
                          ),
                        ),
                        if (invoice.discount > 0)
                          _InvoiceDetailRow(
                            label: 'Giảm giá',
                            value:
                                '-${AppFormatters.formatCurrency(invoice.discount)}',
                            valueColor: AppColors.success,
                          ),
                        const Divider(),
                        _InvoiceDetailRow(
                          label: 'TỔNG',
                          value: AppFormatters.formatCurrency(
                            invoice.totalAmount,
                          ),
                          isBold: true,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        _InvoiceDetailRow(
                          label: 'Thanh toán',
                          value: PaymentMethods.getMethodName(
                            invoice.paymentMethod,
                          ),
                        ),
                        _InvoiceDetailRow(
                          label: 'Thời gian',
                          value:
                              '${AppFormatters.formatDateTime(invoice.startTime)} - ${AppFormatters.formatTime(invoice.endTime)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoTab extends StatefulWidget {
  const _InfoTab();

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  bool _isResetting = false;

  Future<void> _showResetDatabaseDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DesktopDialog(
        title: 'Xác nhận reset database',
        maxWidth: 500,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.danger, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.danger, size: 40),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Text(
                      'CẢNH BÁO',
                      style: AppTextStyles.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            Text(
              'Hành động này sẽ XÓA TOÀN BỘ dữ liệu trong database bao gồm:',
              style: AppTextStyles.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            _DangerItem(text: 'Tất cả bàn billiard và trạng thái'),
            _DangerItem(text: 'Tất cả thành viên'),
            _DangerItem(
              text: 'Tất cả nhân viên (trừ tài khoản admin mặc định)',
            ),
            _DangerItem(text: 'Tất cả hàng hóa và tồn kho'),
            _DangerItem(text: 'Tất cả đơn hàng và hóa đơn'),
            _DangerItem(text: 'Tất cả khu vực và ưu đãi'),
            const SizedBox(height: AppSizes.paddingLarge),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppColors.info, size: 20),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: Text(
                      'Database sẽ được tạo lại với tài khoản admin mặc định:\nUsername: admin | Password: admin123',
                      style: AppTextStyles.roboto(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Bạn có chắc chắn muốn tiếp tục?',
              style: AppTextStyles.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('XÁC NHẬN RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _resetDatabase();
    }
  }

  Future<void> _resetDatabase() async {
    setState(() => _isResetting = true);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSizes.paddingMedium),
                  Text('Đang reset database...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Reset database
      await DatabaseService.instance.resetDatabase();

      // Reload all cubits
      if (mounted) {
        context.read<TableCubit>().loadTables();
        context.read<MemberCubit>().loadMembers();
        context.read<ProductCubit>().loadProducts();
        context.read<InvoiceCubit>().loadInvoices();
        context.read<UserCubit>().loadUsers();
        context.read<PromotionCubit>().loadPromotions();
        context.read<ZoneCubit>().loadZones();
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppSizes.paddingSmall),
                Text('Reset database thành công!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Thông tin ứng dụng',
            style: AppTextStyles.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                children: [
                  const Icon(
                    Icons.sports_baseball,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'QUẢN LÝ BILLIARD CLUB',
                    style: AppTextStyles.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Phiên bản 1.0.0',
                    style: AppTextStyles.roboto(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMedium),
                  _InfoRow(
                    icon: Icons.computer,
                    label: 'Nền tảng',
                    value: 'Windows & macOS',
                  ),
                  _InfoRow(
                    icon: Icons.language,
                    label: 'Ngôn ngữ',
                    value: 'Tiếng Việt',
                  ),
                  _InfoRow(
                    icon: Icons.code,
                    label: 'Framework',
                    value: 'Flutter Desktop',
                  ),
                  _InfoRow(
                    icon: Icons.storage,
                    label: 'Database',
                    value: 'SQLite',
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'Tính năng chính',
                    style: AppTextStyles.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  _FeatureItem(
                    icon: Icons.table_bar,
                    text: 'Quản lý bàn billiard',
                  ),
                  _FeatureItem(icon: Icons.people, text: 'Quản lý thành viên'),
                  _FeatureItem(icon: Icons.person, text: 'Quản lý nhân viên'),
                  _FeatureItem(icon: Icons.inventory, text: 'Quản lý hàng hóa'),
                  _FeatureItem(
                    icon: Icons.point_of_sale,
                    text: 'Thu ngân & thanh toán',
                  ),
                  _FeatureItem(
                    icon: Icons.bar_chart,
                    text: 'Báo cáo doanh thu',
                  ),
                  _FeatureItem(icon: Icons.receipt, text: 'Quản lý hóa đơn'),
                  _FeatureItem(
                    icon: Icons.discount,
                    text: 'Hệ thống thành viên & giảm giá',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          // Database Management Section
          Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.storage,
                          color: AppColors.danger,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Text(
                        'Quản lý Database',
                        style: AppTextStyles.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'Chức năng này cho phép reset toàn bộ database. Tất cả dữ liệu sẽ bị xóa và database sẽ được tạo lại với các bảng trống. Chỉ giữ lại tài khoản admin mặc định (username: admin / password: admin123).',
                    style: AppTextStyles.roboto(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isResetting ? null : _showResetDatabaseDialog,
                      icon: _isResetting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _isResetting ? 'Đang reset...' : 'Reset Database',
                        style: AppTextStyles.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.roboto(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              value,
              style: AppTextStyles.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              subtitle,
              style: AppTextStyles.roboto(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _InvoiceDetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.roboto(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.roboto(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            '$label: ',
            style: AppTextStyles.roboto(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.success),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            text,
            style: AppTextStyles.roboto(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerItem extends StatelessWidget {
  final String text;

  const _DangerItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.close, size: 18, color: AppColors.danger),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.roboto(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonesTab extends StatelessWidget {
  const _ZonesTab();

  @override
  Widget build(BuildContext context) {
    return const ZonesManagementScreen();
  }
}

class _PromotionsTab extends StatelessWidget {
  const _PromotionsTab();

  @override
  Widget build(BuildContext context) {
    return const PromotionsManagementScreen();
  }
}
