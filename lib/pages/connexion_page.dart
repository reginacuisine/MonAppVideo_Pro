import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../storage.dart';
import 'login_page.dart';
import 'inscription_page.dart';
import 'admin_page.dart';
import 'video_list_page.dart';
import 'dart:async';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});
  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  bool _showPassword = false;
  String? _emailErreur;
  String? _passwordErreur;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validerEmail(String val) {
    setState(() {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
      _emailErreur = emailRegex.hasMatch(val.trim()) ? null : "Email invalide";
    });
  }

  void _validerPassword(String val) {
    setState(() {
      _passwordErreur = val.length >= 6 ? null : "Minimum 6 caractères";
    });
  }

  Future<void> _connecter() async {
    _validerEmail(_emailController.text);
    _validerPassword(_passwordController.text);
    if (_emailErreur != null || _passwordErreur != null) return;

    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool connecte = false;

    // Essayer Firebase avec timeout court
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password,
      ).timeout(const Duration(seconds: 4));
      connecte = true;
      if (!listeUtilisateursLocaux.contains(email)) {
        listeUtilisateursLocaux.add(email);
        await sauvegarderUtilisateurs();
      }
    } catch (e) {
      // Firebase échoue (pas internet, timeout, reCAPTCHA...) → compte local
      connecte = connecterCompteLocal(email, password);
    }

    if (connecte) {
      if (mounted) {
        if (email == kAdminEmail) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => AdminPage(
                  users: List.from(listeUtilisateursLocaux))),
                  (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const VideoListPage(estAdmin: false)),
                  (route) => false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou mot de passe incorrect."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _motDePasseOublie() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez votre email d'abord."), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email de réinitialisation envoyé !"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur. Vérifiez votre email."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _afficherOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add, color: kRose),
              title: const Text("Créer un compte"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const InscriptionPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: kRose),
              title: const Text("Retour à l'accueil"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: kRose),
            onPressed: _afficherOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_open, size: 70, color: kRose),
            const SizedBox(height: 10),
            const Text("Connexion",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 5),
            const Text("Bienvenue à nouveau sur votre application",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 30),

            // Email
            TextField(
              controller: _emailController,
              onChanged: _validerEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
              decoration: champStyle("Email", Icons.email, errorText: _emailErreur),
            ),
            const SizedBox(height: 15),

            // Mot de passe
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              onChanged: _validerPassword,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _connecter(),
              decoration: champStyle("Mot de passe", Icons.lock,
                errorText: _passwordErreur,
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: kRose),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            if (_passwordErreur == null)
              const Padding(padding: EdgeInsets.only(left: 15, top: 4),
                  child: Align(alignment: Alignment.centerLeft,
                      child: Text("Minimum 6 caractères",
                          style: TextStyle(fontSize: 12, color: Colors.grey)))),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _motDePasseOublie,
                child: const Text("Mot de passe oublié ?", style: TextStyle(color: kRose)),
              ),
            ),
            const SizedBox(height: 10),
            _loading
                ? const CircularProgressIndicator(color: kRose)
                : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _connecter,
                child: const Text("Se connecter",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Pas de compte ? ", style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const InscriptionPage())),
                  child: const Text("Inscrivez vous",
                      style: TextStyle(color: kRose, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}