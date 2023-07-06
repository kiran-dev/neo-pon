import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../components/keyboard.dart';
import '../components/now_playing.dart';
import '../components/party_chat.dart';
import '../components/video_controls.dart';
import '../../../models/chat_message.dart';
import '../../../organizers/party_manager.dart';
import '../../../organizers/video_manager.dart';

class PartyControls extends StatefulWidget {
  const PartyControls({Key? key}) : super(key: key);

  @override
  State<PartyControls> createState() => _PartyControlsState();
}

class _PartyControlsState extends State<PartyControls> {
  bool showControls = false;
  bool showNowPlaying = false;
  bool showKeyboard = true;
  bool showChat = true;
  TextEditingController controller = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  ChatMessage? referenceMessage;

  Widget buildTextField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Theme.of(context).shadowColor,
      ),
      child: Container(
        color: Colors.greenAccent
      )
    );
  }

  List<Widget> buildPartyOptions() {
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    return [
      InkWell(
        onTap: () {
          if (!showChat) {
            setState(() {
              showChat = true;
              showNowPlaying = false;
            });
          } else if (controller.text.isNotEmpty) {
            partyManager.addMessage(ChatMessage(
                senderID: auth.currentUser!.uid,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                message: controller.text
            ));
          }
        },
        onLongPress: () {
          setState(() {
            showChat = false;
          });
        },
        child: Center(
          child: Icon(Icons.send_outlined,
            size: 37,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      const SizedBox(width: 14,),
      Material(
        color: Theme.of(context).shadowColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            setState(() {
              showChat = showNowPlaying;
              showNowPlaying = !showNowPlaying;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Center(
              child: Icon(Icons.local_play_outlined,
                size: 21,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 7,),
      Material(
        color: Theme.of(context).shadowColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            setState(() {
              showControls = false;
              showKeyboard = !showKeyboard;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Center(
              child: Icon(Icons.keyboard_alt_outlined,
                size: 21,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 7,),
      Material(
        color: Theme.of(context).shadowColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            setState(() {
              showKeyboard = false;
              showControls = !showControls;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Center(
              child: Icon(Icons.control_camera_outlined,
                size: 21,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),

    ];
  }

  @override
  Widget build(BuildContext context) {
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: false);
    if (videoManager.isRecording && (showKeyboard || showControls || showNowPlaying)) {
      setState(() {
        showKeyboard = false;
        showControls = false;
        showNowPlaying = false;
        showChat = true;
      });
    }

    return OrientationBuilder(
      builder: (context, o) {
        Orientation orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.portrait) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    if (showChat)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 256,
                          height: 328,
                          // height: 328,
                          child: PartyChat()
                        ),
                      ),
                    if (showNowPlaying)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 256,
                          child: NowPlaying(
                            orientation: orientation,
                            closeParty: partyManager.exitParty,
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 256,
                        child: Column(
                          children: [
                            if (showChat)
                              buildTextField(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: buildPartyOptions()
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
              const Expanded(
                flex: 3,
                child: SizedBox()
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Visibility(
                        visible: showKeyboard || showControls,
                        child: Align(
                          alignment: Alignment.center,
                          child: showKeyboard
                              ? Keyboard(textController: controller,)
                              : const VideoControls()
                        )
                    )
                  )
              )
            ],
          );
        }

        return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 7,),
              SizedBox(
                width: 256,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showNowPlaying)
                      Expanded(
                        flex: 1,
                        child: NowPlaying(
                            orientation: orientation,
                            closeParty: partyManager.exitParty
                        ),
                      ),
                    if (showChat)
                      Expanded(flex: 1,child: PartyChat(),),
                    if (!showChat && !showNowPlaying)
                      const Expanded(flex: 1,child: SizedBox(),),
                    if (showChat)
                      buildTextField(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: buildPartyOptions()
                    ),
                    const SizedBox(height: 4,),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              Visibility(
                visible: showKeyboard || showControls,
                child: showKeyboard
                    ? Keyboard(textController: controller,)
                    : const VideoControls()
              )
            ]
        );
      }
    );
  }
}
