import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../constants.dart';
import '../storage.dart';

class LecteurVideoPage extends StatefulWidget {
  final String source;
  final bool estLocal;
  final String titre;

  const LecteurVideoPage({
    super.key,
    required this.source,
    required this.estLocal,
    required this.titre,
  });

  @override
  State<LecteurVideoPage> createState() => _LecteurVideoPageState();
}

class _LecteurVideoPageState extends State<LecteurVideoPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _chargement = true;
  bool _afficherIndicateur = false;
  bool _estAvance = true; // true = avance, false = recule

  @override
  void initState() {
    super.initState();
    ajouterHistorique(widget.titre, widget.source, widget.estLocal ? "local" : "url");
    _initialiserLecteur();
  }

  Future<void> _initialiserLecteur() async {
    if (widget.estLocal) {
      _videoController = VideoPlayerController.asset(widget.source);
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.source));
    }

    await _videoController.initialize();
    if (!mounted) return;

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      materialProgressColors: ChewieProgressColors(
        playedColor: kRose,
        handleColor: kRose,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white70,
      ),
      aspectRatio: _videoController.value.aspectRatio,
      placeholder: const Center(child: CircularProgressIndicator(color: kRose)),
    );

    setState(() => _chargement = false);
  }

  void _avancer() {
    final position = _videoController.value.position;
    final duree = _videoController.value.duration;
    final nouvelle = position + const Duration(seconds: 10);
    _videoController.seekTo(nouvelle > duree ? duree : nouvelle);
    setState(() {
      _estAvance = true;
      _afficherIndicateur = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _afficherIndicateur = false);
    });
  }

  void _reculer() {
    final position = _videoController.value.position;
    final nouvelle = position - const Duration(seconds: 10);
    _videoController.seekTo(nouvelle < Duration.zero ? Duration.zero : nouvelle);
    setState(() {
      _estAvance = false;
      _afficherIndicateur = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _afficherIndicateur = false);
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.titre,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: kRose),
            tooltip: "Ajouter aux favoris",
            onPressed: () async {
              await ajouterFavori(
                widget.titre, widget.source,
                widget.estLocal ? "local" : "url",
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("${widget.titre} ajouté aux favoris ❤️"),
                  backgroundColor: kRose,
                  duration: const Duration(seconds: 2),
                ));
              }
            },
          ),
        ],
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator(color: kRose))
          : _chewieController != null
          ? Stack(
        children: [
          Chewie(controller: _chewieController!),

          // Zone double tap GAUCHE → reculer
          Positioned(
            left: 0, top: 0, bottom: 0,
            width: MediaQuery.of(context).size.width / 2,
            child: GestureDetector(
              onDoubleTap: _reculer,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Zone double tap DROITE → avancer
          Positioned(
            right: 0, top: 0, bottom: 0,
            width: MediaQuery.of(context).size.width / 2,
            child: GestureDetector(
              onDoubleTap: _avancer,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Indicateur visuel au centre
          if (_afficherIndicateur)
            Center(
              child: AnimatedOpacity(
                opacity: _afficherIndicateur ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _estAvance
                            ? Icons.forward_10
                            : Icons.replay_10,
                        color: Colors.white, size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _estAvance ? "+10 sec" : "-10 sec",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      )
          : const Center(
          child: Text("Erreur de chargement",
              style: TextStyle(color: Colors.white))),
    );
  }
}