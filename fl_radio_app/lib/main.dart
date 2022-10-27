import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _prepare();
  }

  // to load stream or catch errors
  Future<void> _prepare() async {
    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(
          // add your streaming link here
          "YOUR_STREAM_LINK")));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Radio Player"),
          backgroundColor: Colors.green,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.network(
                  "https://img.freepik.com/free-vector/hand-drawn-world-radio-day_23-2148803466.jpg?w=740&t=st=1666896725~exp=1666897325~hmac=a88e6834007cb635f7115a791a155c6fc79849f569967af6c7782a4b42e7a9c7"),

              // play pause button
              Center(
                child: PlayerButtons(_audioPlayer),
              ),

              // remove this Text after adding your streaming link
              const Center(
                child: Text("Add your Streaming Link first"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerButtons extends StatelessWidget {
  final AudioPlayer player;

  const PlayerButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
      ],
    );
  }
}
