import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/HomePage.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/widgets/AppLogo.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  AuthPage(this.showExitIcon, {Key? key}) : super(key: key);
  static const routeName = "/AuthPage";
  final bool showExitIcon;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late AppStateManager appManager;
  Userdata? userdata;
  String email = "";
  // removed debug-only fields

  // Rendered logo image passed to FlutterLogin (which only accepts ImageProvider)
  ImageProvider? _logoImage;

  final inputBorder = BorderRadius.all(Radius.circular(8.0));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardModel>(context, listen: false).loadBranding();
    });
    AppLogo.toImageProvider(size: 80).then((img) {
      if (mounted) setState(() => _logoImage = img);
    });
  }

  Future<void> resendVerificationLink() async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      var data = {
        "email": email,
      };
      final response = await Utility.getDio()
          .post(ApiUrl.RESEND_VERIFY_LINK, data: jsonEncode({"data": data}));
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        print(response.data);
        Alerts.show(context, "", t.successresendverifymessage);
      } else {
        Alerts.show(context, "", t.cannotprocess);
      }
    } catch (exception) {
      Navigator.of(context).pop();
      Alerts.show(context, "", exception.toString());
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      Alerts.showProgressDialog(context, t.processingpleasewait);
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(context).pop();
      Alerts.show(context, "", t.resetpasswordsuccess);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> registerSuccessMessage(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext _context) {
        return AlertDialog(
          title: Text(""),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                t.resendverifycode,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                resendVerificationLink();
              },
            ),
          ],
        );
      },
    );
  }

  // debug dialog removed

  void _loginAsGuest() {
    final bool appLogin = Provider.of<DashboardModel>(context, listen: false)
            .data['app_login'] as bool? ??
        false;
    if (appLogin) {
      Navigator.of(context).pushReplacementNamed(HomePage.routeName);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<String?> _authUser(LoginData _data) async {
    email = _data.name;
    try {
      var data = {
        "email": _data.name,
        "password": _data.password,
      };
      final response = await Utility.getDio()
          .post(ApiUrl.LOGIN_APP, data: jsonEncode({"data": data}));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = Utility.decodeResponse(response.data);
        if (res["status"] == "error") {
          if (res["statuscode"] == 1) {
            registerSuccessMessage(t.resendverifylink);
          }
          return res["message"];
        } else {
          userdata = Userdata.fromJson(res["user"]);
          return null;
        }
      } else {
        return "A network error occured.";
      }
    } catch (exception) {
      print("[LOGIN] ===== Exception Caught =====");
      print("[LOGIN] Exception type: ${exception.runtimeType}");
      print("[LOGIN] Exception: $exception");
      if (exception is DioException) {
        print("[LOGIN] DioError type: ${exception.type}");
        print("[LOGIN] DioError message: ${exception.message}");
        print("[LOGIN] DioError response: ${exception.response}");
      }
      return exception.toString();
    }
  }

  Future<String?> _signupUser(SignupData _data) async {
    email = _data.name!;
    try {
      var data = {
        "email": _data.name,
        "password": _data.password,
      };

      final response = await Utility.getDio()
          .post(ApiUrl.CREATE_ACCOUNT, data: jsonEncode({"data": data}));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = Utility.decodeResponse(response.data);
        if (res["status"] == "error") {
          if (res.containsKey("statuscode") && res["statuscode"] == 1) {
            registerSuccessMessage(t.resendverifylink);
          }
          return res["message"];
        } else {
          if (res.containsKey("user") && res["user"] != null) {
            try {
              userdata = Userdata.fromJson(res["user"]);
            } catch (_) {}
          }
          return null;
        }
      } else {
        return t.cannotprocess;
      }
    } catch (exception) {
      return exception.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    appManager = Provider.of<AppStateManager>(context);
    final dashboard = Provider.of<DashboardModel>(context);
    final appName = dashboard.data['mobile_app_name']?.toString() ?? '';
    final logoUrl = dashboard.data['mobile_logo_url']?.toString() ?? '';
    final primary = dashboard.brandingColor(
        'mobile_primary_color', const Color(0xFF6366F1));
    final accent =
        dashboard.brandingColor('mobile_accent_color', const Color(0xFFF59E0B));

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: MyColors.mainC0lor,
            height: double.infinity,
            child: FlutterLogin(
              title: appName.isEmpty ? t.appname : appName,
              logo: logoUrl.isEmpty ? _logoImage : NetworkImage(logoUrl),
              onLogin: _authUser,
              onSignup: _signupUser,
              loginAfterSignUp: false,
              disableCustomPageTransformer: true,
              onSubmitAnimationCompleted: () async {
                print("set user data");
                //await appManager.setUserData(userdata!);
                //Navigator.of(context).pop();
                // Skip profile update screen - all profile fields are now optional
                // Users can update their profile later if they wish
                await appManager.setUserData(userdata!);
                if ((Provider.of<DashboardModel>(context, listen: false)
                    .data['app_login'] as bool)) {
                  Navigator.of(context)
                      .pushReplacementNamed(HomePage.routeName);
                } else {
                  Navigator.of(context).pop();
                }
              },
              onRecoverPassword: _recoverPassword,
              /* additionalSignupFields: [
                UserFormField(
                  keyName: "firstname",
                  displayName: "FirstName",
                  icon: Icon(Icons.person),
                ),
                UserFormField(
                  keyName: "lastname",
                  displayName: "LastName",
                  icon: Icon(Icons.person),
                )
              ],*/
              messages: LoginMessages(
                userHint: t.emailaddress,
                recoveryCodeValidationError: "",
                passwordHint: t.password,
                confirmPasswordHint: t.confirmpassword,
                loginButton: t.login,
                signupButton: t.createaccount,
                forgotPasswordButton: t.forgotpassword,
                recoverPasswordButton: t.resetpassword,
                goBackButton: t.goback,
                confirmPasswordError: t.passwordsdontmatch,
                recoverPasswordDescription: t.resetpasswordhint,
                recoverPasswordSuccess: t.resetpasswordsuccess,
                signUpSuccess: "Sign up success",
              ),
              theme: LoginTheme(
                logoWidth: 20,
                cardInitialHeight: 400,
                primaryColor: primary,
                accentColor: accent,
                errorColor: Colors.deepOrange,
                titleStyle: TextStyle(
                  color: MyColors.white,
                  fontSize: 24,
                  letterSpacing: -2,
                  fontWeight: FontWeight.bold,
                ),
                footerTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
                bodyStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                ),
                textFieldStyle: TextStyle(color: Colors.black),
                switchAuthTextColor: Colors.grey[700],
                buttonStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                cardTheme: CardTheme(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(top: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  focusColor: MyColors.mainC0lor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  errorStyle: const TextStyle(
                    backgroundColor: Colors.white,
                    color: Colors.red,
                  ),
                  labelStyle:
                      const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFe2e8f0), width: 1.5),
                    borderRadius: inputBorder,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.mainC0lor, width: 2),
                    borderRadius: inputBorder,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red.shade700, width: 1.5),
                    borderRadius: inputBorder,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red.shade400, width: 2),
                    borderRadius: inputBorder,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFe2e8f0), width: 1),
                    borderRadius: inputBorder,
                  ),
                  suffixIconColor: const Color(0xFF475569),
                  prefixIconColor: const Color(0xFF475569),
                ),
                buttonTheme: LoginButtonTheme(
                  splashColor: MyColors.primaryDark,
                  backgroundColor: MyColors.mainC0lor,
                  highlightColor: MyColors.primaryDark,
                  elevation: 0.0,
                  highlightElevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.showExitIcon,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, top: 50, bottom: 20),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '— or —',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loginAsGuest,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.5), width: 1),
                    ),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
