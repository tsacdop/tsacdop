import 'dart:convert';

import 'package:dio/dio.dart';

import '../.env.dart';
import '../type/searchepisodes.dart';
import '../type/searchpodcast.dart';

class SearchEngine {
  Future<SearchPodcast<dynamic>> searchPodcasts(
      {String searchText, int nextOffset}) async {
    var apiKey = environment['apiKey'];
    var url = "https://listen-api.listennotes.com/api/v2/search?q="
        "${Uri.encodeComponent(searchText)}${"&sort_by_date=0&type=podcast&offset=$nextOffset"}";
    var response = await Dio().get(url,
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
    var apiKey = environment['apiKey'];
    var url =
        "https://listen-api.listennotes.com/api/v2/podcasts/$id?next_episode_pub_date=$nextEpisodeDate";
    var response = await Dio().get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchEpisodes.fromJson(searchResultMap);
    return searchResult;
  }
}
