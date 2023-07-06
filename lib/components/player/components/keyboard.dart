import 'dart:async';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum KeySet {
  alphabets, number, emojis
}

class Keyboard extends StatefulWidget {
  TextEditingController textController;
  bool allowEmoji;
  bool allowNumbers;
  bool allowAlphabets;
  bool allowNewLine;
  Widget? actionWidget;

  Keyboard({Key? key,
    required this.textController,
    this.allowEmoji = true,
    this.allowNumbers = true,
    this.allowAlphabets = true,
    this.allowNewLine = true,
    this.actionWidget,
  }) : super(key: key);

  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {

  @override
  Widget build(BuildContext context) {
    return CustomKeyboard(
      onTextInput: (myText) {
        _insertText(myText, widget.textController);
      },
      onBackspace: () {
        _backspace(widget.textController);
      },
      allowEmoji: widget.allowEmoji,
      allowAlphabets: widget.allowAlphabets,
      allowNumbers: widget.allowNumbers,
      allowNewLine: widget.allowNewLine,
      actionWidget: widget.actionWidget ?? const Positioned(left: 0, bottom: 0,child: SizedBox(width: 1, height: 1,),),
    );
  }

  void _insertText(String myText, TextEditingController controller) {
    final text = controller.text;
    final textSelection = controller.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void _backspace(TextEditingController controller) {
    final text = controller.text;
    final textSelection = controller.selection;
    final selectionLength = textSelection.end - textSelection.start;

    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      controller.text = newText;
      controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }

    // Delete the previous character
    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomKeyboard extends StatefulWidget {
  CustomKeyboard({
    Key? key,
    required this.onTextInput,
    required this.onBackspace,
    required this.allowEmoji,
    required this.allowNumbers,
    required this.allowAlphabets,
    required this.allowNewLine,
    required this.actionWidget
  }) : super(key: key);

  final ValueSetter<String> onTextInput;
  final VoidCallback onBackspace;
  final bool allowEmoji;
  final bool allowNumbers;
  final bool allowAlphabets;
  final bool allowNewLine;
  Widget actionWidget;

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool capsOn = false;
  String letters = "abcdefghijklmnopqrstuvwxyz";
  KeySet keySet = KeySet.alphabets;

  void _tIH(String char) {
    if (capsOn && letters.contains(char)) {
      return widget.onTextInput?.call(char.toUpperCase());
    }
    return widget.onTextInput?.call(char);
  }

  void _bSH() => widget.onBackspace?.call();

  Widget buildBackKey(orientation) {
    return BackspaceKey(
      onBackspace: _bSH,
    );
  }

  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(
        builder: (context, o) {
          Orientation orientation = MediaQuery.of(context).orientation;
          if (orientation == Orientation.portrait) {
            return Container(
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  SizedBox(
                    // margin: const EdgeInsets.only(right: 56),
                    width: 328,
                    height: 308,
                    child: buildKeys(),
                  ),
                  SizedBox(
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        ...buildKeySets(),
                        Expanded(child: SizedBox()),
                        buildBackKey(orientation),
                        SizedBox(height: 50,),
                      ]
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  // color: Theme.of(context).shadowColor,
                  height: 28,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: buildKeySets(),
                  ),
                ),
                SizedBox(
                  // color: Theme.of(context).shadowColor,
                  // margin: const EdgeInsets.only(top: 14, bottom: 4),
                  width: 328,
                  height: 280,
                  child: Center(child: buildKeys()),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 21, bottom: 7),
                  child: buildBackKey(orientation)
                ),
              ],
            );
          }
        }
    );
  }

  Widget buildKeys() {
    switch(keySet) {
      case KeySet.alphabets:
        return AlphabetLayout(
          toggleCaps: () {
            setState(() {
              capsOn = !capsOn;
            });
          },
          allowNewLine: widget.allowNewLine,
          tIH: _tIH,
          capsOn: capsOn,
        );
      case KeySet.emojis:
        return EmojiLayout(tIH: _tIH,);
      case KeySet.number:
        return NumberLayout(tIH: _tIH, allowNewLine: widget.allowNewLine,);
    };
  }

  List<Widget> buildKeySets() {
    List<Widget> keySetButtons = [];
    if (keySet != KeySet.number) {
      keySetButtons.add(
        IconButton(
            onPressed: widget.allowNumbers ? () {
              setState(() {
                keySet = KeySet.number;
              });
            } : null,
            disabledColor: Theme.of(context).disabledColor,
            icon: const Icon(Icons.numbers, size: 28)
        ),
      );
    }
    if (keySet != KeySet.emojis) {
      keySetButtons.add(
        IconButton(
            onPressed: widget.allowEmoji ? () {
              setState(() {
                keySet = KeySet.emojis;
              });
            } : null,
            disabledColor: Theme.of(context).disabledColor,
            icon: const Icon(Icons.emoji_emotions_rounded, size: 28)
        ),
      );
    }
    if (keySet != KeySet.alphabets) {
      keySetButtons.add(
        IconButton(
            onPressed: widget.allowAlphabets ? () {
              setState(() {
                keySet = KeySet.alphabets;
              });
            } : null,
            disabledColor: Theme.of(context).disabledColor,
            icon: const Icon(Icons.sort_by_alpha_outlined, size: 28)
        ),
      );
    }

    return keySetButtons;
  }
}

class AlphabetLayout extends StatelessWidget {
  Function(String) tIH;
  bool capsOn;
  bool allowNewLine;
  VoidCallback toggleCaps;

  AlphabetLayout({
    Key? key,
    required this.tIH,
    required this.capsOn,
    required this.toggleCaps,
    required this.allowNewLine,
  }) : super(key: key);

  Widget firstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(flex: 4,child: SizedBox(),),
        TextKey(text: 'b', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'c', onTextInput: tIH, capsOn: capsOn),
        if (!capsOn)
          TextKey(text: '-', onTextInput: tIH, capsOn: capsOn),
        if (capsOn)
          TextKey(text: '_', onTextInput: tIH, capsOn: capsOn),
        if (!capsOn)
          TextKey(text: '*', onTextInput: tIH, capsOn: capsOn),
        if (capsOn)
          TextKey(text: '"', onTextInput: tIH, capsOn: capsOn),
        const Expanded(flex: 4, child: SizedBox(),),
      ],
    );
  }

  secondRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextKey(text: 'h', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'g', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'o', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'u', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'e', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'p', onTextInput: tIH, capsOn: capsOn),
      ],
    );
  }

  row7() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextKey(text: 'm', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'x', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'i', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'l', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'v', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 't', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'y', onTextInput: tIH, capsOn: capsOn),
      ],
    );
  }

  row72() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextKey(text: 'n', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'a', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 's', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'd', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'f', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'j', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'k', onTextInput: tIH, capsOn: capsOn),
      ],
    );
  }

  row6() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextKey(text: 'r', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'q', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'w', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: 'z', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: '!', onTextInput: tIH, capsOn: capsOn),
        TextKey(text: '?', onTextInput: tIH, capsOn: capsOn),
      ],
    );
  }

  essentials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(flex: 1,child: SizedBox(),),
        ShiftKey(
          toggleCaps: toggleCaps,
        ),
        const Expanded(flex: 2,child: SizedBox(),),
        SpaceKey(onSpace: () => tIH(' '),),
        const Expanded(flex: 1,child: SizedBox(),),
        if (capsOn)
          TextKey(text: ',', onTextInput: tIH, capsOn: capsOn),
        if (!capsOn)
          TextKey(text: '.', onTextInput: tIH, capsOn: capsOn),
        const Expanded(flex: 2,child: SizedBox(),),
        NewLineKey(goNewLine: () => tIH('\n'), isAllowed: allowNewLine,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        firstRow(),
        secondRow(),
        row7(),
        row72(),
        row6(),
        essentials(),
      ],
    );
  }

}

class EmojiLayout extends StatelessWidget {
  Function(String) tIH;

  static const List<List<AnimatedEmojiData>> emojiSet = [
    [AnimatedEmojis.rabbit, AnimatedEmojis.rainbow, AnimatedEmojis.rofl, AnimatedEmojis.rocket, AnimatedEmojis.smile, AnimatedEmojis.clap, AnimatedEmojis.brokenHeart, AnimatedEmojis.alarmClock, AnimatedEmojis.balloon, AnimatedEmojis.babyChick, AnimatedEmojis.bitingLip, AnimatedEmojis.butterfly],
    [AnimatedEmojis.drum, AnimatedEmojis.dancerWoman, AnimatedEmojis.dragon, AnimatedEmojis.fireworks, AnimatedEmojis.eyes, AnimatedEmojis.fire, AnimatedEmojis.fireHeart, AnimatedEmojis.tiger, AnimatedEmojis.frog, AnimatedEmojis.blood,],
    [AnimatedEmojis.peace, AnimatedEmojis.peacock, AnimatedEmojis.pinkHeart, AnimatedEmojis.partyingFace, AnimatedEmojis.heartEyes, AnimatedEmojis.heartGrow, AnimatedEmojis.halo, AnimatedEmojis.directHit, AnimatedEmojis.dolphin, AnimatedEmojis.diagonalMouth,],
    [AnimatedEmojis.aquarius, AnimatedEmojis.cowboy, AnimatedEmojis.waveDark, AnimatedEmojis.whiteHeart, AnimatedEmojis.wave, AnimatedEmojis.wiltedFlower, AnimatedEmojis.wineGlass, AnimatedEmojis.woozy, AnimatedEmojis.wink, AnimatedEmojis.zanyFace, AnimatedEmojis.zipperFace, AnimatedEmojis.dizzy, AnimatedEmojis.dizzyFace,],
    [AnimatedEmojis.eagle, AnimatedEmojis.electricity, AnimatedEmojis.exclamationDouble, AnimatedEmojis.exhale, AnimatedEmojis.expressionless, AnimatedEmojis.airplaneArrival, AnimatedEmojis.airplaneDeparture, AnimatedEmojis.ant, AnimatedEmojis.bat, AnimatedEmojis.bandagedHeart, AnimatedEmojis.armMechanical, AnimatedEmojis.aries, AnimatedEmojis.fallenLeaf,]
  ];

  EmojiLayout({Key? key, required this.tIH}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28, bottom: 28),
      // height: 222,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, pageNumber) {
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: [
              for (AnimatedEmojiData emoji in emojiSet[pageNumber])
                EmojiKey(emoji: emoji, addEmoji: (string) {
                  tIH(string);
                })
            ],
          );
        }
      ),
    );
  }

}

class NumberLayout extends StatelessWidget {
  Function(String) tIH;
  bool allowNewLine;

  NumberLayout({Key? key, required this.tIH, required this.allowNewLine}) : super(key: key);

  Widget buildSigns() {
    return Column(
      children: [
        Row(
            children: [
              TextKey(text: '@', onTextInput: tIH, capsOn: false),
              TextKey(text: '+', onTextInput: tIH, capsOn: false),
              TextKey(text: '(', onTextInput: tIH, capsOn: false),
              TextKey(text: ')', onTextInput: tIH, capsOn: false),
            ]
        ),
        Row(
          children: [
            TextKey(text: '#', onTextInput: tIH, capsOn: false),
            TextKey(text: '-', onTextInput: tIH, capsOn: false),
            TextKey(text: '[', onTextInput: tIH, capsOn: false),
            TextKey(text: ']', onTextInput: tIH, capsOn: false),
          ],
        ),
        Row(
          children: [
            TextKey(text: '%', onTextInput: tIH, capsOn: false),
            TextKey(text: '/', onTextInput: tIH, capsOn: false),
            TextKey(text: '{', onTextInput: tIH, capsOn: false),
            TextKey(text: '}', onTextInput: tIH, capsOn: false),
          ],
        ),
        Row(
          children: [
            TextKey(text: '^', onTextInput: tIH, capsOn: false),
            TextKey(text: '*', onTextInput: tIH, capsOn: false),
            TextKey(text: '<', onTextInput: tIH, capsOn: false),
            TextKey(text: '>', onTextInput: tIH, capsOn: false),
          ],
        )
      ],
    );
  }

  Widget buildNumbers() {
    return Column(
      children: [
        Row(
          children: [
            TextKey(text: '7', onTextInput: tIH, capsOn: false),
            TextKey(text: '8', onTextInput: tIH, capsOn: false),
            TextKey(text: '9', onTextInput: tIH, capsOn: false),
          ]
        ),
        Row(
          children: [
            TextKey(text: '4', onTextInput: tIH, capsOn: false),
            TextKey(text: '5', onTextInput: tIH, capsOn: false),
            TextKey(text: '6', onTextInput: tIH, capsOn: false),
          ],
        ),
        Row(
          children: [
            TextKey(text: '1', onTextInput: tIH, capsOn: false),
            TextKey(text: '2', onTextInput: tIH, capsOn: false),
            TextKey(text: '3', onTextInput: tIH, capsOn: false),
          ],
        ),
        Row(
          children: [
            TextKey(text: ':', onTextInput: tIH, capsOn: false),
            TextKey(text: '0', onTextInput: tIH, capsOn: false),
            TextKey(text: '=', onTextInput: tIH, capsOn: false),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSigns(),
            buildNumbers()
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(flex: 2,child: SizedBox(),),
            TextKey(text: '&', onTextInput: tIH, capsOn: false),
            const Expanded(flex: 1,child: SizedBox(),),
            SpaceKey(onSpace: () => tIH(' '),),
            const Expanded(flex: 1,child: SizedBox(),),
            TextKey(text: '.', onTextInput: tIH, capsOn: false),
            const Expanded(flex: 1,child: SizedBox(),),
            NewLineKey(goNewLine: () => tIH('\n'), isAllowed: allowNewLine,),
            const Expanded(flex: 2,child: SizedBox(),),
          ],
        )
      ],
    );
  }
}


class TextKey extends StatelessWidget {
  TextKey({
    Key? key,
    required this.text,
    required this.onTextInput,
    required this.capsOn
  }) : super(key: key);

  final String text;
  final ValueSetter<String> onTextInput;
  bool capsOn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Theme.of(context).shadowColor,
        shape: const CircleBorder(),
        // borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            onTextInput.call(text);
          },
          child: SizedBox(
            // decoration: BoxDecoration(),
            width: 37, height: 37,
            // padding: const EdgeInsets.all(7),
            child: Center(child: Text(
              capsOn ? text.toUpperCase() : text,
              style: GoogleFonts.voltaire(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  color: Theme.of(context).primaryColor
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class BackspaceKey extends StatelessWidget {
  BackspaceKey({
    Key? key,
    required this.onBackspace,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback onBackspace;
  final int flex;
  final Duration backSpeed =  const Duration(milliseconds: 77);
  Timer? backBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onBackspace,
      padding: const EdgeInsets.all(7),
      iconSize: 28,
      icon: Icon(Icons.backspace,),
    );
  }
}

class ShiftKey extends StatelessWidget {
  const ShiftKey({
    Key? key,
    required this.toggleCaps,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback toggleCaps;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(7),
        // shape: Border.all(color: Colors.white),
        child: InkWell(
          onTap: toggleCaps,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Center(
              child: Icon(Icons.arrow_circle_up, size: 28),
            ),
          ),
        ),
    );
  }
}

class SpaceKey extends StatelessWidget {
  const SpaceKey({
    Key? key,
    required this.onSpace,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback onSpace;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).shadowColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onSpace,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 70, vertical: 4),
          child: Icon(Icons.space_bar, size: 28,),
        ),
      ),
    );
  }
}

class NewLineKey extends StatelessWidget {
  const NewLineKey({
    Key? key,
    required this.goNewLine,
    this.flex = 1,
    required this.isAllowed,
  }) : super(key: key);

  final VoidCallback goNewLine;
  final int flex;
  final bool isAllowed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).shadowColor,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: isAllowed ? goNewLine : null,

        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.layers_outlined, size: 28,),
        ),
      ),
    );
  }
}

class EmojiKey extends StatelessWidget {
  AnimatedEmojiData emoji;
  final ValueSetter<String> addEmoji;

  EmojiKey({Key? key, required this.emoji, required this.addEmoji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 37,
      splashColor: Theme.of(context).primaryColor,
      onTap: () {
        print(emoji.id);
        addEmoji("\\${emoji.id} ");
      },
      child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedEmoji(emoji, size: 37,)
      )
    );
  }

}


