import '/auth/firebase_auth/auth_util.dart';
import '/components/button/button_widget.dart';
import '/components/profile_header/profile_header_widget.dart';
import '/components/profile_info_tile/profile_info_tile_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teacher_profile_model.dart';
export 'teacher_profile_model.dart';

class TeacherProfileWidget extends StatefulWidget {
  const TeacherProfileWidget({super.key});

  static String routeName = 'TeacherProfile';
  static String routePath = '/teacherProfile';

  @override
  State<TeacherProfileWidget> createState() => _TeacherProfileWidgetState();
}

class _TeacherProfileWidgetState extends State<TeacherProfileWidget> {
  late TeacherProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeacherProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .snapshots(),
          builder: (context, snapshot) {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            return SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  wrapWithModel(
                    model: _model.profileHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: ProfileHeaderWidget(
                      designation: userData?['designation'] ??
                          'Senior Faculty • M.Sc., M.Ed.',
                      name: currentUserDisplayName != ''
                          ? currentUserDisplayName
                          : (userData?['display_name'] ??
                              'Prof. Rajesh Deshmukh'),
                      photoUrl: currentUserPhoto != ''
                          ? currentUserPhoto
                          : (userData?['photo_url'] ?? null),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: wrapWithModel(
                            model: _model.buttonModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonWidget(
                              icon: Icon(
                                Icons.edit_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              iconPresent: true,
                              iconEndPresent: false,
                              content: 'Edit Profile',
                              variant: 'outline',
                              size: 'medium',
                              fullWidth: true,
                              loading: false,
                              disabled: false,
                              onPressed: () async {
                                context.pushNamed(EditProfileWidget.routeName);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: wrapWithModel(
                            model: _model.buttonModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonWidget(
                              icon: Icon(
                                Icons.share_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              iconPresent: true,
                              iconEndPresent: false,
                              content: 'Share CV',
                              variant: 'secondary',
                              size: 'medium',
                              fullWidth: true,
                              loading: false,
                              disabled: false,
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(width: 16.0)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 0.0, 24.0, 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: Container(
                            child: Text(
                              'Personal Information',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                    lineHeight: 1.35,
                                  ),
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.email_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Email Address',
                            value: currentUserEmail != ''
                                ? currentUserEmail
                                : (userData?['email'] ??
                                    'rajesh.d@deshmukhcoaching.com'),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.phone_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Mobile Number',
                            value: currentPhoneNumber != ''
                                ? currentPhoneNumber
                                : (userData?['phone_number'] ??
                                    '+91 98765 43210'),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel3,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.badge_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Employee ID',
                            value: userData?['employee_id'] ??
                                'Deshmukh-T-2024-089',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel4,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.event_available_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Joined Date',
                            value: userData?['joined_date'] ?? '15 May 2018',
                          ),
                        ),
                        Container(
                          height: 24.0,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: Container(
                            child: Text(
                              'Education & Expertise',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                    lineHeight: 1.35,
                                  ),
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel5,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.school_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Qualification',
                            value: userData?['qualification'] ??
                                'M.Sc. Physics, M.Ed. Education',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel6,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.psychology_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Subject Expertise',
                            value: userData?['subject_expertise'] ??
                                'Advanced Physics & Mathematics',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.profileInfoTileModel7,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileInfoTileWidget(
                            icon: Icon(
                              Icons.workspace_premium_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .onPrimaryContainer,
                              size: 20.0,
                            ),
                            label: 'Experience',
                            value: userData?['experience'] ??
                                '12 Years in Competitive Coaching',
                          ),
                        ),
                        Container(
                          height: 24.0,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: Container(
                            child: Text(
                              'Settings & Preferences',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                    lineHeight: 1.35,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                          child: SwitchListTile.adaptive(
                            value: userData?['notifications_enabled'] ?? true,
                            onChanged: (newValue) async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserUid)
                                  .update({
                                'notifications_enabled': newValue,
                              });
                            },
                            title: Text(
                              'Push Notifications',
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                            subtitle: Text(
                              'Receive alerts for new announcements and schedules.',
                              style: FlutterFlowTheme.of(context).labelSmall,
                            ),
                            activeColor: FlutterFlowTheme.of(context).primary,
                            activeTrackColor:
                                FlutterFlowTheme.of(context).primary10,
                            dense: false,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ),
                        Container(
                          height: 24.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).info,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_rounded,
                                    size: 24.0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'About Deshmukh Teacher Portal',
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .labelLarge
                                                    .fontStyle,
                                                lineHeight: 1.33,
                                              ),
                                        ),
                                        Text(
                                          'This profile is managed by the Deshmukh HR department. For any discrepancies, please contact the administrator.',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(const SizedBox(height: 4.0)),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 16.0)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 24.0,
                        ),
                        wrapWithModel(
                          model: createModel(context, () => ButtonModel()),
                          updateCallback: () => safeSetState(() {}),
                          child: ButtonWidget(
                            icon: Icon(
                              Icons.logout_rounded,
                              color: FlutterFlowTheme.of(context).onError,
                              size: 24.0,
                            ),
                            iconPresent: true,
                            content: 'Logout',
                            variant: 'outline',
                            size: 'large',
                            fullWidth: true,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text(
                                          'Are you sure you want to log out?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Logout'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (confirm) {
                                await authManager.signOut();
                                context.goNamed(LoginWidget.routeName);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40.0,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

