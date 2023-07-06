import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/titil.dart';
import '../components/player/components/keyboard.dart';
import '../organizers/app_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  final titlesRef = FirebaseFirestore.instance.collection('titles')
      .withConverter<Titil>(
    fromFirestore: (snapshot, _) => Titil.fromJson(snapshot.data()!, ID: snapshot.id),
    toFirestore: (title, _) => title.toJson(),
  );

  final TextEditingController searchTextController = TextEditingController();
  bool titlesFetched = false;
  bool showKeyboard = false;
  List<Titil> titlesList = [];
  bool searchFieldChanged = false;
  bool hasSearchText = false;

  Future<void> fetchTitles() async {
    // setState(() => isFetching = true);
    List<QueryDocumentSnapshot<Titil>> titles = await titlesRef
        .get().then((snapshot) => snapshot.docs);
    if (titles.isNotEmpty) {
      List<Titil> listTitles = titles.map((e) => e.data()).toList();
      setState(() {
        titlesList = listTitles;
      });
    }
    setState(() => titlesFetched = true);
  }

  @override
  void initState() {
    fetchTitles();
    searchTextController.addListener(() {
      setState(() {
        searchFieldChanged = true;
      });
    });
    super.initState();
  }

  Widget buildTopSpace() {
    return Visibility(
      visible: !showKeyboard,
      child: const Expanded(
        flex: 1,
        child: SizedBox(),
      )
    );
  }

  Widget buildSearchField() {
    return Visibility(
      visible: showKeyboard,
      child: Align(
        // bottom: 14,
        // right: 214,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 117,
            width: 256,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.bounceIn,
                onEnd: () {
                  setState(() {
                    searchFieldChanged = false;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: Theme.of(context).shadowColor,
                      style: BorderStyle.solid,
                      width: searchFieldChanged ? 4 : 2
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: IconButton(
                          // decoration: ShapeDecoration(
                          //     color: Theme.of(context).shadowColor,
                          //     shape: const CircleBorder()
                          // ),
                          // width: 37,
                          // height: 37,
                          onPressed: () {
                            setState(() {
                              showKeyboard = false;
                            });
                          },
                          iconSize: 28,
                          icon: const Icon(Icons.search_off_rounded,)
                      ),
                    ),
                    SizedBox(
                      width: 177,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        style: GoogleFonts.voltaire(fontSize: 21, fontWeight: FontWeight.w700),
                        controller: searchTextController,
                        readOnly: true,
                        autofocus: true,
                        cursorColor: Theme.of(context).primaryColor,
                        expands: false,
                        onTap: () {
                          setState(() {
                            searchFieldChanged = true;
                          });
                        },
                        selectionControls: EmptyTextSelectionControls(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }

  Widget buildTitlesView() {
    if (!titlesFetched) {
      return Center(
        child: Text("Fetching Titles...",
          style: GoogleFonts.voltaire(
            textStyle: Theme.of(context).textTheme.bodyMedium
          ),
        ),
      );
    }

    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    Iterable<Titil> searchedTitils = titlesList.where((t) {
      if (searchTextController.text.isEmpty) return true;
      if (t.name.toLowerCase().contains(searchTextController.text.toLowerCase())) return true;
      return false;
    });
    double scrollOffset = MediaQuery.of(context).size.width / 4.7;
    if (searchedTitils.length < 3) {
      scrollOffset = scrollOffset / 2;
    } else if (searchedTitils.length < 2) {
      scrollOffset = 0;
    } else if (searchedTitils.isEmpty) {
      scrollOffset = scrollOffset / 10;
    }


    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              scrollDirection: Axis.horizontal,
              controller: ScrollController(
                  initialScrollOffset: scrollOffset,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const Expanded(flex: 1, child: SizedBox(),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width / 4.7,),
                      if (searchedTitils.isEmpty)
                        const Center(
                          child: Text("No titles matching the search."),
                        ),
                      for (Titil t in searchedTitils)
                        GestureDetector(
                          onTap: () {
                            appManager.setCurrentTitle(t);
                            appManager.setCurrentScreen(Screens.animeScreen);
                            Navigator.pushNamed(context, Screens.animeScreen.route);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(17),
                            child: Column(
                              children: [
                                Container(color: Colors.blueGrey, width: 110, height: 170,),
                                SizedBox(height: 7,),
                                Text(t.name)
                              ],
                            ),
                          ),
                        ),
                      SizedBox(width: MediaQuery.of(context).size.width / 4.7,),
                    ],
                  ),
                  const Expanded(flex: 1, child: SizedBox(),)
                ],
              )
          ),
          buildSearchField(),
        ],

      ),
    );
  }

  Widget buildSpaceOrKeyboard() {
    return Expanded(
      flex: 2,
      child: Container(
          child: showKeyboard
          ? Align(
            alignment: Alignment.center,
            child: Keyboard(
              textController: searchTextController,
              allowEmoji: false,
              allowNewLine: false,
            ),
          )
          : Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    showKeyboard = true;
                  });
                },
                iconSize: 28,
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.search_rounded,),
              ),
            ),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Theme.of(context).canvasColor,
      child: OrientationBuilder(
        builder: (context, o) {
          Orientation orientation = MediaQuery.of(context).orientation;
          if (orientation == Orientation.landscape) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTopSpace(),
                buildTitlesView(),
                buildSpaceOrKeyboard()
              ],
            );
          }

          return Column(
            children: [
              buildTopSpace(),
              buildTitlesView(),
              buildSpaceOrKeyboard(),
            ],
          );
        }
      ),
    );
  }
}


class InventoryPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      child: OrientationBuilder(builder: (context, o) {
        Orientation orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          return Row(
            children: [
              // ArcPanel(currentArc: widget.currentArc, width: 400),
              // ArcEpisodes(episodesList: episodesList, setPlayerScreen: widget.setPlayerScreen),
            ],
          );
        }

        return Column(
          children: [
            // ArcPanel(currentArc: widget.currentArc, height: 250),
            // ArcEpisodes(episodesList: episodesList, setPlayerScreen: widget.setPlayerScreen),
          ],
        );
      })
    );
  }

}