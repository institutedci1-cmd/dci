import 'package:d_c_i_teacher_app/components/dashboard_card/dashboard_card_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_model.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_widget.dart' show HomeDashboardWidget;
import 'package:flutter/material.dart';

class HomeDashboardModel extends FlutterFlowModel<HomeDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for DashboardCard.
  late DashboardCardModel dashboardCardModel1;
  // Model for DashboardCard.
  late DashboardCardModel dashboardCardModel2;
  // Model for DashboardCard.
  late DashboardCardModel dashboardCardModel3;
  // Model for DashboardCard.
  late DashboardCardModel dashboardCardModel4;
  // Model for DashboardCard.
  late DashboardCardModel dashboardCardModel5;
  // Model for DashboardCard.
  late DashboardCardModel dashboardCardModel6;

  @override
  void initState(BuildContext context) {
    dashboardCardModel1 = createModel(context, () => DashboardCardModel());
    dashboardCardModel2 = createModel(context, () => DashboardCardModel());
    dashboardCardModel3 = createModel(context, () => DashboardCardModel());
    dashboardCardModel4 = createModel(context, () => DashboardCardModel());
    dashboardCardModel5 = createModel(context, () => DashboardCardModel());
    dashboardCardModel6 = createModel(context, () => DashboardCardModel());
  }

  @override
  void dispose() {
    dashboardCardModel1.dispose();
    dashboardCardModel2.dispose();
    dashboardCardModel3.dispose();
    dashboardCardModel4.dispose();
    dashboardCardModel5.dispose();
    dashboardCardModel6.dispose();
  }
}
