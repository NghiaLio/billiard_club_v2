import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/table/table_state.dart';
import '../cubits/invoice/invoice_cubit.dart';
import '../cubits/invoice/invoice_state.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'tables_screen.dart';
import 'employees_screen.dart';
import 'members_screen.dart';
import 'products_screen.dart';
import 'cashier_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<TableCubit>().loadTables();
    await context.read<InvoiceCubit>().loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _handleAppExit,
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: MediaQuery.of(context).size.width > 800,
              backgroundColor: AppColors.primary,
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
              selectedLabelTextStyle: AppTextStyles.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelTextStyle: AppTextStyles.roboto(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              leading: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.sports_baseball,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  if (MediaQuery.of(context).size.width > 800)
                    Text(
                      'BILLIARD CLUB',
                      style: AppTextStyles.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white54),
                ],
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 10),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        if (MediaQuery.of(context).size.width > 800) ...[
                          const SizedBox(height: 8),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final userName = state is AuthAuthenticated
                                  ? state.user.fullName
                                  : '';
                              final userRole = state is AuthAuthenticated
                                  ? (state.user.role == 'manager'
                                        ? 'Quản lý'
                                        : 'Nhân viên')
                                  : '';
                              return Column(
                                children: [
                                  Text(
                                    userName,
                                    style: AppTextStyles.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    userRole,
                                    style: AppTextStyles.roboto(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 10),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          tooltip: 'Đăng xuất',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Tổng quan'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.table_bar),
                  label: Text('Quản lý bàn'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale),
                  label: Text('Thu ngân'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Thành viên'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory),
                  label: Text('Hàng hóa'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Nhân viên'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Cài đặt'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content
            Expanded(child: _getSelectedScreen()),
          ],
        ),
      ),
    );
  }

  Future<bool> _handleAppExit() async {
    final tableCubit = context.read<TableCubit>();
    final tableState = tableCubit.state;
    if (tableState is! TableLoaded) {
      return true;
    }

    final activeTables = tableState.tables
        .where((table) => table.status != 'available')
        .length;
    if (activeTables == 0) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đóng ứng dụng'),
        content: Text(
          'Có $activeTables bàn chưa đưa về trạng thái ban đầu. Thoát ứng dụng '
          'sẽ tự động đưa tất cả bàn về trạng thái trống. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await tableCubit.resetAllTables();
      return true;
    }

    return false;
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TablesScreen();
      case 2:
        return const CashierScreen();
      case 3:
        return const MembersScreen();
      case 4:
        return const ProductsScreen();
      case 5:
        return const EmployeesScreen();
      case 6:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tổng quan',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics cards
              BlocBuilder<InvoiceCubit, InvoiceState>(
                builder: (context, state) {
                  final todayRevenue = state is InvoiceLoaded
                      ? state.getTodayRevenue()
                      : 0.0;
                  final monthRevenue = state is InvoiceLoaded
                      ? state.getThisMonthRevenue()
                      : 0.0;
                  final todayCount = state is InvoiceLoaded
                      ? state.getTodayInvoiceCount()
                      : 0;

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Doanh thu hôm nay',
                          value: AppFormatters.formatCurrency(todayRevenue),
                          subtitle: '$todayCount hóa đơn',
                          icon: Icons.attach_money,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: _StatCard(
                          title: 'Doanh thu tháng',
                          value: AppFormatters.formatCurrency(monthRevenue),
                          subtitle:
                              '${DateTime.now().month}/${DateTime.now().year}',
                          icon: Icons.trending_up,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: _StatCard(
                          title: 'Hóa đơn hôm nay',
                          value: todayCount.toString(),
                          subtitle: 'Tổng số',
                          icon: Icons.receipt,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Table status overview
              Text(
                'Tình trạng bàn',
                style: AppTextStyles.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  final availableCount = state is TableLoaded
                      ? state.availableTables.length
                      : 0;
                  final occupiedCount = state is TableLoaded
                      ? state.occupiedTables.length
                      : 0;
                  final reservedCount = state is TableLoaded
                      ? state.reservedTables.length
                      : 0;
                  final totalCount = state is TableLoaded
                      ? state.tables.length
                      : 0;

                  return Row(
                    children: [
                      Expanded(
                        child: _TableStatusCard(
                          title: 'Bàn trống',
                          count: availableCount,
                          color: AppColors.success,
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: _TableStatusCard(
                          title: 'Đang chơi',
                          count: occupiedCount,
                          color: AppColors.danger,
                          icon: Icons.play_circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: _TableStatusCard(
                          title: 'Đã đặt',
                          count: reservedCount,
                          color: AppColors.warning,
                          icon: Icons.bookmark,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: _TableStatusCard(
                          title: 'Tổng bàn',
                          count: totalCount,
                          color: AppColors.info,
                          icon: Icons.table_bar,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge * 2),
              // Quick actions
              Text(
                'Thao tác nhanh',
                style: AppTextStyles.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Wrap(
                spacing: AppSizes.paddingMedium,
                runSpacing: AppSizes.paddingMedium,
                children: [
                  _QuickActionButton(
                    icon: Icons.add_circle,
                    label: 'Mở bàn mới',
                    color: AppColors.success,
                    onTap: () {
                      // Navigate to tables screen
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.person_add,
                    label: 'Thêm thành viên',
                    color: AppColors.info,
                    onTap: () {
                      // Navigate to members screen
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.inventory_2,
                    label: 'Quản lý kho',
                    color: AppColors.warning,
                    onTap: () {
                      // Navigate to products screen
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.receipt_long,
                    label: 'Xem hóa đơn',
                    color: AppColors.primary,
                    onTap: () {
                      // Navigate to settings/reports
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 40),
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
              title,
              style: AppTextStyles.roboto(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              value,
              style: AppTextStyles.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
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

class _TableStatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _TableStatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              count.toString(),
              style: AppTextStyles.roboto(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              title,
              style: AppTextStyles.roboto(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
