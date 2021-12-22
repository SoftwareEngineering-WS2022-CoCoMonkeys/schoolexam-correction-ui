import 'package:schoolexam_correction_ui/navigation/paths/route_path.dart';

/// Route to the correction overview of a selected exam
class CorrectionRoutePath extends RoutePath {
  final String id;

  /// We want to navigate to the correction overview page for the exam corresponding to the id
  CorrectionRoutePath.start(this.id);
}
