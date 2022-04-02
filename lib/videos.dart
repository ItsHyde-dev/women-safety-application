import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class Videos extends StatelessWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: VideosStateful());
  }
}

class VideosStateful extends StatefulWidget {
  const VideosStateful({Key? key}) : super(key: key);

  @override
  _VideosStatefulState createState() => _VideosStatefulState();
}

class _VideosStatefulState extends State<VideosStateful> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  final List<String> vidsLink = [
    'https://youtu.be/KVpxP3ZZtAc',
    'https://youtu.be/k9Jn0eP-ZVg',
    'https://youtu.be/T7aNSRoDCmg',
    'https://www.youtube.com/watch?v=k9Jn0eP-ZVg',
    'https://www.youtube.com/watch?v=-V4vEyhWDZ0'
  ];

  final List<String> titles = [
    '5 Self-Defense Moves Every Woman Should Know | HER Network',
    'SELF DEFENSE MOVES EVERY WOMAN SHOULD KNOW',
    '7 Self-Defense Techniques for Women from Professionals',
    'SELF DEFENSE MOVES EVERY WOMAN SHOULD KNOW',
    '5 Choke Hold Defenses Women MUST Know | Self Defense | Aja Dang'
  ];

  String getId(String videoLink) {
    try {
      String videoID = YoutubePlayer.convertUrlToId(videoLink)!;
      return (videoID);
    } on Exception catch (exception) {
      print(exception);
      return '';
    } catch (error) {
      print(error);
      return '';
    }
  }

  bool selected = false;
  int counter = 0;

  Widget VideoListPage() {
    return Scaffold(
        body: Container(
            color: Colors.black,
            child: ListView.builder(
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xff27e1e6), Color(0xffaa64ea)],
                            ),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: InkWell(
                                  child: Stack(
                                    children: <Widget>[
                                      // Stroked text as border.
                                      Text(
                                        titles[index],
                                        style: TextStyle(
                                          fontSize: 20,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 2
                                            ..color =
                                                Colors.black87.withAlpha(100),
                                        ),
                                      ),
                                      // Solid text as fill.
                                      Text(
                                        titles[index],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Text(titles[index],
                                  //     style: TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 18,
                                  //       fontFamily: "Inter",
                                  //       fontWeight: FontWeight.w600,

                                  //     )),
                                  onTap: () {
                                    setState(() {
                                      counter = index;
                                      selected = true;
                                    });
                                  }))));
                })));
  }

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return VideoListPage();
    }
    return player(getId(vidsLink[counter]));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}

Widget player(String id) {
  return YoutubePlayer(
    controller: YoutubePlayerController(
      initialVideoId: id, //Add videoID.
      flags: YoutubePlayerFlags(
        hideControls: false,
        controlsVisibleAtStart: true,
        autoPlay: false,
        mute: false,
      ),
    ),
    showVideoProgressIndicator: true,
    progressIndicatorColor: Colors.red,
  );
}

//youtube player  widget
