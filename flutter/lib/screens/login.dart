// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:chat_app/api/loginRequest.dart';
import 'package:chat_app/api/registerRequest.dart';
import 'package:chat_app/utils/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.submit});

  final void Function(String token) submit;

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _username = '';
  var _password = '';
  var _email = '';
  var _isLoading = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    print("islogin: $_isLogin");
    if (!isValid) {
      // show error message ...
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_isLogin) {
      try {
        var token = await LoginRequest.login(_username, _password);
        if (token == null) {
          print("it null");
        }
        widget.submit(token);
      } catch (error) {
        print(error);
        CustomSnackBar.show(
          context,
          'Please check your credentials or try again later',
          const Icon(Icons.error_outline_outlined, color: Colors.white),
          Colors.red,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      try {
        var res = await RegisterRequest.register(_username, _password, _email);
        print(res);
        if (res == 200) {
          CustomSnackBar.show(
            context,
            'User has been created succesfully',
            const Icon(Icons.check, color: Colors.white),
            Color.fromARGB(255, 15, 165, 1),
          );

          setState(() {
            _isLogin = !_isLogin;
            _form.currentState!.reset();
          });
        } else {
          CustomSnackBar.show(
            context,
            'Error creating account, please try again later',
            const Icon(Icons.error_outline_outlined, color: Colors.white),
            Colors.red,
          );
        }
      } catch (err) {
        CustomSnackBar.show(
          context,
          '$err',
          const Icon(Icons.error_outline_outlined, color: Colors.white),
          Colors.red,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/cart.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            keyboardType: TextInputType.name,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if ((value == null || value.trim().isEmpty) &&
                                  !_isLogin) {
                                return 'Username can not be empty';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _username = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              keyboardType: TextInputType.name,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _email = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (value) {
                              if (!_isLogin) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 8) {
                                  return 'Password must be 8 characters minimum';
                                }
                              }
                              return null;
                            },
                            obscureText: true,
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(11)),
                                  side: BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : _isLogin
                                    ? const Text('Login')
                                    : const Text('Register'),
                          ),
                          if (!_isLoading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _form.currentState!.reset();
                                  _isLoading = false;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
