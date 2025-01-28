import 'package:flutter/material.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'package:ordering_system/dialog/dialog.dart';
import 'package:ordering_system/routing/router.dart';
import 'package:ordering_system/screens/login_screen.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';

class RegisterScreen extends StatefulWidget {
  static const String route = '/register';

  static const String name = 'RegisterScreen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController firstname, lastname, email, password, confrimPass;
  bool isVisible = false;
  bool isObscure = true;

   @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    firstname = TextEditingController();
    lastname = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    confrimPass = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            GlobalRouter.I.router.go(Loginscreen.route);
          },
          icon: const Icon(Icons.arrow_back),),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left:16.0, right: 16.0,bottom: 16.0, top: 5.0),
        child: Form(
          key: formKey,
          child: SizedBox(
            width: SizeConfig.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('REGISTER', style: mRegular.copyWith(color: mBlack, fontSize: 30, letterSpacing: 3)),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: firstname,
                        decoration: const InputDecoration(labelText: 'First Name'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: lastname,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: email,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 320,
                      child:  TextField(
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
                      child: Text("Register", style: mRegular.copyWith(color: mBlack, fontSize: 14),),
                    ),
                  ],
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
      WaitingDialog.show(context,future: AuthController.I.register(
        email.text.trim(),
        password.text.trim(),
        firstname.text.trim(),
        lastname.text.trim(),
      ));
    } 
  }
}
