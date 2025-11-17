import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/member/member_cubit.dart';
import '../cubits/member/member_state.dart';
import '../models/member.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/desktop_dialog.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberCubit>().loadMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý thành viên',
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
              onPressed: () => _showAddMemberDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm thành viên'),
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
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc số điện thoại...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            // Members list
            Expanded(
              child: BlocBuilder<MemberCubit, MemberState>(
                builder: (context, state) {
                  if (state is MemberLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is! MemberLoaded) return const SizedBox();
                  var members = state.members;

                  if (_searchController.text.isNotEmpty) {
                    members = state.searchMembers(_searchController.text);
                  }

                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Chưa có thành viên nào'
                                : 'Không tìm thấy thành viên',
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
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _MemberCard(
                        member: member,
                        onEdit: () => _showEditMemberDialog(context, member),
                        onDelete: () => _confirmDelete(context, member),
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

  void _showAddMemberDialog(BuildContext context) {
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    String membershipType = 'standard';

    showDialog(
      context: context,
      builder: (context) => DesktopDialog(
        title: 'Thêm thành viên mới',
        maxWidth: 700,
        content: DesktopFormLayout(
          columns: 2,
          spacing: AppSizes.paddingMedium,
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên *',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại *',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            DropdownButtonFormField<String>(
              value: membershipType,
              decoration: const InputDecoration(
                labelText: 'Loại thành viên',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'standard',
                  child: Text(
                    '${MembershipTypes.getTypeName('standard')} (0%)',
                  ),
                ),
                DropdownMenuItem(
                  value: 'silver',
                  child: Text('${MembershipTypes.getTypeName('silver')} (5%)'),
                ),
                DropdownMenuItem(
                  value: 'gold',
                  child: Text('${MembershipTypes.getTypeName('gold')} (10%)'),
                ),
                DropdownMenuItem(
                  value: 'platinum',
                  child: Text(
                    '${MembershipTypes.getTypeName('platinum')} (15%)',
                  ),
                ),
              ],
              onChanged: (value) => membershipType = value!,
            ),
            // Full width address
            Column(
              children: [
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
              if (fullNameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final member = Member(
                  id: const Uuid().v4(),
                  fullName: fullNameController.text,
                  phone: phoneController.text,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  address: addressController.text.isEmpty
                      ? null
                      : addressController.text,
                  registrationDate: DateTime.now(),
                  membershipType: membershipType,
                  discountRate:
                      MembershipTypes.discountRates[membershipType] ?? 0,
                );

                await context.read<MemberCubit>().addMember(member);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thêm thành viên thành công'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context, Member member) {
    final fullNameController = TextEditingController(text: member.fullName);
    final phoneController = TextEditingController(text: member.phone);
    final emailController = TextEditingController(text: member.email ?? '');
    final addressController = TextEditingController(text: member.address ?? '');
    String membershipType = member.membershipType;
    bool isActive = member.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DesktopDialog(
          title: 'Chỉnh sửa thành viên',
          maxWidth: 700,
          content: DesktopFormLayout(
            columns: 2,
            spacing: AppSizes.paddingMedium,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              DropdownButtonFormField<String>(
                value: membershipType,
                decoration: const InputDecoration(
                  labelText: 'Loại thành viên',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'standard',
                    child: Text(
                      '${MembershipTypes.getTypeName('standard')} (0%)',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'silver',
                    child: Text(
                      '${MembershipTypes.getTypeName('silver')} (5%)',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'gold',
                    child: Text('${MembershipTypes.getTypeName('gold')} (10%)'),
                  ),
                  DropdownMenuItem(
                    value: 'platinum',
                    child: Text(
                      '${MembershipTypes.getTypeName('platinum')} (15%)',
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => membershipType = value!);
                },
              ),
              // Full width address and switch
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  SwitchListTile(
                    title: const Text('Hoạt động'),
                    value: isActive,
                    onChanged: (value) {
                      setState(() => isActive = value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
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
                final updatedMember = member.copyWith(
                  fullName: fullNameController.text,
                  phone: phoneController.text,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  address: addressController.text.isEmpty
                      ? null
                      : addressController.text,
                  membershipType: membershipType,
                  discountRate:
                      MembershipTypes.discountRates[membershipType] ?? 0,
                  isActive: isActive,
                );

                await context.read<MemberCubit>().updateMember(updatedMember);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật thành viên thành công'),
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

  void _confirmDelete(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thành viên ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<MemberCubit>().deleteMember(member.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa thành viên thành công'),
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
}

class _MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getMembershipColor(String type) {
    switch (type) {
      case 'platinum':
        return const Color(0xFF9C27B0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: BorderSide(
          color: _getMembershipColor(member.membershipType).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getMembershipColor(member.membershipType),
                    _getMembershipColor(member.membershipType).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_membership,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.fullName,
                        style: AppTextStyles.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getMembershipColor(member.membershipType),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          MembershipTypes.getTypeName(member.membershipType),
                          style: AppTextStyles.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      if (!member.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Không hoạt động',
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
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        member.phone,
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (member.email != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.email!,
                          style: AppTextStyles.roboto(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.discount,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Giảm giá: ${member.discountRate.toStringAsFixed(0)}%',
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đăng ký: ${AppFormatters.formatDate(member.registrationDate)}',
                        style: AppTextStyles.roboto(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
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
