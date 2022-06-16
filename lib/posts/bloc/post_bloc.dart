import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:infinite_list_bloc_example/posts/models/post.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) =>
      droppable<E>().call(events.throttle(duration), mapper);
}

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onPostFetched(
      PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        return emit(state.copyWith(
            status: PostStatus.success, posts: posts, hasReachedMax: false));
      }
      final posts = await _fetchPosts(state.posts.length);
      posts.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(state.copyWith(
              status: PostStatus.success,
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: false));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure));
      log(e.toString());
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    try {
      final response = await httpClient.get(
        Uri.https(
          'jsonplaceholder.typicode.com',
          '/posts',
          <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
        ),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as List;
        return body
            .map((dynamic json) => Post(
                id: json['id'] as int,
                title: json['title'] as String,
                body: json['body'] as String))
            .toList();
      }
    } catch (e) {
      log(e.toString());
    }
    throw Exception('Error Fetching posts');
  }
}
