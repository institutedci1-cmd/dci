import 'package:cached_network_image/cached_network_image.dart';
import 'package:d_c_i_teacher_app/components/contact_item/contact_item_widget.dart';
import 'package:d_c_i_teacher_app/components/info_section/info_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/pages/about_dci/about_dci_model.dart';
export 'package:d_c_i_teacher_app/pages/about_dci/about_dci_model.dart';

class AboutDCIWidget extends ConsumerStatefulWidget {
  const AboutDCIWidget({super.key});

  static String routeName = 'AboutDCI';
  static String routePath = '/aboutDCI';

  @override
  ConsumerState<AboutDCIWidget> createState() => _AboutDCIWidgetState();
}

class _AboutDCIWidgetState extends ConsumerState<AboutDCIWidget> {
  late AboutDCIModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AboutDCIModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: ref.watch(instituteInfoStreamProvider).when(
          data: (info) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopHeader(context, info),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMissionVision(context, info),
                        const SizedBox(height: 24.0),
                        _buildStatsRow(context, info),
                        const SizedBox(height: 24.0),
                        _buildContactInfo(context, info),
                        const SizedBox(height: 32.0),
                        _buildFooter(info),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, Map<String, dynamic>? info) {
    return SizedBox(
      height: 320.0,
      child: Stack(
        alignment: const AlignmentDirectional(-1.0, -1.0),
        children: [
          Container(
            height: 260.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary,
                  FlutterFlowTheme.of(context).primaryDark,
                ],
                begin: const AlignmentDirectional(0.0, -1.0),
                end: const AlignmentDirectional(0, 1.0),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'About Deshmukh Institute',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info?['name'] ?? 'Deshmukh Coaching Institute',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0.0, 1.0),
            child: Container(
              width: 140.0,
              height: 140.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.medium,
                border: Border.all(color: FlutterFlowTheme.of(context).primary, width: 3),
              ),
              padding: const EdgeInsets.all(16.0),
              child: CachedNetworkImage(
                imageUrl: info?['logo_url'] ?? '',
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (context, url, error) => Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 44,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.safePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionVision(BuildContext context, Map<String, dynamic>? info) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
            boxShadow: AppShadows.low,
          ),
          child: wrapWithModel(
            model: _model.infoSectionModel1,
            updateCallback: () => safeSetState(() {}),
            child: InfoSectionWidget(
              description: info?['mission'] ?? 'To provide academic excellence.',
              icon: Icon(Icons.rocket_launch_rounded, color: FlutterFlowTheme.of(context).primary),
              title: 'Our Mission',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
            boxShadow: AppShadows.low,
          ),
          child: wrapWithModel(
            model: _model.infoSectionModel2,
            updateCallback: () => safeSetState(() {}),
            child: InfoSectionWidget(
              description: info?['vision'] ?? 'To be leading individuals.',
              icon: Icon(Icons.visibility_rounded, color: FlutterFlowTheme.of(context).primary),
              title: 'Our Vision',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, Map<String, dynamic>? info) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        _buildStatItem(context, info?['stats_years'] ?? '10+', 'Years', theme.primary),
        const SizedBox(width: AppSpacing.md),
        _buildStatItem(context, info?['stats_students'] ?? '5k+', 'Students', theme.info),
        const SizedBox(width: AppSpacing.md),
        _buildStatItem(context, info?['stats_results'] ?? '100%', 'Results', theme.success),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
          boxShadow: AppShadows.low,
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.title.copyWith(
              color: color,
              fontSize: 18,
            )),
            Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Map<String, dynamic>? info) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Us', style: AppTypography.section.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        wrapWithModel(
          model: _model.contactItemModel1,
          updateCallback: () => safeSetState(() {}),
          child: ContactItemWidget(
            icon: Icon(Icons.phone_rounded, color: theme.primary, size: 20),
            label: 'Phone Number',
            value: info?['phone'] ?? '+91 98765 43210',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        wrapWithModel(
          model: _model.contactItemModel2,
          updateCallback: () => safeSetState(() {}),
          child: ContactItemWidget(
            icon: Icon(Icons.email_rounded, color: theme.primary, size: 20),
            label: 'Email Address',
            value: info?['email'] ?? 'admin@deshmukhinstitute.com',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        wrapWithModel(
          model: _model.contactItemModel3,
          updateCallback: () => safeSetState(() {}),
          child: ContactItemWidget(
            icon: Icon(Icons.location_on_rounded, color: theme.primary, size: 20),
            label: 'Office Address',
            value: info?['address'] ?? 'Main Branch, City Center',
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Map<String, dynamic>? info) {
    return Column(
      children: [
        Text(
          'Deshmukh Teachers App ${info?['version'] ?? 'v1.0.3'}',
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Empowering Educators, Inspiring Minds.',
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(fontStyle: FontStyle.italic),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      ],
    );
  }
}
