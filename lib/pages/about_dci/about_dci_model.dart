import 'package:d_c_i_teacher_app/components/contact_item/contact_item_widget.dart';
import 'package:d_c_i_teacher_app/components/info_section/info_section_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/about_dci/about_dci_widget.dart' show AboutDCIWidget;
import 'package:flutter/material.dart';

class AboutDCIModel extends FlutterFlowModel<AboutDCIWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for InfoSection.
  late InfoSectionModel infoSectionModel1;
  // Model for InfoSection.
  late InfoSectionModel infoSectionModel2;
  // Model for ContactItem.
  late ContactItemModel contactItemModel1;
  // Model for ContactItem.
  late ContactItemModel contactItemModel2;
  // Model for ContactItem.
  late ContactItemModel contactItemModel3;

  @override
  void initState(BuildContext context) {
    infoSectionModel1 = createModel(context, () => InfoSectionModel());
    infoSectionModel2 = createModel(context, () => InfoSectionModel());
    contactItemModel1 = createModel(context, () => ContactItemModel());
    contactItemModel2 = createModel(context, () => ContactItemModel());
    contactItemModel3 = createModel(context, () => ContactItemModel());
  }

  @override
  void dispose() {
    infoSectionModel1.dispose();
    infoSectionModel2.dispose();
    contactItemModel1.dispose();
    contactItemModel2.dispose();
    contactItemModel3.dispose();
  }
}
