import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/chat_message.dart';
import '../models/party_member.dart';
import '../models/video_resource.dart';
import '../models/video_action.dart';
import 'video_manager.dart';

enum PartyStatus { HOST, SECOND, MEMBER }

class PartyManager extends ChangeNotifier {
  static String dbURL = "https://neo-pon-default-rtdb.asia-southeast1.firebasedatabase.app";
  DatabaseReference partiesRef = FirebaseDatabase(databaseURL: dbURL).ref("parties");
  DatabaseReference usersRef = FirebaseDatabase(databaseURL: dbURL).ref("users");

  DatabaseReference? currentUserRef;
  DatabaseReference? currentPartyRef;
  DatabaseReference? membersRef;
  DatabaseReference? messagesRef;
  DatabaseReference? actionsRef;
  PartyStatus partyStatus = PartyStatus.MEMBER;

  String? hostID;
  VideoResource? currentVideoResource;
  List<PartyMember> partyMembers = [];
  List<VideoAction> videoActions = [];
  List<ChatMessage> chatMessages = [];

  bool inParty() {
    return currentPartyRef != null;
  }

  bool isHostOfParty() {
    return true;
  }

  void createParty(List<String> userIDs) async {
    print("Creating a new party...");
    List members = [];
    for (String uID in userIDs) {
      members.add(PartyMember.NewInvite(ID: uID));
    }
    DatabaseReference newPartyRef = partiesRef.push();
    newPartyRef.set({
      "isActive": true,
      "members": members,
      "messages": [],
      "actions": [],
    }).then((_) {
      currentPartyRef = newPartyRef;
      setupListeners(newPartyRef);
      sendInvites(newPartyRef!.key, userIDs);
      partyStatus = PartyStatus.HOST;
      notifyListeners();
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
  }

  setupListeners(DatabaseReference newPartyRef) async  {
    membersRef = newPartyRef.child("members");
    final membersSnapshot = await membersRef!.get();
    if (membersSnapshot.exists) {
      partyMembers = membersSnapshot.value as List<PartyMember>;
    }
    membersRef!.onChildAdded.listen((event) {
      print(event);
      // A new comment has been added, so add it to the displayed list.
    });
    membersRef!.onChildRemoved.listen((event) {
      // A comment has been removed; use the key to determine if we are displaying
      // this comment and if so remove it.
    });

    messagesRef = newPartyRef.child("messages");
    messagesRef!.onChildAdded.listen((event) {
      if (event.snapshot.exists) {
        final json = event.snapshot.value as Map<Object?, Object?>;
        print(json);
        ChatMessage cM = ChatMessage.fromJson(json.cast());
        chatMessages.add(cM);
        notifyListeners();
      }
    });
    messagesRef!.onChildRemoved.listen((event) {
      // A comment has been removed; use the key to determine if we are displaying
      // this comment and if so remove it.
    });

    actionsRef = newPartyRef.child("actions");
    final actionSnapshot = await actionsRef!.equalTo("STATUS", key: "action")
        .limitToLast(1).get();
    if (actionSnapshot.exists) {
      final latestStatus = actionSnapshot.value as VideoAction;
      videoActions.add(latestStatus);
    }
    actionsRef!.onChildAdded.listen((event) {
      print(event.snapshot.value);
      // A new comment has been added, so add it to the displayed list.
    });
  }

  sendInvites(key, userIDs) {
    print(key);
  }

  Future<void> addMember(String userID) async {
    if (membersRef == null) return;
    DatabaseReference newInviteRef = membersRef!.push();
    await newInviteRef.set(PartyMember.NewInvite(ID: userID).toJson());
  }

  Future<void> addMessage(ChatMessage message) async {
    if (messagesRef == null) return;
    DatabaseReference newMessageRef = messagesRef!.push();
    await newMessageRef.set(message.toJson());
  }

  Future<void> addAction(VideoAction action) async {
    if (actionsRef == null) return;
    DatabaseReference newActionRef = actionsRef!.push();
    await newActionRef.set(action.toJson());
  }

  void exitParty() {
    currentPartyRef = null;
    messagesRef = null; // messagesRef?.remove();
    actionsRef = null; // actionsRef?.remove();
    membersRef = null; // membersRef?.remove();
    notifyListeners();
  }

  void applyVideoActions(VideoManager videoManager) {
    if (videoActions.isEmpty) return;


    // videoActions.removeAt(index);
    print("Applied all actions");
  }
}

