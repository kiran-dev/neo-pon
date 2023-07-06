import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/chat_message.dart';
import '../../../organizers/party_manager.dart';

class PartyChat extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;

  PartyChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: false);
    return OrientationBuilder(
        builder: (context, o) {
          Orientation orientation = MediaQuery.of(context).orientation;
          return Container(
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28)
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              reverse: true,
              child: Column(
                children: [
                  for(ChatMessage cM in partyManager.chatMessages)
                    Row(
                      mainAxisAlignment: cM.senderID == auth.currentUser!.uid
                          ? MainAxisAlignment.start : MainAxisAlignment.end,
                      children: [

                        Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            width: 177,
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(7)
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).shadowColor,
                                      // borderRadius: BorderRadius.circular(28)
                                  ),
                                  padding: const EdgeInsets.all(7),
                                  child: Center(
                                    child: Text("D",
                                      style: GoogleFonts.voltaire(
                                          textStyle: Theme.of(context).textTheme.labelMedium
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 11,),
                                Text(cM.message,
                                  style: GoogleFonts.voltaire(
                                      textStyle: Theme.of(context).textTheme.labelMedium
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    )
                ],
              ),
            ),
          );
        }
    );
  }

}