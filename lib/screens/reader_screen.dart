import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../models/manga.dart';
import '../models/volume.dart';
import '../organizers/app_manager.dart';

class ReaderScreen extends StatefulWidget {
  Chapter chapter;

  ReaderScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final Reference storageRef = FirebaseStorage.instance.ref();
  PageController pageController = PageController(initialPage: 0);
  List<ImageResource> chapterPages = [];
  bool isFetching = true;

  Future<void> loadChapter() async {
    try {
      Reference chapterRef = storageRef.child(widget.chapter.ref);
      final listResult = await chapterRef.listAll();
      setState(() {
        chapterPages = listResult.items.map((e) => ImageResource(ref: e, cacheLocation: e.fullPath)).toList();
        isFetching = false;
      });
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    loadChapter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return Container(
        color: Theme.of(context).canvasColor,
        child: const Center(
          child: Text("Fetching Resources ..."),
        ),
      );
    }

    return PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapterPages.length,
      dragStartBehavior: DragStartBehavior.down,
      controller: pageController,
      itemBuilder: (BuildContext context, int itemIndex) {
        int pgNum = itemIndex + 1;
        bool hasNext = pgNum < chapterPages.length;
        bool hasPrev = pgNum > 1;
        return ChapterPage(
          resource: chapterPages[itemIndex],
          pageNumber: pgNum,
          totalPages: chapterPages.length,
          goNext: () {
            pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeIn);
            if (hasNext) chapterPages[pgNum + 1].getImage();
          },
          goPrevious: () {
            if (hasPrev) {
              pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeIn);
            }
          }
        );
      },
      // physics: BouncingScrollPhysics(),
    );
  }
}


class ChapterPage extends StatelessWidget {
  final ImageResource resource;
  final int pageNumber;
  final int totalPages;
  final Function goNext;
  final Function goPrevious;
  const ChapterPage({Key? key, required this.resource, required this.pageNumber, required this.totalPages, required this.goNext, required this.goPrevious}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<FileImage?>(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return Center(child: Text("..."));
              }

              if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.data != null) {
                return Center(
                  child: PhotoView(imageProvider: snapshot.data, enablePanAlways: true),
                );
              }

              return Center(child: Text('Fetching...'));
            },
            future: resource.getImage(),
          ),
          Positioned(
              left: 28,
              bottom: 7,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Theme.of(context).canvasColor,
                ),
                child: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.keyboard_arrow_left, size: 28,),
                  onPressed: () => goPrevious(),
                ),
              )
          ),
          Positioned(
              bottom: 17,
              child: GestureDetector(
                onTap: () {
                  if(Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                    appManager.setCurrentScreen(Screens.mangaScreen);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).canvasColor,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.highlight_remove, size: 23),
                      const SizedBox(width: 7,),
                      Text("$pageNumber / $totalPages", style: Theme.of(context).textTheme.titleMedium,),
                    ],
                  )
                ),
              )
          ),
          Positioned(
              right: 28,
              bottom: 7,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Theme.of(context).canvasColor,
                ),
                child: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.keyboard_arrow_right, size: 28),
                  onPressed: () => goNext(),
                ),
              )
          ),
        ]
    );
  }
}