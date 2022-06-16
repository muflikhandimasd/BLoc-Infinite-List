import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list_bloc_example/posts/bloc/post_bloc.dart';

import '../widgets/widgets.dart';

class PostList extends StatefulWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(builder: (context, state) {
      switch (state.status) {
        case PostStatus.failure:
          return const Center(
            child: Text('Failed to fetch posts'),
          );
        case PostStatus.success:
          if (state.posts.isEmpty) {
            return const Center(
              child: Text('no posts'),
            );
          }
          return ListView.builder(
            itemCount: state.hasReachedMax
                ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
            itemBuilder: (_, i) {
              return i >= state.posts.length
                  ? const BottomLoader()
                  : PostListItem(post: state.posts[i]);
            },
          );
        default:
          return const Center(
            child: CircularProgressIndicator(),
          );
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
