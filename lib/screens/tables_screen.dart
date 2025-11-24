// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:billiard_club/services/excel_service.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/table/table_state.dart';
import '../cubits/zone/zone_cubit.dart';
import '../cubits/zone/zone_state.dart';
import '../models/billiard_table.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/desktop_dialog.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String _filterStatus = 'all';
  String _filterZone = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ZoneCubit>().loadActiveZones();
    context.read<TableCubit>().loadTables();
  }

  @override
  Widget build(BuildContext context) {
    final listTables = context.watch<TableCubit>().tables;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý bàn',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          listTables.isEmpty ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showImportTableDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nhập dữ liệu bàn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ): SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTableDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm bàn'),
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
              child: Row(
                children: [
                  // Status filter
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Tất cả',
                            isSelected: _filterStatus == 'all',
                            onTap: () => setState(() => _filterStatus = 'all'),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          _FilterChip(
                            label: 'Trống',
                            isSelected: _filterStatus == 'available',
                            color: AppColors.success,
                            onTap: () =>
                                setState(() => _filterStatus = 'available'),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          _FilterChip(
                            label: 'Đang chơi',
                            isSelected: _filterStatus == 'occupied',
                            color: AppColors.danger,
                            onTap: () =>
                                setState(() => _filterStatus = 'occupied'),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          _FilterChip(
                            label: 'Đã đặt',
                            isSelected: _filterStatus == 'reserved',
                            color: AppColors.warning,
                            onTap: () =>
                                setState(() => _filterStatus = 'reserved'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  // Zone filter dropdown
                  BlocBuilder<ZoneCubit, ZoneState>(
                    builder: (context, zoneState) {
                      final zones = zoneState is ZoneLoaded
                          ? zoneState.zones
                          : [];
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _filterZone,
                          underline: const SizedBox.shrink(),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          style: AppTextStyles.roboto(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('Tất cả khu vực'),
                            ),
                            ...zones.map((zone) => DropdownMenuItem(
                                  value: zone.name,
                                  child: Text(zone.name),
                                )),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _filterZone = value);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tables grid
            Expanded(
              child: BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  if (state is! TableLoaded) return const SizedBox();
                  var tables = state.tables;

                  // Apply status filter
                  if (_filterStatus != 'all') {
                    tables = tables
                        .where((t) => t.status == _filterStatus)
                        .toList();
                  }

                  // Apply zone filter
                  if (_filterZone != 'all') {
                    tables = tables.where((t) => t.zone == _filterZone).toList();
                  }

                  if (tables.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_restaurant,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Text(
                            'Không có bàn nào',
                            style: AppTextStyles.roboto(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: AppSizes.paddingMedium,
                          mainAxisSpacing: AppSizes.paddingMedium,
                        ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      return _TableCard(
                        table: tables[index],
                        onTap: () => _showTableActions(context, tables[index]),
                        onEdit: tables[index].status == 'available'
                            ? () => _showEditTableDialog(context, tables[index])
                            : null,
                        onDelete: tables[index].status == 'available'
                            ? () => _confirmDeleteTable(context, tables[index])
                            : null,
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

  void _showTableActions(BuildContext context, BilliardTable table) {
    final tableProvider = context.read<TableCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TableActionsSheet(
        table: table,
        tableProvider: tableProvider,
      ),
    );
  }
}

class _TableActionsSheet extends StatefulWidget {
  final BilliardTable table;
  final TableCubit tableProvider;

  const _TableActionsSheet({
    required this.table,
    required this.tableProvider,
  });

  @override
  State<_TableActionsSheet> createState() => _TableActionsSheetState();
}

class _TableActionsSheetState extends State<_TableActionsSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.table.status == 'occupied') {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận kết thúc'),
        content: Text(
          'Bạn có chắc muốn kết thúc phiên chơi của ${widget.table.tableName}?\n\n'
          'Thời gian chơi sẽ không được ghi nhận.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<TableCubit>().closeTable(widget.table.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã kết thúc phiên chơi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.table.tableName,
              style: AppTextStyles.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              '${AppFormatters.formatCurrency(widget.table.pricePerHour)}/giờ',
              style: AppTextStyles.roboto(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            if (widget.table.status == 'available') ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await widget.tableProvider.openTable(widget.table.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mở bàn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.findAncestorStateOfType<_TablesScreenState>()!
                      ._showReserveTableDialog(context, widget.table);
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Đặt bàn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
            ] else if (widget.table.status == 'occupied') ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    Text(
                      'Thời gian chơi',
                      style: AppTextStyles.roboto(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      AppFormatters.formatDuration(widget.table.playingDuration),
                      style: AppTextStyles.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Chi phí hiện tại: ${AppFormatters.formatCurrency(widget.table.currentCost)}',
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEndSessionDialog();
                },
                icon: const Icon(Icons.stop_circle),
                label: const Text('Kết thúc'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
            ] else if (widget.table.status == 'reserved') ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    Text(
                      'Đặt bởi: ${widget.table.reservedBy ?? "N/A"}',
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.table.reservationTime != null) ...[
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Lúc: ${AppFormatters.formatDateTime(widget.table.reservationTime!)}',
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              ElevatedButton.icon(
                onPressed: () async {
                  await widget.tableProvider.openTable(widget.table.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu chơi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              ElevatedButton.icon(
                onPressed: () async {
                  await widget.tableProvider.cancelReservation(widget.table.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Hủy đặt bàn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.paddingMedium),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
  }
}

extension _TablesScreenStateMethods on _TablesScreenState {


  void _showImportTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DesktopDialog(
        title: 'Nhập dữ liệu bàn',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nhập dữ liệu bàn từ file Excel'),
            ElevatedButton.icon(
              onPressed: () async {
                final file = await ExcelService().loadExcelFile();
                if (file != null) {
                  final excel = await ExcelService().readExcelFile(file);
                  for (var sheet in excel.sheets.values) {
                    for (var row in sheet.rows) {
                      final table = BilliardTable(
                        id: const Uuid().v4(),
                        tableName: row[0] as String,
                        tableType: row[1] as String,
                        zone: row[2] as String,
                        pricePerHour: double.parse(row[3] as String),
                      );
                      await context.read<TableCubit>().addTable(table);
                    }
                  }
                }
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('Chọn file Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAddTableDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String tableType = TableTypes.types.first;
    String zone = TableZones.zones.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DesktopDialog(
          title: 'Thêm bàn mới',
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên bàn *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: tableType,
                decoration: const InputDecoration(
                  labelText: 'Thương hiệu *',
                  border: OutlineInputBorder(),
                ),
                items: TableTypes.types
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => tableType = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: zone,
                decoration: const InputDecoration(
                  labelText: 'Khu vực *',
                  border: OutlineInputBorder(),
                ),
                items: TableZones.zones
                    .map((z) => DropdownMenuItem(
                          value: z,
                          child: Text(z),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => zone = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá/giờ (VNĐ) *',
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final table = BilliardTable(
                    id: const Uuid().v4(),
                    tableName: nameController.text,
                    tableType: tableType,
                    zone: zone,
                    pricePerHour: double.parse(priceController.text),
                  );

                  await context.read<TableCubit>().addTable(table);

                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTableDialog(BuildContext context, BilliardTable table) {
    final nameController = TextEditingController(text: table.tableName);
    final priceController = TextEditingController(
      text: table.pricePerHour.toString(),
    );
    String tableType = table.tableType;
    String zone = table.zone;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DesktopDialog(
          title: 'Sửa thông tin bàn',
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên bàn *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: tableType,
                decoration: const InputDecoration(
                  labelText: 'Thương hiệu *',
                  border: OutlineInputBorder(),
                ),
                items: TableTypes.types
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => tableType = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: zone,
                decoration: const InputDecoration(
                  labelText: 'Khu vực *',
                  border: OutlineInputBorder(),
                ),
                items: TableZones.zones
                    .map((z) => DropdownMenuItem(
                          value: z,
                          child: Text(z),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => zone = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá/giờ (VNĐ) *',
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final updatedTable = BilliardTable(
                    id: table.id,
                    tableName: nameController.text,
                    tableType: tableType,
                    zone: zone,
                    pricePerHour: double.parse(priceController.text),
                  );

                  await context.read<TableCubit>().updateTable(updatedTable);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật bàn thành công'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
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

  void _confirmDeleteTable(BuildContext context, BilliardTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa ${table.tableName}?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<TableCubit>().deleteTable(table.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa bàn thành công'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showReserveTableDialog(BuildContext context, BilliardTable table) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => DesktopDialog(
        title: 'Đặt ${table.tableName}',
        maxWidth: 500,
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên khách hàng hoặc SĐT *',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await context.read<TableCubit>().reserveTable(
                  table.id,
                  nameController.text,
                );

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Đặt bàn'),
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatefulWidget {
  final BilliardTable table;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TableCard({
    required this.table,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(_TableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table.status != widget.table.status) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.table.status == 'occupied') {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = TableStatus.getStatusColor(widget.table.status);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header với tên và menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.table.tableName,
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      TableStatus.getStatusText(widget.table.status),
                      style: AppTextStyles.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.onEdit != null || widget.onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) => [
                        if (widget.onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Sửa'),
                              ],
                            ),
                          ),
                        if (widget.onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit' && widget.onEdit != null) {
                          widget.onEdit!();
                        } else if (value == 'delete' && widget.onDelete != null) {
                          widget.onDelete!();
                        }
                      },
                    ),
                ],
              ),
            ),
            // Hình ảnh bàn bida với thông tin overlay
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hình ảnh bàn bida
                    ColorFiltered(
                      colorFilter: widget.table.status == 'available'
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : ColorFilter.mode(
                              Colors.grey.withOpacity(0.5),
                              BlendMode.saturation,
                            ),
                      child: Image.asset(
                        'assets/images/download.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Overlay tối cho bàn đang dùng
                    if (widget.table.status != 'available')
                      Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    // Thông tin ở giữa bàn
                    Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.table.status == 'occupied' &&
                                widget.table.startTime != null) ...[
                              Text(
                                AppFormatters.formatDuration(
                                  widget.table.playingDuration,
                                ),
                                style: AppTextStyles.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppFormatters.formatCurrency(widget.table.currentCost),
                                style: AppTextStyles.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ] else ...[
                              Text(
                                widget.table.tableType.toUpperCase(),
                                style: AppTextStyles.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppFormatters.formatCurrency(widget.table.pricePerHour)} /giờ',
                                style: AppTextStyles.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
