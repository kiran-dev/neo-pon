import 'magnify_config.dart';
import 'save.dart';
import 'video_resource.dart';

enum VAction {
  PAUSE, PLAY, FORWARD, BACKWARD, MOVETO, STATUS,
  VOLUME, SPEED,
  MAGNIFY_ON, UPDATE_MAGNIFY, MAGNIFY_OFF,
  RECORDING_ON, SET_RECORDED, LOOP_RECORDED, DELETE_RECORDED, RECORDING_OFF,
  CHANGE_VIDEO
}

class VideoAction {
  int timestamp;
  String userID;
  VAction action;
  Duration? position;
  double? value;
  MagnifyConfig? magnifyConfig;
  VideoResource? videoResource;
  Save? recordedSave;

  VideoAction({
    this.value,
    required this.action,
    required this.timestamp,
    required this.userID,
    this.position,
    this.videoResource,
    this.magnifyConfig,
    this.recordedSave,
  });

  factory VideoAction.fromJson(Map<String, dynamic> json, { ID: "" }) {
    return VideoAction(
      action: json['action'],
      timestamp: json['timestamp'],
      userID: json['userID'],
      value: json['value'],
      position: json['duration'] == null ? null
          : Duration(
              minutes: json['duration']['m'],
              seconds: json['duration']['s'],
              milliseconds: json['duration']['ms']
            ),
      magnifyConfig: json['magnifyConfig'] == null ? null
          : MagnifyConfig.fromJson(json['magnifyConfig']),
      videoResource: json['videoResource'] == null ? null
          : VideoResource.fromJson(json['videoResource']),
      recordedSave: json['recordedSave'] == null ? null
          : Save.fromJson(json['recordedSave']),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> mainJson = {
      'action': action.name,
      'timestamp': timestamp,
      'userID': userID
    };

    if (position != null) {
      mainJson['position'] = {
        "m": position!.inMinutes,
        "s": position!.inSeconds - (position!.inMinutes * 60),
        "ms": position!.inMilliseconds - (position!.inSeconds * 1000),
      };
    }

    if (value != null) {
      mainJson['value'] = value!;
    }

    if (magnifyConfig != null) {
      mainJson['magnifyConfig'] = magnifyConfig!.toJson();
    }

    if (videoResource != null) {
      mainJson['videoResource'] = videoResource!.toJson();
    }

    if (recordedSave != null) {
      mainJson['recordedSave'] = recordedSave!.toJson();
    }

    return mainJson;
  }
}
