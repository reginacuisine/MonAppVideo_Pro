import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';
import '../storage.dart';
import 'connexion_page.dart';
import 'lecteur_video_page.dart';
import 'historique_page.dart';
import 'favoris_page.dart';

class VideoListPage extends StatefulWidget {
  final bool estAdmin;
  const VideoListPage({super.key, this.estAdmin = false});
  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final _searchController = TextEditingController();
  String _recherche = "";
  bool _chargement = true;

  static const List<Map<String, dynamic>> videosLocales = [
    {"titre": "Clip Widbo", "path": "assets/ClipWidbo.mp4", "image": "assets/ClipWidbo.png", "couleur": Color(0xFFE91E8C)},
    {"titre": "Clip Natou", "path": "assets/ClipNatou.mp4", "image": "assets/ClipNatou.png", "couleur": Color(0xFF9C27B0)},
    {"titre": "Clip Privat", "path": "assets/ClipPrivat.mp4", "image": "assets/ClipPrivat.png", "couleur": Color(0xFFFF4DB8)},
    {"titre": "Clip Tanya", "path": "assets/ClipTanya.mp4", "image": "assets/ClipTanya.png", "couleur": Color(0xFFAD1457)},
    {"titre": "Tanya", "path": "assets/Tanya.mp4", "image": "assets/Tanya.png", "couleur": Color(0xFFFF4DB8)},
    {"titre": "9ETAPESPOURCREERUNEAPP", "path": "assets/9ETAPESPOURCREERUNEAPP.mp4", "image": "assets/9ETAPESPOURCREERUNEAPP.png", "couleur": Color(0xFFE91E8C)},
    {"titre": "ActiverWindows11avieen1minute", "path": "assets/ActiverWindows11avieen1minute.mp4", "image": "assets/ActiverWindows11avieen1minute.png", "couleur": Color(0xFFE91E8C)},
    {"titre": "CommentTrouverlaCledeWindows10ou11", "path": "assets/CommentTrouverlaCledeWindows10ou11.mp4", "image": "assets/CommentTrouverlaCledeWindows10ou11.png", "couleur": Color(0xFFE91E8C)},
    {"titre": "InstallerFlutterVSodeGitTutorielFlutterpourdebutants", "path": "assets/InstallerFlutterVSodeGitTutorielFlutterpourdebutants.mp4", "image": "assets/InstallerFlutterVSodeGitTutorielFlutterpourdebutants.png", "couleur": Color(0xFFE91E8C)},
    {"titre": "InstallerFluttersurWindows11en2025GuideCompletavecVSCodeAndroidSt", "path": "assets/InstallerFluttersurWindows11en2025GuideCompletavecVSCodeAndroidSt.mp4", "image": "assets/InstallerFluttersurWindows11en2025GuideCompletavecVSCodeAndroidSt.png", "couleur": Color(0xFFE91E8C)},
  ];

  static const List<Map<String, String>> youtubeVideos = [
    {"titre": "Tuto Flutter Animation", "url": "https://youtu.be/XYiP09ihsKA"},
    {"titre": "Procès Yé Yaké Camille", "url": "https://www.youtube.com/watch?v=n2r2zCpGrh0&list=PPSV"},
    {"titre": "Flutter Cours Complet", "url": "https://www.youtube.com/watch?v=Q5sdjwUZrV0"},
    {"titre": "Discours du Capitaine Ibrahim TRAORE au 1er Sommet de l'AES", "url": "https://www.youtube.com/watch?v=3V3YJX5wt8U"},
    {"titre": "Adresse du chef de l'Etat Cpt Ibrahim TRAORE aux forces vives de la nation", "url": "https://www.youtube.com/watch?v=8PIWkEkn-7I"},
    {"titre": "Bassolma Bazie (Burkina Faso) devant la 78e Assemblée générale des Nations unies", "url": "https://www.youtube.com/watch?v=wLbOhoKyYG0"},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _chargement = false);
    });
  }

  List<Map<String, dynamic>> get _localesFiltrees => videosLocales
      .where((v) => v["titre"].toLowerCase().contains(_recherche.toLowerCase())).toList();
  List<Map<String, String>> get _youtubeFiltres => youtubeVideos
      .where((v) => v["titre"]!.toLowerCase().contains(_recherche.toLowerCase())).toList();
  List<Map<String, String>> get _ajouteesFiltrees => videosAjoutees
      .where((v) => v["titre"]!.toLowerCase().contains(_recherche.toLowerCase())).toList();

  void _retour() {
    if (widget.estAdmin) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const ConnexionPage()), (route) => false);
    }
  }

  Widget _shimmerGrille() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _carteClip(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => LecteurVideoPage(
            source: video["path"], estLocal: true, titre: video["titre"]),
      )),
      onLongPress: () async {
        await ajouterFavori(video["titre"], video["path"], "local");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("${video["titre"]} ajouté aux favoris ❤️"),
            backgroundColor: kRose,
            duration: const Duration(seconds: 2),
          ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(
              color: (video["couleur"] as Color).withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                video["image"],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: video["couleur"]),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  ),
                ),
              ),
              const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
              ),
              Positioned(
                bottom: 10, left: 8, right: 8,
                child: Text(video["titre"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Badge favori
              Positioned(
                top: 8, right: 8,
                child: estFavori(video["path"])
                    ? const Icon(Icons.favorite, color: kRose, size: 20)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carteYoutube(Map<String, String> video) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        ),
        title: Text(video["titre"]!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: const Text("YouTube", style: TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.open_in_new, color: kRose),
        onTap: () async => await launchUrl(
            Uri.parse(video["url"]!), mode: LaunchMode.externalApplication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Galerie Vidéo"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: _retour),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: "Favoris",
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavorisPage()))
                .then((_) => setState(() {})),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Historique",
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistoriquePage())),
          ),
        ],
      ),
      body: Column(
        children: [
      // Bouton retour
      Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
      child: SizedBox(
        width: double.infinity, height: 48,
        child: ElevatedButton.icon(
          onPressed: _retour,
          style: ElevatedButton.styleFrom(
            backgroundColor: kRosePale, foregroundColor: kRose,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          icon: const Icon(Icons.arrow_back),
          label: Text(
            widget.estAdmin ? " Retour au Panel Admin" : " Retour à la connexion",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    ),
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _recherche = val),
              decoration: InputDecoration(
                hintText: "Rechercher une vidéo...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: kRose),
                suffixIcon: _recherche.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _recherche = "");
                  },
                ) : null,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: kRose, width: 1.5)),
              ),
            ),
          ),
          Expanded(
            child: _chargement
                ? ListView(children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text("🎬 Mes Clips",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              _shimmerGrille(),
            ])
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Clips en grille
                  if (_localesFiltrees.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Text("🎬 Mes Clips",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _localesFiltrees.length,
                      itemBuilder: (_, i) => _carteClip(_localesFiltrees[i]),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Section YouTube
                  if (_youtubeFiltres.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text("▶️ YouTube",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    ..._youtubeFiltres.map(_carteYoutube),
                  ],

                  // Section Vidéos Spéciales
                  if (_ajouteesFiltrees.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text("✨ Vidéos Spéciales",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    ..._ajouteesFiltrees.map((video) {
                      final isYoutube = video["type"] == "youtube";
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: isYoutube ? Colors.red : kRose,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                                isYoutube ? Icons.play_arrow : Icons.link,
                                color: Colors.white, size: 26),
                          ),
                          title: Text(video["titre"]!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          trailing: Icon(
                              isYoutube ? Icons.open_in_new : Icons.play_arrow,
                              color: kRose),
                          onTap: () async {
                            if (isYoutube) {
                              await launchUrl(Uri.parse(video["url"]!),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => LecteurVideoPage(
                                    source: video["url"]!, estLocal: false,
                                    titre: video["titre"]!),
                              ));
                            }
                          },
                        ),
                      );
                    }),
                  ],

                  // Aucun résultat
                  if (_localesFiltrees.isEmpty && _youtubeFiltres.isEmpty &&
                      _ajouteesFiltrees.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Column(children: [
                        const Icon(Icons.search_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("Aucune vidéo trouvée pour \"$_recherche\"",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ])),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
