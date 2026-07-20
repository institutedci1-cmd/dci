import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/components/profile_header/profile_header_widget.dart';
import 'package:d_c_i_teacher_app/components/profile_info_tile/profile_info_tile_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/teacher_profile/teacher_profile_widget.dart' show TeacherProfileWidget;
import 'package:flutter/material.dart';

class TeacherProfileModel extends FlutterFlowModel<TeacherProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ProfileHeader.
  late ProfileHeaderModel profileHeaderModel;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel1;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel2;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel3;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel4;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel5;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel6;
  // Model for ProfileInfoTile.
  late ProfileInfoTileModel profileInfoTileModel7;

  @override
  void initState(BuildContext context) {
    profileHeaderModel = createModel(context, () => ProfileHeaderModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    profileInfoTileModel1 = createModel(context, () => ProfileInfoTileModel());
    profileInfoTileModel2 = createModel(context, () => ProfileInfoTileModel());
    profileInfoTileModel3 = createModel(context, () => ProfileInfoTileModel());
    profileInfoTileModel4 = createModel(context, () => ProfileInfoTileModel());
    profileInfoTileModel5 = createModel(context, () => ProfileInfoTileModel());
    profileInfoTileModel6 = createModel(context, () => ProfileInfoTileModel());
    profileInfoTileModel7 = createModel(context, () => ProfileInfoTileModel());
  }

  @override
  void dispose() {
    profileHeaderModel.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
    profileInfoTileModel1.dispose();
    profileInfoTileModel2.dispose();
    profileInfoTileModel3.dispose();
    profileInfoTileModel4.dispose();
    profileInfoTileModel5.dispose();
    profileInfoTileModel6.dispose();
    profileInfoTileModel7.dispose();
  }
}
