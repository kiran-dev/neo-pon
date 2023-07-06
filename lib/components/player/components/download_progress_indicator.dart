import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum Mode { BAR, CIRCLE }

class DownloadProgressIndicator extends StatelessWidget {
  DownloadProgress? progress;
  Mode mode;

  DownloadProgressIndicator({Key? key, this.progress, this.mode = Mode.BAR }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (progress == null || progress!.totalSize == null) {
      return const Center(
        child: Text("..."),
      );
    }

    int downloaded = progress!.downloaded;
    int totalSize = progress!.totalSize! ?? 0;
    String downloadedMb = (downloaded / 1024 / 1024).toStringAsFixed(2);
    String totalSizeMb = (totalSize / 1024 / 1024).toStringAsFixed(2);

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).shadowColor, width: 4)
              ),
              width: 500.0,
              height: 50.0,
              child: LinearProgressIndicator(
                value: progress!.progress,
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).canvasColor,
              ),
            ),
            const SizedBox(height: 20.0),
            Text('Fetching resources...', style: TextStyle(color: Theme.of(context).primaryColor),),
            const SizedBox(height: 10.0),
            Text("$downloadedMb Mb of $totalSizeMb Mb")
          ],
        )
    );
  }
}
