import 'package:flutter/material.dart';
import '../constants.dart';
import '../storage.dart';
import 'lecteur_video_page.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});
  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} à ${d.hour.toString().padLeft(2, '0')}h${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        actions: [
          if (historiqueVideo.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: "Vider l'historique",
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Vider l'historique ?"),
                    content: const Text("Toutes les vidéos regardées seront effacées."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false),
                          child: const Text("Annuler")),
                      TextButton(onPressed: () => Navigator.pop(context, true),
                          child: const Text("Vider", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await viderHistorique();
                  setState(() {});
                }
              },
            ),
        ],
      ),
      body: historiqueVideo.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Aucune vidéo regardée",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: historiqueVideo.length,
        itemBuilder: (context, index) {
          final video = historiqueVideo[index];
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
            subtitle: Text(_formatDate(video["date"] ?? ""),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.play_arrow, color: kRose),
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