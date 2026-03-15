import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants.dart';
import 'storage.dart';
import 'pages/login_page.dart' show LoginPage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAaNCV270EBAQuQt2o8Up_ud8_iY6r1AVU",
      projectId: "monappvideo-6d93a",
      storageBucket: "monappvideo-6d93a.firebasestorage.app",
      messagingSenderId: "545767765158",
      appId: "1:545767765158:android:eb6e738aff4ab14e923067",
    ),
  );
  await chargerUtilisateurs();
  await chargerVideos();
  await chargerHistorique();
  await chargerFavoris();
  await chargerComptesLocaux();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeApp(),
      home: const LoginPage(),
    );
  }
}