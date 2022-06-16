import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list_bloc_example/posts/bloc/post_bloc.dart';
import 'package:infinite_list_bloc_example/posts/view/view.dart';
import 'package:http/http.dart' as http;

class PostsPage extends StatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Infinite BLoC'),
      ),
      body: BlocProvider(
          create: (_) =>
              PostBloc(httpClient: http.Client())..add(PostFetched()),
          child: const PostList()),
    );
  }
}
