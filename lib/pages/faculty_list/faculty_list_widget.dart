import 'package:cached_network_image/cached_network_image.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/add_user/add_user_widget.dart';
import 'package:d_c_i_teacher_app/pages/edit_profile/edit_profile_widget.dart';
import 'package:d_c_i_teacher_app/pages/teacher_profile/teacher_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/faculty_list/faculty_list_model.dart';
export 'package:d_c_i_teacher_app/pages/faculty_list/faculty_list_model.dart';

class FacultyListWidget extends ConsumerStatefulWidget {
  const FacultyListWidget({super.key});

  static String routeName = 'FacultyList';
  static String routePath = '/facultyList';

  @override
  ConsumerState<FacultyListWidget> createState() => _FacultyListWidgetState();
}

class _FacultyListWidgetState extends ConsumerState<FacultyListWidget> {
  late FacultyListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FacultyListModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersStreamProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            HeaderSectionWidget(
              title: 'Faculty Directory',
              subtitle: 'Manage Institute Staff',
              onBackPressed: () async => context.safePop(),
              showActionIcon: false,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppSearchBar(
                controller: _model.searchController,
                hintText: 'Search by name or email...',
                onChanged: (val) => setState(() => _searchQuery = val),
                onClear: () => setState(() {
                  _model.searchController?.clear();
                  _searchQuery = '';
                }),
              ),
            ),
            Expanded(
              child: allUsersAsync.when(
                data: (users) {
                  final filteredUsers = users.where((u) {
                    final name = u.displayName.toLowerCase();
                    final email = u.email.toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return name.contains(query) || email.contains(query);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No faculty found',
                      description: _searchQuery.isEmpty 
                          ? 'No staff members registered yet.' 
                          : 'No matching faculty for "$_searchQuery".',
                      actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : 'Add Member',
                      onActionPressed: () {
                        if (_searchQuery.isNotEmpty) {
                          setState(() {
                            _model.searchController?.clear();
                            _searchQuery = '';
                          });
                        } else {
                          context.pushNamed(AddUserWidget.routeName);
                        }
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(context, user);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Teacher user) {
    final theme = FlutterFlowTheme.of(context);
    final access = ref.read(accessControlProvider);
    final bool canEdit = access.canManageTeachers;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => context.pushNamed(
            TeacherProfileWidget.routeName,
            extra: {'userData': user},
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withAlpha(40)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: user.photoUrl.isNotEmpty 
                ? CachedNetworkImage(imageUrl: user.photoUrl, fit: BoxFit.cover)
                : Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
            ),
          ),
          title: Text(
            user.displayName,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '${user.role} • ${user.email}',
            style: AppTypography.caption.copyWith(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: theme.primary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => context.pushNamed(
                    EditProfileWidget.routeName,
                    extra: {'userToEdit': user},
                  ),
                ),
              if (canEdit) const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
