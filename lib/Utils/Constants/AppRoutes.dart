import 'package:echat/Screens/ChatList/Presentation/chat_list.dart';
import 'package:echat/Screens/Login/Presentation/auto_login.dart';
import 'package:echat/Screens/Login/Presentation/login_screen.dart';
import 'package:flutter/material.dart';


final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => AutoLogin(),
  '/gmailAuth': (context) => GmailAuthPage(),
  '/chatList': (context) => ChatList(),
};
