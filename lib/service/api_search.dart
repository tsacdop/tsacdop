import 'dart:convert';

import 'package:dio/dio.dart';

import '../type/searchpodcast.dart';
import '../type/searchepisodes.dart';
import '../.env.dart';

class SearchEngine {
  Future<SearchPodcast<dynamic>> searchPodcasts(
      {String searchText, int nextOffset}) async {
    String apiKey = environment['apiKey'];
    String url = "https://listen-api.listennotes.com/api/v2/search?q=" +
        Uri.encodeComponent(searchText) +
        "&sort_by_date=0&type=podcast&offset=$nextOffset";
    Response response = await Dio().get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchPodcast.fromJson(searchResultMap);
    return searchResult;
  }

  Future<SearchEpisodes<dynamic>> fetchEpisode(
      {String id, int nextEpisodeDate}) async {
    String apiKey = environment['apiKey'];
    String url =
        "https://listen-api.listennotes.com/api/v2/podcasts/$id?next_episode_pub_date=$nextEpisodeDate";
    Response response = await Dio().get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchEpisodes.fromJson(searchResultMap);
    return searchResult;
  }
}
