// The file which is to create new post from user input
import 'package:firebase_sample/models/http_exception.dart';
import 'package:firebase_sample/models/post.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // for http request

class Posts with ChangeNotifier {
  List<Post> _posts = [];

  Posts(
    this._posts,
  );

  // getter for post
  List<Post> get posts {
    return [..._posts];
  }

  Future<void> retrievePostData() async {
    var url = 'https://fir-book-sample.firebaseio.com/posts.json';
    try {
      final response = await http.get(url); // get for fetching from DB
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }
      final List<Post> loadedPosts = [];

      extractedData.forEach((postId, courseData) {
        loadedPosts.add(Post(
          id: postId,
          name: courseData['name'],
          imagePath: courseData['imagePath'],
          createdAt: courseData['createdAt'],
        ));
      });
      _posts = loadedPosts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addPost(Post post) async {
    const url = 'https://fir-book-sample.firebaseio.com/posts.json';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'name': post.name,
          'imagePath': post.imagePath,
          'createdAt': post.createdAt,
        }),
      );

      final newPost = Post(
        name: post.name,
        imagePath: post.imagePath,
        createdAt: post.createdAt,
        id: json.decode(response.body)['name'],
      );
      _posts.add(newPost);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updatePost(String id, Post newPost) async {
    final postIndex = _posts.indexWhere((cs) => cs.id == id);

    if (postIndex >= 0) {
      final url = 'https://fir-book-sample.firebaseio.com/posts/$id.json';
      await http.patch(url,
          body: json.encode({
            'name': newPost.name,
            'imagePath': newPost.imagePath,
            'createdAt': newPost.createdAt,
          }));
      _posts[postIndex] = newPost;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deletePost(String id) async {
    final url = 'https://fir-book-sample.firebaseio.com/posts/$id.json';
    final existingPostIndex = _posts.indexWhere((post) => post.id == id);
    var existingCourse = _posts[existingPostIndex];
    _posts.removeAt(existingPostIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _posts.insert(existingPostIndex, existingCourse);
      notifyListeners();
      throw HttpException('Could not delete post.');
    }
    existingCourse = null;
  }
}
