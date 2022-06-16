import 'package:flutter/material.dart';

import '../models/post.dart';

class PostListItem extends StatelessWidget {
  final Post post;
  const PostListItem({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme texTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text(
          '${post.id}',
          style: texTheme.caption,
        ),
        title: Text(post.title),
        isThreeLine: true,
        subtitle: Text(post.body),
        dense: true,
      ),
    );
  }
}
