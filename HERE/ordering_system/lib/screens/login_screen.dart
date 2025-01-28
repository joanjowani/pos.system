import 'package:flutter/material.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'package:ordering_system/dialog/dialog.dart';
import 'package:ordering_system/routing/router.dart';
import 'package:ordering_system/screens/register_screen.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';

class Loginscreen extends StatefulWidget {
  static const String route = '/';

  static const String name = 'LoginScreen';
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController email, password;

  bool isVisible = false;
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    email = TextEditingController();
    password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SizedBox(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LOGIN', style: mRegular.copyWith(color: mBlack, fontSize: 30, letterSpacing: 3)),
                const SizedBox(height: 30,),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email',),
                  ),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    ),
                    obscureText: isObscure,
                  ),
                ),
                const SizedBox(height: 80),
                ElevatedButton(
                  style: buttonOrange,
                   onPressed: () {
                      onSubmit();
                    },
                    child: Text("Login", style: mRegular.copyWith(color: mBlack, fontSize: 16),),
                ),
                const SizedBox(height: 30,),
                TextButton(
                  onPressed: () {
                    GlobalRouter.I.router.go(RegisterScreen.route);
                  },
                  child: Text('Don\'t have and account?  Register', style: mRegular.copyWith(color: mBlack, fontSize: 14),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      WaitingDialog.show(context,
          future: AuthController.I
              .login(email.text.trim(), password.text.trim()));
    }
  }
}