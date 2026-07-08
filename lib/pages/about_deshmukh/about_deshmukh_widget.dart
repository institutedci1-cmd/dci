import '/components/contact_item/contact_item_widget.dart';
import '/components/info_section/info_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_deshmukh_model.dart';
export 'about_deshmukh_model.dart';

class AboutDeshmukhWidget extends StatefulWidget {
  const AboutDeshmukhWidget({super.key});

  static String routeName = 'AboutDeshmukh';
  static String routePath = '/aboutDeshmukh';

  @override
  State<AboutDeshmukhWidget> createState() => _AboutDeshmukhWidgetState();
}

class _AboutDeshmukhWidgetState extends State<AboutDeshmukhWidget> {
  late AboutDeshmukhModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AboutDeshmukhModel());

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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('config')
              .doc('institute_info')
              .snapshots(),
          builder: (context, snapshot) {
            final info = snapshot.data?.data() as Map<String, dynamic>?;

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
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, Map<String, dynamic>? info) {
    return SizedBox(
      height: 280.0,
      child: Stack(
        alignment: const AlignmentDirectional(-1.0, -1.0),
        children: [
          Container(
            height: 220.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary,
                  FlutterFlowTheme.of(context).tertiary
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
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'About Deshmukh Institute',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info?['name'] ?? 'Deshmukh Coaching Institute',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).onBackground90,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0.0, 1.0),
            child: Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Image.network(
                info?['logo_url'] ?? 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/d-c-i-teacher-app-lffjyu/assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/logo.png', fit: BoxFit.contain),
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
        wrapWithModel(
          model: _model.infoSectionModel1,
          updateCallback: () => safeSetState(() {}),
          child: InfoSectionWidget(
            description: info?['mission'] ?? 'To provide academic excellence.',
            icon: Icon(Icons.rocket_launch_rounded, color: FlutterFlowTheme.of(context).primary),
            title: 'Our Mission',
          ),
        ),
        const SizedBox(height: 16),
        wrapWithModel(
          model: _model.infoSectionModel2,
          updateCallback: () => safeSetState(() {}),
          child: InfoSectionWidget(
            description: info?['vision'] ?? 'To be leading individuals.',
            icon: Icon(Icons.visibility_rounded, color: FlutterFlowTheme.of(context).primary),
            title: 'Our Vision',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, Map<String, dynamic>? info) {
    return Row(
      children: [
        _buildStatItem(context, info?['stats_years'] ?? '10+', 'Years'),
        const SizedBox(width: 16),
        _buildStatItem(context, info?['stats_students'] ?? '5k+', 'Students'),
        const SizedBox(width: 16),
        _buildStatItem(context, info?['stats_results'] ?? '100%', 'Results'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: Column(
          children: [
            Text(value, style: FlutterFlowTheme.of(context).titleLarge.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              color: FlutterFlowTheme.of(context).primary,
              fontWeight: FontWeight.bold,
            )),
            Text(label, style: FlutterFlowTheme.of(context).labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Map<String, dynamic>? info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Us', style: FlutterFlowTheme.of(context).titleMedium.override(
          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 16),
        wrapWithModel(
          model: _model.contactItemModel1,
          updateCallback: () => safeSetState(() {}),
          child: ContactItemWidget(
            icon: Icon(Icons.phone_rounded, color: FlutterFlowTheme.of(context).primary),
            label: 'Phone Number',
            value: info?['phone'] ?? '+91 98765 43210',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.contactItemModel2,
          updateCallback: () => safeSetState(() {}),
          child: ContactItemWidget(
            icon: Icon(Icons.email_rounded, color: FlutterFlowTheme.of(context).primary),
            label: 'Email Address',
            value: info?['email'] ?? 'info@deshmukhcoaching.com',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.contactItemModel3,
          updateCallback: () => safeSetState(() {}),
          child: ContactItemWidget(
            icon: Icon(Icons.location_on_rounded, color: FlutterFlowTheme.of(context).primary),
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
        Text('Deshmukh Teacher App ${info?['version'] ?? 'v2.4.0'}', style: FlutterFlowTheme.of(context).labelSmall),
        const SizedBox(height: 4),
        Text('Made with ❤️ for Deshmukh Faculty', style: FlutterFlowTheme.of(context).labelSmall),
      ],
    );
  }
}
