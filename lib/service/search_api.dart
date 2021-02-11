import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../.env.dart';
import '../home/about.dart';
import '../type/search_api/index_episode.dart';
import '../type/search_api/index_podcast.dart';
import '../type/search_api/itunes_podcast.dart';
import '../type/search_api/search_top_podcast.dart';
import '../type/search_api/searchepisodes.dart';
import '../type/search_api/searchpodcast.dart';

const podcastIndexApi = {
  "podcastIndexApiKey": "XXWQEGULBJABVHZUM8NF",
  "podcastIndexApiSecret": "KZ2uy4upvq4t3e\$m\$3r2TeFS2fEpFTAaF92xcNdX"
};

enum SearchEngine { podcastIndex, listenNotes }

class ListenNotesSearch {
  final _dio = Dio(BaseOptions(connectTimeout: 30000, receiveTimeout: 90000));
  final _baseUrl = "https://listen-api.listennotes.com/api/v2/";
  final _apiKey = environment['apiKey'];
  bool get _validApi => _apiKey != '';

  Future<SearchPodcast<dynamic>> searchPodcasts(
      {String searchText, int nextOffset}) async {
    if(!_validApi) return null;
    var url = "${_baseUrl}search?q="
        "${Uri.encodeComponent(searchText)}${"&sort_by_date=0&type=podcast&offset=$nextOffset"}";
    var response = await _dio.get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$_apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchPodcast.fromJson(searchResultMap);
    return searchResult;
  }

  Future<SearchEpisodes<dynamic>> fetchEpisode(
      {String id, int nextEpisodeDate}) async {
    if(!_validApi) return null;
    var url =
        "${_baseUrl}podcasts/$id?next_episode_pub_date=$nextEpisodeDate";
    var response = await _dio.get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$_apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchEpisodes.fromJson(searchResultMap);
    return searchResult;
  }

  Future<SearchTopPodcast<dynamic>> fetchBestPodcast(
      {String genre, int page, String region = 'us'}) async {
    if(!_validApi) return null;
    var url =
        "${_baseUrl}best_podcasts?genre_id=$genre&page=$page&region=$region";
    var response = await Dio().get(url,
        options: Options(headers: {
          'X-ListenAPI-Key': "$_apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchTopPodcast.fromJson(searchResultMap);
    return searchResult;
  }
}

class ItunesSearch {
  Future<ItunesSearchResult<dynamic>> searchPodcasts(
      {String searchText, int limit}) async {
    final url = "https://itunes.apple.com/search?term="
        "${Uri.encodeComponent(searchText)}&media=podcast&entity=podcast&limit=$limit";
    final response = await Dio()
        .get(url, options: Options(headers: {'Accept': "application/json"}));
    print(response.toString());
    Map searchResultMap = jsonDecode(response.toString());
    final searchResult = ItunesSearchResult.fromJson(searchResultMap);
    return searchResult;
  }
}

class PodcastsIndexSearch {
  final _dio = Dio(BaseOptions(connectTimeout: 30000, receiveTimeout: 90000));
  final _baseUrl = 'https://api.podcastindex.org';
  Map<String, String> _initSearch() {
    final unixTime =
        (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
    final apiKey = podcastIndexApi['podcastIndexApiKey'];
    final apiSecret = podcastIndexApi['podcastIndexApiSecret'];
    final firstChunk = utf8.encode(apiKey);
    final secondChunk = utf8.encode(apiSecret);
    final thirdChunk = utf8.encode(unixTime);
    var output = AccumulatorSink<Digest>();
    var input = sha1.startChunkedConversion(output);
    input.add(firstChunk);
    input.add(secondChunk);
    input.add(thirdChunk);
    input.close();
    var digest = output.events.single;

    var headers = <String, String>{
      "X-Auth-Date": unixTime,
      "X-Auth-Key": apiKey,
      "Authorization": digest.toString(),
      "User-Agent": "Tsacdop/$version"
    };
    return headers;
  }

  Future<PodcastIndexSearchResult<dynamic>> searchPodcasts(
      {String searchText, int limit = 99}) async {
    final url = "$_baseUrl/api/1.0/search/byterm"
        "?q=${Uri.encodeComponent(searchText)}&max=$limit&fulltext=true";
    final headers = _initSearch();
    final response = await _dio.get(url, options: Options(headers: headers));
    Map searchResultMap = jsonDecode(response.toString());
    final searchResult = PodcastIndexSearchResult.fromJson(searchResultMap);
    return searchResult;
  }

  Future<IndexEpisodeResult<dynamic>> fetchEpisode({String rssUrl}) async {
    final url = "$_baseUrl/api/1.0/episodes/byfeedurl?url=$rssUrl";
    final headers = _initSearch();
    final response = await _dio.get(url, options: Options(headers: headers));
    Map searchResultMap = jsonDecode(response.toString());
    final searchResult = IndexEpisodeResult.fromJson(searchResultMap);
    return searchResult;
  }
}
