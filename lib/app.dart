import 'package:flutter/material.dart';

import 'posts/view/view.dart';

class App extends MaterialApp {
  const App({Key? key}) : super(key: key, home: const PostsPage());
}
