import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/model/http_exception.dart';
import 'package:retroshare/provider/identity.dart';
import 'package:retroshare/provider/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

enum PasswordError { correct, notTheSame, tooShort }

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  TextEditingController nodeNameController = TextEditingController();

  bool advancedOption = false;
  bool isUsernameCorrect = true;
  PasswordError passwordError = PasswordError.correct;

  @override
  void initState() {
    super.initState();
    advancedOption = false;
    isUsernameCorrect = true;
    passwordError = PasswordError.correct;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    nodeNameController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    var success = true;
    if (usernameController.text.length < 3) {
      setState(() {
        isUsernameCorrect = false;
      });
      success = false;
    }
    if (passwordController.text != repeatPasswordController.text) {
      setState(() {
        passwordError = PasswordError.notTheSame;
      });
      success = false;
    }
    if (passwordController.text.length < 3) {
      setState(() {
        passwordError = PasswordError.tooShort;
      });
      success = false;
    }

    if (!success) return;

    await Navigator.pushNamed(
      context,
      '/',
      arguments: {
        'statusText': 'Creating account...\nThis could take minutes',
        'isLoading': true,
        'spinner': true,
      },
    );
    try {
      final accountSignup =
          Provider.of<AccountCredentials>(context, listen: false);
      await accountSignup
          .signup(
        usernameController.text,
        passwordController.text,
        nodeNameController.text,
      )
          .then((value) {
        final ids = Provider.of<Identities>(context, listen: false);
        ids.fetchOwnidenities().then((value) {
          ids.ownIdentity.isEmpty
              ? Navigator.pushReplacementNamed(
                  context,
                  '/create_identity',
                  arguments: true,
                )
              : Navigator.pushReplacementNamed(context, '/home');
        });
      });
    } on HttpException {
      const errorMessage = 'Authentication failed';
      await errorShowDialog(errorMessage, 'Something went wrong', context);
    } catch (e) {
      await errorShowDialog(
        'Retroshare Service Down',
        'Try to restart the app Again!',
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/rs-logo.png',
                    height: 250,
                    width: 250,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFFF5F5F5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 40,
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.person_outline,
                          color: Color(0xFF9E9E9E),
                          size: 22,
                        ),
                        hintText: 'Username',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Visibility(
                  visible: !isUsernameCorrect,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                          width: 52,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Username is too short',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isUsernameCorrect,
                  child: const SizedBox(height: 10),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFFF5F5F5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 40,
                    child: TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF9E9E9E),
                          size: 22,
                        ),
                        hintText: 'Password',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      obscureText: true,
                    ),
                  ),
                ),
                Visibility(
                  visible: passwordError == PasswordError.tooShort,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                          width: 52,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Password is too short',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: passwordError != PasswordError.tooShort,
                  child: const SizedBox(height: 10),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFFF5F5F5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 40,
                    child: TextField(
                      controller: repeatPasswordController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF9E9E9E),
                          size: 22,
                        ),
                        hintText: 'Repeat password',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      obscureText: true,
                    ),
                  ),
                ),
                Visibility(
                  visible: passwordError == PasswordError.notTheSame,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                          width: 52,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Passwords do not match',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: passwordError != PasswordError.notTheSame,
                  child: const SizedBox(height: 10),
                ),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        advancedOption = !advancedOption;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        //color: Color(0xFFF5F5F5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      height: 45,
                      child: Row(
                        children: <Widget>[
                          Checkbox(
                            value: advancedOption,
                            onChanged: (bool? value) {
                              setState(() {
                                advancedOption = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Advanced option',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: advancedOption,
                  child: const SizedBox(height: 10),
                ),
                Visibility(
                  visible: advancedOption,
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFFF5F5F5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 40,
                      child: TextField(
                        controller: nodeNameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.smartphone,
                            color: Color(0xFF9E9E9E),
                            size: 22,
                          ),
                          hintText: 'Node name',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: advancedOption,
                  child: const SizedBox(height: 10),
                ),
                Visibility(
                  visible: advancedOption,
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        //color: Color(0xFFF5F5F5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      height: 45,
                      child: Row(
                        children: <Widget>[
                          Checkbox(
                            // todo: implement Tor/I2p Hidden node
                            value: false,
                            onChanged: (bool? value) {},
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Tor/I2p Hidden node',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await createAccount();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFF00FFFF),
                            Color(0xFF29ABE2),
                          ],
                          begin: Alignment(-1, -4),
                          end: Alignment(1, 4),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Create account',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
