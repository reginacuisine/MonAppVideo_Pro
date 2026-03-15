import 'package:flutter/material.dart';
import '../constants.dart';
import '../storage.dart';
import 'lecteur_video_page.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});
  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
      ),
      body: videosFavoris.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Aucun favori pour l'instant",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            const Text("Appuie sur ❤️ pour ajouter une vidéo",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: videosFavoris.length,
        itemBuilder: (context, index) {
          final video = videosFavoris[index];
          final isLocal = video["type"] == "local";
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: kRosePale,
              child: Icon(
                isLocal ? Icons.video_file : Icons.link,
                color: kRose,
              ),
            ),
            title: Text(video["titre"] ?? "Vidéo",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: kRose),
                  onPressed: () async {
                    await supprimerFavori(video["source"]!);
                    setState(() {});
                  },
                ),
                if (isLocal)
                  const Icon(Icons.play_arrow, color: kRose),
              ],
            ),
            onTap: () {
              if (isLocal) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => LecteurVideoPage(
                      source: video["source"]!,
                      estLocal: true,
                      titre: video["titre"] ?? "Vidéo"),
                ));
              }
            },
          );
        },
      ),
    );
  }
}