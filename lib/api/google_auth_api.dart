import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthApi{
  static final _googleSignIn = GoogleSignIn(scopes: ['https://mail.google.com/']);

  static Future<GoogleSignInAccount?> signIn() async{
    if(await _googleSignIn.isSignedIn()){
      print(_googleSignIn.currentUser);
      return _googleSignIn.currentUser;
    }
    else {
      print('the user was not found signed in');
      return await _googleSignIn.signIn();
    }
  }

  static Future signOut() => _googleSignIn.signOut();
}