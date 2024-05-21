import 'package:flutter/material.dart';
import 'package:uncw_learn/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 73, 66),
      ),
      body: Container(
        color: Colors.teal,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Teal Tours!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const LoginForm(),
              const Padding(
                padding: EdgeInsets.all(40),
              ),
              const Text(
                "New user?",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String? email;
  String? password;
  String? error;
  final formKey = GlobalKey<FormState>();
  bool isEmailValid = true;
  bool validated = false;

  void tryLogin(email, password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      error = null;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed!'),
            duration: Duration(seconds: 2),
          ),
        );
        error = 'An error occurred: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(padding: EdgeInsets.all(25)),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your email",
              border: OutlineInputBorder(),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
            ),
            maxLength: 64,
            onChanged: (value) {
              email = value;
              if (value.contains("@") && value.contains(".")) {
                setState(() {
                  isEmailValid = true;
                });
              } else {
                setState(() {
                  isEmailValid = false;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty || !isEmailValid) {
                return "Please enter an email";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter a password",
              border: OutlineInputBorder(),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
            ),
            obscureText: true,
            onChanged: (value) => password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a password";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              tryLogin(email, password, context);
            },
            child: const Text('Login'),
          )
        ],
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 6, 73, 66),
        ),
        body: Container(
          color: Colors.teal,
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to Teal Tours!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  RegisterForm()
                ]),
          ),
        ));
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String? email;
  String? password;
  String? confirmPassword;
  final userRef = FirebaseFirestore.instance.collection('Users');

  final formKey = GlobalKey<FormState>();
  bool isEmailValid = true;

  @override
  Widget build(BuildContext context) {
    void firebaseRegister() async {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email!, password: password!);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration successful!'),
          duration: Duration(seconds: 2),
        ));
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        setState(() {});
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 50),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your email",
              border: OutlineInputBorder(),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
            ),
            maxLength: 64,
            onChanged: (value) {
              email = value;
              if (value.contains("@") && value.contains(".")) {
                setState(() {
                  isEmailValid = true;
                });
              } else {
                setState(() {
                  isEmailValid = false;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty || !isEmailValid) {
                return "Please enter an email";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter a password",
              border: OutlineInputBorder(),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
            ),
            obscureText: true,
            onChanged: (value) => password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a password";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Re-enter a password",
              border: OutlineInputBorder(),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
            ),
            obscureText: true,
            onChanged: (value) => confirmPassword = value,
            validator: (value) {
              if (value == null || value.isEmpty || value != password) {
                return "Password must match";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Perform registration logic here
                firebaseRegister();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration successful!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (home) => const HomeScreen()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration failed!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }
}
