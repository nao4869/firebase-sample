// The file which is to create new post from user input
import 'package:firebase_sample/models/http_exception.dart';
import 'package:firebase_sample/models/post.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // for http request

class PostProvider with ChangeNotifier {
  List<Post> posts = [];

  PostProvider({
    this.posts,
  });

  // getter for post
  List<Post> get postList {
    return [...posts];
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

      extractedData.forEach((postId, postData) {
        loadedPosts.add(Post(
          id: postData['id'],
          //id: postId,
          name: postData['name'],
          imagePath: postData['imagePath'],
          videoPath: postData['videoPath'],
          createdAt: postData['createdAt'],
        ));
      });
      posts = loadedPosts;

      // 作成日毎にソートする
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
          // 'id': post.id,
          'name': post.name,
          'imagePath': post.imagePath,
          'videoPath': post.videoPath,
          'createdAt': post.createdAt,
        }),
      );

      final newPost = Post(
        name: post.name,
        imagePath: post.imagePath,
        videoPath: post.videoPath,
        createdAt: post.createdAt,
        id: json.decode(response.body)['name'],
      );
      posts.add(newPost);
      // 新規投稿時にも、作成日順にソートする
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updatePost(String id, Post newPost) async {
    final postIndex = posts.indexWhere((cs) => cs.id == id);

    if (postIndex >= 0) {
      final url = 'https://fir-book-sample.firebaseio.com/posts/$id.json';
      await http.patch(url,
          body: json.encode({
            'name': newPost.name,
            'imagePath': newPost.imagePath,
            'videoPath': newPost.videoPath,
            'createdAt': newPost.createdAt,
          }));
      posts[postIndex] = newPost;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deletePost(String id) async {
    final url = 'https://fir-book-sample.firebaseio.com/posts/$id.json';
    final existingPostIndex = posts.indexWhere((post) => post.id == id);
    var existingCourse = posts[existingPostIndex];
    posts.removeAt(existingPostIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      posts.insert(existingPostIndex, existingCourse);
      notifyListeners();
      throw HttpException('Could not delete post.');
    }
    existingCourse = null;
  }
}
