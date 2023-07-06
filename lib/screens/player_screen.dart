import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/player/components/download_progress_indicator.dart';
import '../models/video_resource.dart';
import '../organizers/video_manager.dart';
import '../components/player/player.dart';

class PlayerScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> pageNavigationKey;
  const PlayerScreen({Key? key, required this.pageNavigationKey}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<PlayerScreen> {

  @override
  Widget build(BuildContext context) {
    VideoManager videoManager = Provider.of<VideoManager>(context, listen: true);
    VideoResource? currentVideo = videoManager.currentVideo;

    if (currentVideo?.isDownloaded ?? false) {
      return Player(
        pageNavigationKey: widget.pageNavigationKey,
      );
    }

    if (currentVideo == null || currentVideo!.fileStream == null || currentVideo!.downloadProgress == null) {
      return Center(
        child: Text("...", style: Theme.of(context).textTheme.displayLarge,),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      color: Theme.of(context).canvasColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DownloadProgressIndicator(progress: currentVideo!.downloadProgress,),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(28)
                  ),
                  child: IconButton(
                    iconSize: 28,
                    highlightColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).shadowColor,
                    onPressed: () {
                      if(widget.pageNavigationKey.currentState!.canPop()) {
                        widget.pageNavigationKey.currentState!.pop();
                      }
                      videoManager.notifyComplete();
                    }, icon: Icon(Icons.keyboard_arrow_left)
                  ),
                ),
                const SizedBox(width: 10,),
                SizedBox(
                  width: 180,
                  child: Text(
                    "You'll get notified, once the resource is downloaded.",
                    maxLines: 2,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ]
        )
      ),
    );
  }
}

