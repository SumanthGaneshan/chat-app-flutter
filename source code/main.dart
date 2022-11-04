import 'package:chat_app/screens/all_contact.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/auth/sign_up_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/recent_chats.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

Map<int, Color> color = {
  50: Color.fromRGBO(230, 230, 250, .1),
  100: Color.fromRGBO(230, 230, 250, .2),
  200: Color.fromRGBO(230, 230, 250, .3),
  300: Color.fromRGBO(230, 230, 250, .4),
  400: Color.fromRGBO(230, 230, 250, .5),
  500: Color.fromRGBO(230, 230, 250, .6),
  600: Color.fromRGBO(230, 230, 250, .7),
  700: Color.fromRGBO(230, 230, 250, .8),
  800: Color.fromRGBO(230, 230, 250, .9),
  900: Color.fromRGBO(230, 230, 250, 1),
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MaterialColor colorCustom = MaterialColor(0xFFFF4567, color);

    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, appSnapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              // primarySwatch:  colorCustom,
              // primaryColor: colorCustom,
              // colorScheme: ThemeData().colorScheme.copyWith(
              //   primary: colorCustom,
              //   secondary: Colors.blue,
              // ),
              pageTransitionsTheme: const PageTransitionsTheme(builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              }),
            ),
            home: appSnapshot.connectionState != ConnectionState.done
                ? const SplashScreen()
                : StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      if(userSnapshot.connectionState == ConnectionState.waiting){
                        return const SplashScreen();
                      }
                      if (userSnapshot.hasData) {
                        return AllContact();
                      }
                      return SignUpScreen();
                    },
                  ),
            routes: {
              LoginScreen.routeName: (ctx) => LoginScreen(),
              SignUpScreen.routeName: (ctx) => SignUpScreen(),
              AllContact.routeName: (ctx) => AllContact(),
            },
          );
        });
  }
}
