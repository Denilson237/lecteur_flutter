import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer player = AudioPlayer();
  late ConcatenatingAudioSource playlist;
  bool playing = false;
  Duration duration = const Duration();
  Duration position = const Duration();

   List<Map<String, dynamic>> data = [
    {
      "id": 1,
      "title": "Problem",
      "artiste": "Ariana Grande",
      "image": "problem.jpg",
      "urlsong": "Problem.mp3"
    },
    {
      "id": 2,
      "title": "Bang Bang",
      "artiste": "Jessie G",
      "image": "bang.jpg",
      "urlsong": "Bang_bang.mp3"
    },
    {
      "id": 3,
      "title": "Dangerous Woman",
      "artiste": "Ariana Grande",
      "image": "un.jpg",
      "urlsong": "Dangerous_Woman.mp3"
    },
    {
      "id": 4,
      "title": "One Last Time",
      "artiste": "Selena",
      "image": "one.jpg",
      "urlsong": "One_Last_Time.mp3"
    },
  ];

  @override
  void initState() {
    super.initState();

    List<String> m = [
      'assets/song/Problem.mp3',
      'assets/song/b.mp3',
      'assets/song/d.mp3',
      'assets/song/One_Last_Time.mp3',
    ];

    // Créer une liste des sources audio à partir de la liste des chemins
    List<AudioSource> audioSources = [];
    for (String path in m) {
      audioSources.add(AudioSource.asset(path));
    }

    // Construire la playlist avec les sources audio
    playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: audioSources,
    );

    player.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);

    // Activer la boucle de playlist et le mode shuffle
   player.setLoopMode(LoopMode.all);  // Définir la boucle de playlist one (pour un), all(pour toute la playlist), off(pour annuler)
    //player.setShuffleModeEnabled(false); // Activer le mode aleatoire

    // Définir la vitesse de lecture et le volume
    player.setSpeed(1.0); // Deux fois plus rapide
    player.setVolume(1); // Volume réduit de moitier// a zero il y a pas de volume

    player.playbackEventStream.listen((event) {
      setState(() {
        duration = event.duration!;
        playing = player.playing;
      });
    });
    player.positionStream.listen((p){
      setState(() => position = p);
    });
    
    player.currentIndexStream.listen((even) {
      print("la chanson est terminee");
      index ++;
    });
  }
  
  int index = 3;
  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
     if (index >= data.length) {
      index = 0;
    } else if (index < 0) {
      index = data.length - 1;
    }

    var musique = data[index];
    return MaterialApp(
      title: "Application de musique",
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 85.0,
          title: const Text(
            "Densh Musique",
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue[900],
          centerTitle: true,
        ),
        backgroundColor: Colors.lightBlue[400],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                elevation: 10.0,
                child: SizedBox(
                  width: largeur / 1.3,
                  height: largeur / 1.15,
                  child: Image.asset(
                    'assets/images/${musique["image"]}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    musique["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    musique["artiste"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: largeur / 1.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${position.inSeconds} : ${position.inMilliseconds}",
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.blue[900]),
                        ),
                        Text(
                          "${duration.inSeconds} : ${duration.inMilliseconds}",
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.blue[900]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(

                    width: largeur / 1.135,
                    child: Slider(
                      min: 0.0,
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble(),
                onChanged: (double value) {
                  player.seek(Duration(seconds: value.toInt()));
                },
                     //activeColor: Colors.blue[900],
                      //inactiveColor: Colors.white,
                      //divisions: 100,
                      //label: position.round().toString(),
                     
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: largeur / 5,
                width: largeur,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                    icon:const Icon(Icons.skip_previous,
                    color: Colors.white,
                        size: 60.0),
                    onPressed: () {
                      _playPrevious();
                    },
                  ),
                    InkWell(
                onTap: () {
                  _togglePlayback();
                },
                child: Icon(
                  playing ? Icons.pause_circle : Icons.play_circle,
                  size: 70,
                  color: Colors.white,
                ),
              ),
                    IconButton(
                    icon: const Icon(Icons.skip_next,
                    color: Colors.white,
                        size: 60.0),
                    onPressed: () {
                      _playNext();
                    },
                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePlayback() async {
    if (playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  void _playNext() async {
    await player.seekToNext();
    index ++;
    await player.play();
  }

  void _playPrevious() async {
    
    await player.seekToPrevious();
    index --;
    await player.play();
    
  }
}
