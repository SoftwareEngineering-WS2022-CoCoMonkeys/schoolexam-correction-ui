abstract class BlocLoading {
  /// If a non empty [description] is given, the global listener is going to respect this text in the representation to the user.
  /// It is therefore best practice to include a localized string informing the user about the reason for the loading procedure.
  final String description;

  BlocLoading({this.description = ""});
}