import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _google = GoogleSignIn();

  Future<GoogleSignInAccount?> signIn() => _google.signIn();

  Future<void> signOut() => _google.signOut();
}
