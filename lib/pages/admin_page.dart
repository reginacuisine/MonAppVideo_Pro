import 'package:flutter/material.dart';
import '../constants.dart';
import '../storage.dart';
import 'login_page.dart';
import 'video_list_page.dart';

class AdminPage extends StatefulWidget {
  final List<String> users;
  const AdminPage({super.key, required this.users});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late List<String> _users;
  late List<Map<String, String>> _videos;
  late TabController _tabController;
  final _titreController = TextEditingController();
  final _urlController = TextEditingController();
  String _typeVideo = "youtube";

  @override
  void initState() {
    super.initState();
    _users = List.from(widget.users);
    _videos = List.from(videosAjoutees);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titreController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _supprimerVideo(int index) async {
    final titre = _videos[index]["titre"]!;
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer la vidéo"),
        content: Text("Voulez-vous supprimer\n\"$titre\" ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirmer == true) {
      setState(() => _videos.removeAt(index));
      videosAjoutees.removeAt(index);
      await sauvegarderVideos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("\"$titre\" supprimée"), backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  void _ajouterVideo() {
    _titreController.clear();
    _urlController.clear();
    _typeVideo = "youtube";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 25, right: 25, top: 25,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Ajouter une vidéo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => _typeVideo = "youtube"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _typeVideo == "youtube" ? kRose : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle,
                                color: _typeVideo == "youtube" ? Colors.white : Colors.grey),
                            const SizedBox(width: 5),
                            Text("YouTube", style: TextStyle(
                                color: _typeVideo == "youtube" ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => _typeVideo = "url"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _typeVideo == "url" ? kRose : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.link,
                                color: _typeVideo == "url" ? Colors.white : Colors.grey),
                            const SizedBox(width: 5),
                            Text("URL", style: TextStyle(
                                color: _typeVideo == "url" ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _titreController,
                decoration: InputDecoration(
                  hintText: "Titre de la vidéo",
                  prefixIcon: const Icon(Icons.title, color: kRose),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kRose, width: 1.5)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: _typeVideo == "youtube" ? "https://youtu.be/..." : "https://example.com/video.mp4",
                  prefixIcon: const Icon(Icons.link, color: kRose),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kRose, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_titreController.text.trim().isEmpty ||
                        _urlController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Remplissez tous les champs."),
                            backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    final nouvelle = {
                      "titre": _titreController.text.trim(),
                      "url": _urlController.text.trim(),
                      "type": _typeVideo,
                    };
                    videosAjoutees.add(nouvelle);
                    await sauvegarderVideos();
                    if (mounted) Navigator.pop(context);
                    setState(() => _videos = List.from(videosAjoutees));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("\"${nouvelle["titre"]}\" ajoutée !"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  child: const Text("Ajouter",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Admin"),
        backgroundColor: kRose,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.people), text: "Utilisateurs (${_users.length})"),
            Tab(icon: const Icon(Icons.video_library), text: "Vidéos (${_videos.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: kRosePale,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: kRose.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: kRose, size: 30),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total utilisateurs",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("${_users.length} utilisateur(s)",
                            style: const TextStyle(fontSize: 20,
                                fontWeight: FontWeight.bold, color: kRose)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _users.isEmpty
                    ? const Center(child: Text("Aucun utilisateur.",
                    style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final email = _users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kRosePale,
                          child: const Icon(Icons.person, color: kRose),
                        ),
                        title: Text(email,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text("✅ Actif",
                            style: TextStyle(color: Colors.green, fontSize: 12)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const VideoListPage(estAdmin: true))),
                    icon: const Icon(Icons.video_library),
                    label: const Text("Voir les Vidéos", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Expanded(
                child: _videos.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text("Aucune vidéo ajoutée.",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _ajouterVideo,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une vidéo"),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    final video = _videos[index];
                    final isYoutube = video["type"] == "youtube";
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isYoutube
                              ? Colors.red.withOpacity(0.1) : kRosePale,
                          child: Icon(isYoutube ? Icons.play_circle : Icons.link,
                              color: isYoutube ? Colors.red : kRose),
                        ),
                        title: Text(video["titre"]!,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(isYoutube ? "YouTube" : "Streaming",
                            style: TextStyle(
                                color: isYoutube ? Colors.red : kRose, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _supprimerVideo(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _ajouterVideo,
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter une vidéo", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
