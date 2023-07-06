import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../components/player/components/keyboard.dart';
import '../organizers/app_manager.dart';

class UserScreen extends StatefulWidget {

  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _UserScreenState extends State<UserScreen> {
  final profilesRef = FirebaseFirestore.instance.collection('profiles')
      .withConverter<Profile>(
        fromFirestore: (snapshot, _) => Profile.fromJson(snapshot.data()!, ID: snapshot.id),
        toFirestore: (user, _) => user.toJson(),
      );
  Profile? profile;
  String? errorMessage;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> fetchProfile(String userId) async {
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    List<QueryDocumentSnapshot<Profile>> profiles = await profilesRef
        .where('userID', isEqualTo: userId)
        .get().then((snapshot) => snapshot.docs);
    if (profiles.isNotEmpty) {
      List<Profile> listProfiles = profiles.map((e) => e.data()).toList();
      setState(() {
        profile = listProfiles[0];
      });
      appManager.setCurrentProfile(listProfiles[0]);
    }
  }

  Future<void> updateProfile() async {
    String userId = auth.currentUser!.uid;
    await profilesRef.doc(userId).update({});
    fetchProfile(userId);
  }

  void logOut() async {
    setState(() => errorMessage = '');
    await FirebaseAuth.instance.signOut();
    AppManager appManager = Provider.of<AppManager>(context, listen: false);
    appManager.setCurrentProfile(null);
    setState(() {});
  }

  void login(String email, String password) async {
    setState(() => errorMessage = '');
    await auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    if (auth.currentUser != null) {
      fetchProfile(auth.currentUser!.uid);
    }
    setState(() {});
  }

  @override
  void initState() {
    if (auth.currentUser != null) {
      fetchProfile(auth.currentUser!.uid);
    } else {
      auth.authStateChanges().listen((User? user) {
        if (user != null) {
          fetchProfile(user.uid);
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser == null) {
      return LoginScreen(logIn: login);
    } else if (auth.currentUser != null && profile == null) {
      return const Center(
        child: Text("..."),
      );
    } else {
      return ProfileScreen(profile: profile!, logOut: logOut);
    }
  }
}

class LoginScreen extends StatefulWidget {
  Function logIn;

  LoginScreen({Key? key, required this.logIn}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController(text: 'abc@def.com');
  final TextEditingController passwordController = TextEditingController(text: 'abcdef');

  TextEditingController? currentController;

  Widget buildEmailField() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(28)
          ),
          child: Icon(
            Icons.email_outlined,
            size: 28,
            color: Theme.of(context).shadowColor,
          ),
        ),
        SizedBox(
          width: 249,
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.fromLTRB(7, 2, 14, 28)
            ),
            readOnly: true,
            showCursor: true,
            onTap: () {
              setState(() {
                currentController = emailController;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(28)
          ),
          child: Icon(
            Icons.password_outlined,
            size: 28,
            color: Theme.of(context).shadowColor,
          ),
        ),
        SizedBox(
          width: 249,
          child: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.fromLTRB(7, 2, 14, 28)
            ),
            readOnly: true,
            showCursor: true,
            onTap: () {
              setState(() {
                currentController = passwordController;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildKeyboard() {
    return Keyboard(
      textController: currentController!,
      allowNewLine: false,
      allowEmoji: false,
      actionWidget: Positioned(
        bottom: 7,
        child: signInButton(),
      ),
    );
  }

  Widget signInButton() {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          visualDensity: VisualDensity.standard,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 7, horizontal: 14)
          ),
        ),
        onPressed: () => widget.logIn(emailController.text, passwordController.text),
        child: Text('Sign In', style: TextStyle(color: Theme.of(context).canvasColor),)
    );
  }

  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(
      builder: (context, o) {
        Orientation orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildEmailField(),
                        const SizedBox(height: 37,),
                        buildPasswordField(),
                        const SizedBox(height: 28,),
                        if (currentController != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              signInButton(),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: currentController != null
                          ? buildKeyboard()
                          : signInButton()
                    ),
                  )
                ],
              )
          );
        }

        return Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: SizedBox()),
                buildEmailField(),
                const SizedBox(height: 37,),
                buildPasswordField(),
                const SizedBox(height: 37,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    signInButton(),
                  ],
                ),
                Expanded(flex: 1, child: SizedBox()),
                if (currentController != null)
                  SizedBox(height: 328, child: buildKeyboard())
              ],
            )
        );
      }
    );
  }
}

enum Editables { TAG, NAME, PICTURE }
class ProfileScreen extends StatefulWidget {
  final Profile profile;
  final VoidCallback logOut;

  const ProfileScreen({Key? key, required this.profile, required this.logOut}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Editables? currentlyEditing;
  TextEditingController controller = TextEditingController();

  List<XFile>? _imageFileList;

  void _setImageFileListFromFile(XFile? value) {
    setState(() {
      _imageFileList = value == null ? null : <XFile>[value];
    });
  }
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  Future<void> _onImageButtonPressed(ImageSource source,
      {required BuildContext context, bool isMultiImage = false}) async {
    if (context.mounted) {

      await _displayPickImageDialog(context,
              (double? maxWidth, double? maxHeight, int? quality) async {
            try {
              final XFile? pickedFile = await _picker.pickImage(
                source: source,
                // maxWidth: maxWidth,
                // maxHeight: maxHeight,
                // imageQuality: quality,
              );
              print("picked XFILE");
              if (pickedFile != null) {
                print(pickedFile.name);
                setState(() {
                  _setImageFileListFromFile(pickedFile);
                });
              }

            } catch (e) {
              setState(() {
                _pickImageError = e;
              });
            }
          });
    }
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxWidth if desired'),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxHeight if desired'),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Enter quality if desired'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    final double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    final double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    final int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }


  Widget buildPicture() {
    return InkWell(
      onTap: () {

      },
      onLongPress: () {
        setState(() {
          currentlyEditing = Editables.PICTURE;
        });
      },
      child: Icon(Icons.account_circle,
          size: 128,
          color: Theme.of(context).primaryColor
      ),
    );
  }

  Widget buildTag() {
    return InkWell(
      onLongPress: () {
        setState(() {
          currentlyEditing = Editables.TAG;
        });
      },
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alternate_email, size: 48, color: Colors.grey),
            const SizedBox(width: 10,),
            Text(widget.profile.tag ?? "...",
              style: GoogleFonts.notoSerif(
                textStyle: Theme.of(context).textTheme.headlineMedium,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ]
      ),
    );
  }

  Widget buildName() {
    return InkWell(
      onLongPress: () {
        setState(() {
          currentlyEditing = Editables.NAME;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
              child: Text(widget.profile.name ?? "...",
                style: GoogleFonts.notoSerif(
                  textStyle: Theme.of(context).textTheme.headlineLarge,
                  color: Theme.of(context).primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              )
          ),
        ],
      ),
    );
  }

  Widget buildLogOut() {
    if (currentlyEditing == Editables.NAME || currentlyEditing == Editables.TAG) {
      return SizedBox(
          width: 328,
          child: Visibility(
              visible: true,
              child: Keyboard(textController: controller,)
          )
      );
    } else if (currentlyEditing == null) {
      return ElevatedButton(
          onPressed: widget.logOut,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
            visualDensity: VisualDensity.standard,
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(vertical: 7, horizontal: 14)
            ),
          ),
          child: Text('Log Out',
              style: GoogleFonts.notoSerif(
                textStyle: Theme.of(context).textTheme.headlineSmall,
                color: Theme.of(context).canvasColor,
              )
          )
      );
    } else {
      return Center(
        child: _imageFileList != null && _imageFileList!.isNotEmpty
            ? Text(_imageFileList!.length.toString())
            : FloatingActionButton(
                onPressed: () {
                  // isVideo = false;
                  _onImageButtonPressed(ImageSource.gallery, context: context);
                },
                heroTag: 'image0',
                tooltip: 'Pick Image from gallery',
                child: const Icon(Icons.photo),
              ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, o) {
        Orientation orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPicture(),
                        const SizedBox(height: 28,),
                        buildTag(),
                        const SizedBox(height: 28,),
                        buildName(),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Center(child: buildLogOut(),))
                ],
              )
          );
        }
        return Container(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                const Expanded(child: SizedBox(),),
                buildPicture(),
                const SizedBox(height: 28,),
                buildTag(),
                const SizedBox(height: 28,),
                buildName(),
                const Expanded(child: SizedBox(),),
                buildLogOut(),
                const Expanded(child: SizedBox(),),
              ],
            )
        );
      }
    );
  }
}

