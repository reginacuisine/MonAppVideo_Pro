import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

List<String> listeUtilisateursLocaux = [];
List<Map<String, String>> videosAjoutees = [];
List<Map<String, String>> historiqueVideo = [];

Future<void> sauvegarderUtilisateurs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('utilisateurs', listeUtilisateursLocaux);
}

Future<void> chargerUtilisateurs() async {
  final prefs = await SharedPreferences.getInstance();
  listeUtilisateursLocaux = prefs.getStringList('utilisateurs') ?? [];
}

Future<void> sauvegarderVideos() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = videosAjoutees.map((v) => jsonEncode(v)).toList();
  await prefs.setStringList('videos_ajoutees', liste);
}

Future<void> chargerVideos() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = prefs.getStringList('videos_ajoutees') ?? [];
  videosAjoutees = liste.map((v) => Map<String, String>.from(jsonDecode(v))).toList();
}

Future<void> ajouterHistorique(String titre, String source, String type) async {
  final entree = {
    "titre": titre,
    "source": source,
    "type": type,
    "date": DateTime.now().toIso8601String(),
  };
  historiqueVideo.removeWhere((v) => v["source"] == source);
  historiqueVideo.insert(0, entree);
  if (historiqueVideo.length > 50) historiqueVideo = historiqueVideo.sublist(0, 50);
  await sauvegarderHistorique();
}

Future<void> sauvegarderHistorique() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = historiqueVideo.map((v) => jsonEncode(v)).toList();
  await prefs.setStringList('historique_video', liste);
}

Future<void> chargerHistorique() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = prefs.getStringList('historique_video') ?? [];
  historiqueVideo = liste.map((v) => Map<String, String>.from(jsonDecode(v))).toList();
}

Future<void> viderHistorique() async {
  historiqueVideo = [];
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('historique_video');
}

List<Map<String, String>> videosFavoris = [];

Future<void> ajouterFavori(String titre, String source, String type) async {
  final dejaDedans = videosFavoris.any((v) => v["source"] == source);
  if (!dejaDedans) {
    videosFavoris.add({"titre": titre, "source": source, "type": type});
    await sauvegarderFavoris();
  }
}

Future<void> supprimerFavori(String source) async {
  videosFavoris.removeWhere((v) => v["source"] == source);
  await sauvegarderFavoris();
}

bool estFavori(String source) {
  return videosFavoris.any((v) => v["source"] == source);
}

Future<void> sauvegarderFavoris() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = videosFavoris.map((v) => jsonEncode(v)).toList();
  await prefs.setStringList('favoris', liste);
}

Future<void> chargerFavoris() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = prefs.getStringList('favoris') ?? [];
  videosFavoris = liste.map((v) => Map<String, String>.from(jsonDecode(v))).toList();
}

// ========== COMPTES LOCAUX ==========
List<Map<String, String>> comptesLocaux = [];

Future<void> sauvegarderComptesLocaux() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = comptesLocaux.map((c) => jsonEncode(c)).toList();
  await prefs.setStringList('comptes_locaux', liste);
}

Future<void> chargerComptesLocaux() async {
  final prefs = await SharedPreferences.getInstance();
  final liste = prefs.getStringList('comptes_locaux') ?? [];
  comptesLocaux = liste.map((c) => Map<String, String>.from(jsonDecode(c))).toList();
}

Future<bool> creerCompteLocal(String email, String password) async {
  final dejaDedans = comptesLocaux.any((c) => c["email"] == email);
  if (dejaDedans) return false; // email déjà utilisé
  comptesLocaux.add({"email": email, "password": password});
  if (!listeUtilisateursLocaux.contains(email)) {
    listeUtilisateursLocaux.add(email);
  }
  await sauvegarderComptesLocaux();
  await sauvegarderUtilisateurs();
  return true;
}

bool connecterCompteLocal(String email, String password) {
  return comptesLocaux.any((c) => c["email"] == email && c["password"] == password);
}