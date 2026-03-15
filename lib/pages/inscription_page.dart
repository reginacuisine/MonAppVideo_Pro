import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../storage.dart';
import 'connexion_page.dart';
import 'login_page.dart';
import 'video_list_page.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});
  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // FocusNodes pour navigation clavier
  final _prenomFocus = FocusNode();
  final _telephoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _loading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _nomErreur;
  String? _prenomErreur;
  String? _emailErreur;
  String? _passwordErreur;
  String? _confirmPasswordErreur;
  String? _telephoneErreur;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _prenomFocus.dispose();
    _telephoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _valider() {
    setState(() {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      final telephone = _telephoneController.text.trim();
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
      final telephoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

      _nomErreur = _nomController.text.trim().isEmpty ? "Le nom est requis" : null;
      _prenomErreur = _prenomController.text.trim().isEmpty ? "Le prénom est requis" : null;
      _telephoneErreur = telephone.isEmpty
          ? null
          : (!telephoneRegex.hasMatch(telephone) ? "Numéro invalide" : null);
      _emailErreur = emailRegex.hasMatch(email) ? null : "Email invalide (ex: nom@gmail.com)";
      _passwordErreur = password.length >= 6 ? null : "Minimum 6 caractères";
      _confirmPasswordErreur = password == confirmPassword ? null : "Les mots de passe ne correspondent pas";
    });
  }

  bool get _formulaireValide =>
      _nomErreur == null &&
          _prenomErreur == null &&
          _emailErreur == null &&
          _passwordErreur == null &&
          _confirmPasswordErreur == null &&
          _telephoneErreur == null;

  Future<void> _creerCompte() async {
    _valider();
    if (!_formulaireValide) return;
    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Essayer Firebase avec timeout
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password,
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    // Toujours créer compte local
    final localOk = await creerCompteLocal(email, password);

    if (!localOk && !listeUtilisateursLocaux.contains(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cet email est déjà utilisé."),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const VideoListPage(estAdmin: false)),
              (route) => false);
    }
    if (mounted) setState(() => _loading = false);
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
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.login, color: kRose),
              title: const Text("Se connecter"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const ConnexionPage()));
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
          onPressed: () => Navigator.pop(context),
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
            const SizedBox(height: 10),
            const Icon(Icons.person_add, size: 70, color: kRose),
            const SizedBox(height: 10),
            const Text("Créer un compte",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 5),
            const Text("Bienvenue sur votre application",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 25),

            // Nom
            TextField(
              controller: _nomController,
              onChanged: (_) => _valider(),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_prenomFocus),
              decoration: champStyle("Nom *", Icons.person, errorText: _nomErreur),
            ),
            const SizedBox(height: 15),

            // Prénom
            TextField(
              controller: _prenomController,
              focusNode: _prenomFocus,
              onChanged: (_) => _valider(),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_telephoneFocus),
              decoration: champStyle("Prénom *", Icons.person_outline, errorText: _prenomErreur),
            ),
            const SizedBox(height: 15),

            // Téléphone
            TextField(
              controller: _telephoneController,
              focusNode: _telephoneFocus,
              onChanged: (_) => _valider(),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
              decoration: champStyle("Téléphone (optionnel)", Icons.phone, errorText: _telephoneErreur),
            ),
            const SizedBox(height: 4),
            const Align(alignment: Alignment.centerLeft,
                child: Padding(padding: EdgeInsets.only(left: 15),
                    child: Text("Ex: +22670000000", style: TextStyle(fontSize: 12, color: Colors.grey)))),
            const SizedBox(height: 15),

            // Email
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              onChanged: (_) => _valider(),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
              decoration: champStyle("Email *", Icons.email, errorText: _emailErreur),
            ),
            if (_emailErreur == null)
              const Padding(padding: EdgeInsets.only(left: 15, top: 4),
                  child: Align(alignment: Alignment.centerLeft,
                      child: Text("Ex: nom@gmail.com", style: TextStyle(fontSize: 12, color: Colors.grey)))),
            const SizedBox(height: 15),

            // Mot de passe
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              onChanged: (_) => _valider(),
              obscureText: !_showPassword,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
              decoration: champStyle("Mot de passe *", Icons.lock,
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
                      child: Text("Minimum 6 caractères", style: TextStyle(fontSize: 12, color: Colors.grey)))),
            const SizedBox(height: 15),

            // Confirmer mot de passe
            TextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              onChanged: (_) => _valider(),
              obscureText: !_showConfirmPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _creerCompte(),
              decoration: champStyle("Confirmer le mot de passe *", Icons.lock_outline,
                errorText: _confirmPasswordErreur,
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility, color: kRose),
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _loading
                ? const CircularProgressIndicator(color: kRose)
                : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _creerCompte,
                child: const Text("Créer mon compte",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Déjà un compte ? ", style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const ConnexionPage())),
                  child: const Text("Connectez-vous",
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