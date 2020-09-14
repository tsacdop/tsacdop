import 'dart:convert';

import 'package:dio/dio.dart';

import '../.env.dart';
import '../type/search_top_podcast.dart';
import '../type/searchepisodes.dart';
import '../type/searchpodcast.dart';

class SearchEngine {
  final apiKey = environment['apiKey'];
  Future<SearchPodcast<dynamic>> searchPodcasts(
      {String searchText, int nextOffset}) async {
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

  Future<SearchTopPodcast<dynamic>> fetchBestPodcast(
      {String genre, int page, String region = 'us'}) async {
    var url =
        "https://listen-api.listennotes.com/api/v2/best_podcasts?genre_id=$genre&page=$page&region=$region";
    var response = await Dio().get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchTopPodcast.fromJson(searchResultMap);
    return searchResult;
  }
}
