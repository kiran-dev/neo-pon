import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../organizers/party_manager.dart';

class PartyView extends StatelessWidget {
  List<String> friends = ["Aishwarya", "Karthik", "Kirani", "Kiran"];

  PartyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PartyManager partyManager = Provider.of<PartyManager>(context, listen: true);

    return Container(
      width: 328,
      height: 256,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(7),
                    color: Theme.of(context).canvasColor
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 14,),
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).shadowColor
                        ),
                        width: 37,
                        height: 37,
                        // constraints: BoxConstraints.expand(),
                      ),
                      const SizedBox(width: 7,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Me",
                            style: GoogleFonts.voltaire(
                              textStyle: Theme.of(context).textTheme.headlineSmall,
                              color: Theme.of(context).primaryColor
                            ),
                          ),
                          Text("@ brave_tagger",
                            style: GoogleFonts.voltaire(
                              textStyle: Theme.of(context).textTheme.labelLarge,
                              color: Theme.of(context).primaryColor
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 37, height: 37,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).shadowColor,
                                  borderRadius: BorderRadius.circular(37)
                              ),
                              child: Center(child: Text("1"),),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 14,),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 5,
                  child: Container(
                    color: Theme.of(context).shadowColor,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 7,),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).shadowColor
                                ),
                                width: 37,
                                height: 37,
                                // constraints: BoxConstraints.expand(),
                              ),
                              const SizedBox(width: 7,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name",
                                    style: GoogleFonts.voltaire(
                                      textStyle: Theme.of(context).textTheme.headlineSmall
                                    ),
                                  ),
                                  Text("@ $index",
                                    style: GoogleFonts.voltaire(
                                        textStyle: Theme.of(context).textTheme.labelLarge
                                    ),
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              Container(
                                child: Text("Invite",
                                  style: GoogleFonts.voltaire(
                                      textStyle: Theme.of(context).textTheme.bodySmall
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7,),
                            ],
                          ),
                        );
                      }),
                  )
              )
            ],
          ),
          Positioned(
            bottom: 7,
            child: GestureDetector(
              onTap: () {
                partyManager.createParty([]);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(14)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Text("Start Party",
                  style: GoogleFonts.voltaire(
                      textStyle: Theme.of(context).textTheme.displaySmall,
                      color: Theme.of(context).primaryColor,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                  ),

                ),
              )
          ),)
        ],
      ),
    );
  }

}