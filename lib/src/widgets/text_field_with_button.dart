import 'dart:io';
import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';

class TextFieldWithButton extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function onSubmit;
  final Function onEmojiTap;
  final bool showEmojiKeyboard;
  final BuildContext context;

  TextFieldWithButton({
    @required this.context,
    @required this.textEditingController,
    @required this.onSubmit,
    this.onEmojiTap,
    this.showEmojiKeyboard = false,
  });

  @override
  _TextFieldWithButtonState createState() => _TextFieldWithButtonState();
}

class _TextFieldWithButtonState extends State<TextFieldWithButton> {
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = widget.textEditingController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE9ECEF),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              // Emoji Button
              if (!Platform.isIOS)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        widget.onEmojiTap(widget.showEmojiKeyboard);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.showEmojiKeyboard
                              ? Color(0xFF3498DB).withOpacity(0.1)
                              : Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.showEmojiKeyboard
                                ? Color(0xFF3498DB).withOpacity(0.3)
                                : Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: widget.showEmojiKeyboard
                              ? Color(0xFF3498DB)
                              : Color(0xFF7F8C8D),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              // Text Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFFE9ECEF),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    autocorrect: true,
                    maxLines: 5,
                    minLines: 1,
                    showCursor: true,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: Color(0xFF3498DB),
                    controller: widget.textEditingController,
                    onSubmitted: (_) {
                      if (widget.textEditingController.text.trim().isNotEmpty) {
                        widget.onSubmit();
                      }
                    },
                    onTap: () {
                      if (widget.showEmojiKeyboard) {
                        widget.onEmojiTap(widget.showEmojiKeyboard);
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: 'Mesajınızı yazın...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF95A5A6),
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              // Send Button
              Container(
                margin: EdgeInsets.only(left: 8),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: _isTyping
                        ? LinearGradient(
                            colors: [
                              Color(0xFF3498DB),
                              Color(0xFF2980B9),
                            ],
                          )
                        : null,
                    color: _isTyping ? null : Color(0xFFE9ECEF),
                    boxShadow: _isTyping
                        ? [
                            BoxShadow(
                              color: Color(0xFF3498DB).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _isTyping
                          ? () {
                              widget.onSubmit();
                            }
                          : null,
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.send_rounded,
                          color: _isTyping ? Colors.white : Color(0xFF95A5A6),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        renderEmojiKeyboard(),
      ],
    );
  }

  Widget renderEmojiKeyboard() {
    if (widget.showEmojiKeyboard) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    if (widget.showEmojiKeyboard && !_keyboardIsVisible()) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE9ECEF),
              width: 1,
            ),
          ),
        ),
        child: EmojiPicker(
          rows: 4,
          columns: 7,
          onEmojiSelected: (emoji, category) {
            final emojiImage = emoji.emoji;
            widget.textEditingController.text =
                "${widget.textEditingController.text}$emojiImage";
            setState(() {
              _isTyping = widget.textEditingController.text.trim().isNotEmpty;
            });
          },
          recommendKeywords: ["racing", "horse"],
          numRecommended: 10,
        ),
      );
    }
    return Container(width: 0, height: 0);
  }

  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }
}
