import 'dart:convert';
import 'dart:math';

import 'package:chat_app/src/data/models/chat.dart';
import 'package:chat_app/src/data/providers/chats_provider.dart';
import 'package:chat_app/src/screens/contact/contact_view.dart';
import 'package:chat_app/src/utils/dates.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class ChatCard extends StatelessWidget {
  final Chat chat;

  final format = new DateFormat("HH:mm");

  final List<Color> avatarColors = [
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
    Color(0xFF2ECC71),
    Color(0xFFF39C12),
    Color(0xFF1ABC9C),
    Color(0xFFE67E22),
    Color(0xFF34495E),
  ];

  final rng = new Random();

  ChatCard({
    @required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr_TR', null);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ChatsProvider _chatsProvider =
                Provider.of<ChatsProvider>(context, listen: false);
            _chatsProvider.setSelectedChat(chat);
            Navigator.of(context).pushNamed(ContactScreen.routeName);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    child: Text(
                      chat.user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    radius: 24,
                    backgroundColor: _getAvatarColor(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              chat.user.name,
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                UtilDates.getSendAtDayOrHour(chat.messages[0].sendAt),
                                style: TextStyle(
                                  color: _numberOfUnreadMessagesByMe() > 0
                                      ? Color(0xFF3498DB)
                                      : Color(0xFF95A5A6),
                                  fontSize: 12,
                                  fontWeight: _numberOfUnreadMessagesByMe() > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              if (_numberOfUnreadMessagesByMe() > 0)
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: unreadMessages(),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        chat.messages[0].message,
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    // Kullanıcı adına göre tutarlı renk seçimi
    int index = chat.user.name.hashCode % avatarColors.length;
    return avatarColors[index.abs()];
  }

  String messageDate(int milliseconds) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return format.format(date);
  }

  int _numberOfUnreadMessagesByMe() {
    return chat.messages.where((message) => message.unreadByMe).length;
  }

  Widget unreadMessages() {
    final _unreadMessages = _numberOfUnreadMessagesByMe();
    if (_unreadMessages == 0) {
      return Container(width: 0, height: 0);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFF3498DB),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _unreadMessages > 99 ? '99+' : _unreadMessages.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

