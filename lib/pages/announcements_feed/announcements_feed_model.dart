import 'package:d_c_i_teacher_app/components/announcement_card/announcement_card_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:d_c_i_teacher_app/pages/announcements_feed/announcements_feed_widget.dart' show AnnouncementsFeedWidget;
import 'package:flutter/material.dart';

class AnnouncementsFeedModel extends FlutterFlowModel<AnnouncementsFeedWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AnnouncementCard.
  late AnnouncementCardModel announcementCardModel1;
  // Model for AnnouncementCard.
  late AnnouncementCardModel announcementCardModel2;
  // Model for AnnouncementCard.
  late AnnouncementCardModel announcementCardModel3;
  // Model for AnnouncementCard.
  late AnnouncementCardModel announcementCardModel4;
  // Model for AnnouncementCard.
  late AnnouncementCardModel announcementCardModel5;

  @override
  void initState(BuildContext context) {
    announcementCardModel1 =
        createModel(context, () => AnnouncementCardModel());
    announcementCardModel2 =
        createModel(context, () => AnnouncementCardModel());
    announcementCardModel3 =
        createModel(context, () => AnnouncementCardModel());
    announcementCardModel4 =
        createModel(context, () => AnnouncementCardModel());
    announcementCardModel5 =
        createModel(context, () => AnnouncementCardModel());
  }

  @override
  void dispose() {
    announcementCardModel1.dispose();
    announcementCardModel2.dispose();
    announcementCardModel3.dispose();
    announcementCardModel4.dispose();
    announcementCardModel5.dispose();
  }
}
