import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/controllers/auth_controller.dart';
import '/models/http_exception.dart';

// BuildContext? context;

class AuthenticationScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  AuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    print('This means it\'s not authenticated and we are in Auth screen');
    //print(AuthController.instance.isAuth);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final AuthController controller = Get.find();
  AuthCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    var _authMode = AuthController.instance.authMode;
    var _isLoading = AuthController.instance.isLoading;
    final Map<String, String> _authData = {
      'email': '',
      'password': '',
    };
    AnimationController? _controller = AuthController.instance.controller;
    Animation<Offset>? _slideAnimation = AuthController.instance.slideAnimation;
    Animation<double>? _opacityAnimation =
        AuthController.instance.opacityAnimation;

    void _switchAuthMode() {
      if (_authMode!.value == AuthMode.Login) {
        _authMode.value = AuthMode.Signup;
        _controller!.forward();
      } else {
        _authMode.value = AuthMode.Login;
        _controller!.reverse();
      }
    }

    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An Error Occurred!'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Get.back();
              },
            )
          ],
        ),
      );
    }

    Future<void> _submit() async {
      if (!controller.key.currentState!.validate()) {
        return;
      }
      // print('app is here!!!');
      controller.key.currentState!.save();
      _isLoading!.value = true;

      try {
        if (_authMode!.value == AuthMode.Login) {
          // Log user in
          // print('app is here!!!222');

          await AuthController.instance.login(
            _authData['email'] as String,
            _authData['password'] as String,
          );
        } else {
          // print('app is here!!!333333');

          // Sign user up
          await AuthController.instance.signup(
            _authData['email'] as String,
            _authData['password'] as String,
          );
        }
      } on HttpException catch (error) {
        // print('app is here!!!44444');

        var errorMessage = 'Authentication failed';

        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessage = 'This email address is already in use.';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          errorMessage = 'This is not a valid email address';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          errorMessage = 'This password is too weak.';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessage = 'Could not find a user with that email.';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessage = 'Invalid password.';
        }
        _showErrorDialog(errorMessage);
      } catch (error) {
        var errorMessage =
            'Could not authenticate you. Please try again later.' +
                error.toString();
        _showErrorDialog(errorMessage);
      }
      _isLoading.value = false;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode!.value == AuthMode.Signup ? 320 : 260,
        //height: _heightAnimation.value.height,
        constraints: BoxConstraints(
            minHeight: _authMode.value == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Form(
              key: controller.key,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid email!';
                        }
                      },
                      onSaved: (value) {
                        _authData['email'] = value as String;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      controller: controller.passwordController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return 'Password is too short!';
                        }
                      },
                      onSaved: (value) {
                        _authData['password'] = value as String;
                      },
                    ),
                    AnimatedContainer(
                      constraints: BoxConstraints(
                        minHeight: _authMode.value == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode.value == AuthMode.Signup ? 120 : 0,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: FadeTransition(
                        opacity: _opacityAnimation as Animation<double>,
                        child: SlideTransition(
                          position: _slideAnimation as Animation<Offset>,
                          child: TextFormField(
                            enabled: _authMode.value == AuthMode.Signup,
                            decoration: const InputDecoration(
                                labelText: 'Confirm Password'),
                            obscureText: true,
                            validator: _authMode.value == AuthMode.Signup
                                ? (value) {
                                    if (value !=
                                        controller.passwordController.text) {
                                      return 'Passwords do not match!';
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (_isLoading!.value)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        child: Text(_authMode.value == AuthMode.Login
                            ? 'LOGIN'
                            : 'SIGN UP'),
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          primary: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                          onPrimary:
                              Theme.of(context).primaryTextTheme.button!.color,
                        ),
                      ),
                    TextButton(
                      child: Text(
                          '${_authMode.value == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} '),
                      onPressed: _switchAuthMode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

// return Scaffold(
//   body: Center(
//     child: Container(
//       constraints: const BoxConstraints(maxWidth: 400),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 12),
//                 child: Image.asset("icons/logo.png"),
//               ),
//               Expanded(child: Container()),
//             ],
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           Row(
//             children: [
//               Text("Login",
//                   style: GoogleFonts.roboto(
//                       fontSize: 30, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Row(
//             children: [
//               CustomText(
//                 text: "Welcome.",
//                 color: lightGrey,
//                 size: 10,
//                 weight: FontWeight.w300,
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           TextField(
//             decoration: InputDecoration(
//                 labelText: "Email",
//                 hintText: "abc@domain.com",
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20))),
//           ),
//           SizedBox(
//             height: 15,
//           ),
//           TextField(
//             obscureText: true,
//             decoration: InputDecoration(
//                 labelText: "Password",
//                 hintText: "123",
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20))),
//           ),
//           SizedBox(
//             height: 15,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Checkbox(value: true, onChanged: (value) {}),
//                   CustomText(
//                     text: "Remeber Me",
//                     weight: FontWeight.bold,
//                     size: 10,
//                     color: dark,
//                   ),
//                 ],
//               ),
//               CustomText(
//                 text: "Forgot password?",
//                 color: active,
//                 size: 10,
//                 weight: FontWeight.bold,
//               )
//             ],
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Obx(
//             () => ElevatedButton(
//                 child: Text(_authMode.value == AuthMode.Login
//                     ? 'LOGIN'
//                     : 'SIGN UP'),
//                 onPressed: _submit,
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   primary: Theme.of(context).primaryColor,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 30.0, vertical: 8.0),
//                   onPrimary:
//                       Theme.of(context).primaryTextTheme.button!.color,
//                 )),
//           ),
//           Obx(() => TextButton(
//               child: Text(
//                   '${_authMode.value == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} '),
//               onPressed: _switchAuthMode,
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 30.0, vertical: 4),
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 textStyle: TextStyle(color: Theme.of(context).primaryColor),
//               ))),
//           const SizedBox(
//             height: 15,
//           ),
//           RichText(
//               text: TextSpan(children: [
//             const TextSpan(text: "Do not have admin credentials? "),
//             TextSpan(
//                 text: "Request Credentials! ",
//                 style: TextStyle(color: active))
//           ]))
//         ],
//       ),
//     ),
//   ),
// );
