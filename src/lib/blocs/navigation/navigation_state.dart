import 'package:equatable/equatable.dart';

enum AppNavigationContext { exams, analysis }

class AppNavigationState extends Equatable {
  /// Determines in which context of the app the user is currently navigating in.
  final AppNavigationContext context;

  /// This parameter determines if the login screen is overlayed
  final bool requiresAuthentication;

  /// This parameter determines the currently selected exam.
  /// If no exam is selected, an empty string is provided.
  final String examId;

  const AppNavigationState._(
      {this.examId = "",
      this.requiresAuthentication = true,
      this.context = AppNavigationContext.exams});

  const AppNavigationState.initial() : this._();

  AppNavigationState copyWith(
      {String? examId,
      bool? requiresAuthentication,
      AppNavigationContext? context}) {
    return AppNavigationState._(
        examId: examId ?? this.examId,
        requiresAuthentication:
            requiresAuthentication ?? this.requiresAuthentication,
        context: context ?? this.context);
  }

  @override
  List<Object> get props => [requiresAuthentication, examId, context];
}
