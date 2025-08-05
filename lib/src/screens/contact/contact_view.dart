import 'package:chat_app/src/data/models/chat.dart';
import 'package:chat_app/src/data/models/message.dart';
import 'package:chat_app/src/data/providers/chats_provider.dart';
import 'package:chat_app/src/screens/contact/contact_controller.dart';
import 'package:chat_app/src/utils/dates.dart';
import 'package:chat_app/src/widgets/custom_app_bar.dart';
import 'package:chat_app/src/widgets/text_field_with_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker/emoji_picker.dart';

enum MessagePosition { BEFORE, AFTER }

class ContactScreen extends StatefulWidget {
  static final String routeName = "/contact";

  ContactScreen();

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with TickerProviderStateMixin {
  ContactController _contactController;
  final format = new DateFormat("HH:mm");
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _contactController = ContactController(
      context: context,
    );
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _contactController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _contactController.initProvider();
    super.didChangeDependencies();
  }

  Color _getAvatarColor() {
    final colors = [
      Color(0xFF3498DB),
      Color(0xFF9B59B6),
      Color(0xFFE74C3C),
      Color(0xFF2ECC71),
      Color(0xFFF39C12),
      Color(0xFF1ABC9C),
      Color(0xFFE67E22),
      Color(0xFF34495E),
    ];
    int index = _contactController.selectedChat.user.name.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: _contactController.streamController.stream,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF2C3E50),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: GestureDetector(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getAvatarColor().withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        child: Text(
                          _contactController.selectedChat.user.name[0]
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        radius: 18,
                        backgroundColor: _getAvatarColor(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _contactController.selectedChat.user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "@${_contactController.selectedChat.user.username}",
                            style: TextStyle(
                              color: Color(0xFF95A5A6),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFF3498DB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF3498DB),
                      size: 20,
                    ),
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF8F9FA),
                              Color(0xFFECF0F1),
                            ],
                          ),
                        ),
                        child: Scrollbar(
                          child: ListView.builder(
                            controller: _contactController.scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            reverse: true,
                            itemCount:
                                _contactController.selectedChat.messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: renderMessage(
                                    context,
                                    _contactController
                                        .selectedChat.messages[index],
                                    index),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: TextFieldWithButton(
                        onSubmit: _contactController.sendMessage,
                        textEditingController: _contactController.textController,
                        onEmojiTap: (bool showEmojiKeyboard) {
                          _contactController.showEmojiKeyboard =
                              !showEmojiKeyboard;
                        },
                        showEmojiKeyboard: _contactController.showEmojiKeyboard,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget renderMessage(BuildContext context, Message message, int index) {
    if (_contactController.myUser == null) return Container();
    bool isMyMessage = message.from == _contactController.myUser.id;
    
    return Column(
      children: <Widget>[
        renderMessageSendAtDay(message, index),
        Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isMyMessage
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!isMyMessage) renderMessageSendAt(message, MessagePosition.BEFORE),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(isMyMessage ? 20 : 4),
                    bottomRight: Radius.circular(isMyMessage ? 4 : 20),
                  ),
                  color: isMyMessage
                      ? Color(0xFF3498DB)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isMyMessage
                          ? Colors.white
                          : Color(0xFF2C3E50),
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              if (isMyMessage) renderMessageSendAt(message, MessagePosition.AFTER),
            ],
          ),
        ),
      ],
    );
  }

  Widget renderMessageSendAt(Message message, MessagePosition position) {
    bool isMyMessage = message.from == _contactController.myUser.id;
    
    if (isMyMessage && position == MessagePosition.AFTER) {
      return Container(
        margin: EdgeInsets.only(left: 8, bottom: 4),
        child: Text(
          messageDate(message.sendAt),
          style: TextStyle(
            color: Color(0xFF95A5A6),
            fontSize: 11,
          ),
        ),
      );
    }
    if (!isMyMessage && position == MessagePosition.BEFORE) {
      return Container(
        margin: EdgeInsets.only(right: 8, bottom: 4),
        child: Text(
          messageDate(message.sendAt),
          style: TextStyle(
            color: Color(0xFF95A5A6),
            fontSize: 11,
          ),
        ),
      );
    }
    return Container(height: 0, width: 0);
  }

  String messageDate(int milliseconds) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return format.format(date);
  }

  Widget renderMessageSendAtDay(Message message, int index) {
    if (index == _contactController.selectedChat.messages.length - 1) {
      return getLabelDay(message.sendAt);
    }
    final lastMessageSendAt = new DateTime.fromMillisecondsSinceEpoch(
        _contactController.selectedChat.messages[index + 1].sendAt);
    final messageSendAt =
        new DateTime.fromMillisecondsSinceEpoch(message.sendAt);
    final formatter = UtilDates.formatDay;
    String formattedLastMessageSendAt = formatter.format(lastMessageSendAt);
    String formattedMessageSendAt = formatter.format(messageSendAt);
    if (formattedLastMessageSendAt != formattedMessageSendAt) {
      return getLabelDay(message.sendAt);
    }
    return Container();
  }

  Widget getLabelDay(int milliseconds) {
    String day = UtilDates.getSendAtDay(milliseconds);
    return Column(
      children: <Widget>[
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color(0xFF3498DB).withOpacity(0.1),
            border: Border.all(
              color: Color(0xFF3498DB).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              day,
              style: TextStyle(
                color: Color(0xFF3498DB),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

