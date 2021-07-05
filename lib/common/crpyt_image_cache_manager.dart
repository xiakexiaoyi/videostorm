import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_aes/flutter_aes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/byte_stream.dart';
import 'dart:convert';
import 'dart:io';


/// 缓存管理
class CrpytImageCacheManager extends CacheManager {
  static const key = 'libCrpytCachedImageData';

  static CrpytImageCacheManager _instance;
  factory CrpytImageCacheManager() {
    _instance ??= CrpytImageCacheManager._();
    return _instance;
  }

  CrpytImageCacheManager._() : super(Config(key, fileService: CrpytHttpFileService()));
}
class CrytFileServiceResponse extends FileServiceResponse{

  CrytFileServiceResponse(this._response,this._url);

  final DateTime _receivedTime = DateTime.now();
  final String _url;
  final http.StreamedResponse _response;

  @override
  int get statusCode => _response.statusCode;

  bool _hasHeader(String name) {
    return _response.headers.containsKey(name);
  }

  String _header(String name) {
    return _response.headers[name];
  }

  @override
  Stream<List<int>> get content  async*{
    String aesKey = _url.toString().substring(
        _url.toString().lastIndexOf('/') + 1);
    if (aesKey.contains('_')) {
      aesKey = aesKey.substring(0, aesKey.indexOf('_'));
    }
   // print('imageurl：'+_url);
    //print('image aeskey：' + aesKey);

    var completer = Completer<Uint8List>();
    var bytes=await _response.stream.toBytes();
   // print(bytes);
    var result=await FlutterAes.decrypt(Uint8List.fromList(bytes), utf8.encode(aesKey + aesKey+aesKey + aesKey), utf8.encode(aesKey+aesKey));
    //yield  ByteStream.fromBytes(result);
    yield result;

    //return _response.stream;

  }
//  Future<Uint8List> toBytes() {
//
//    var sink = ByteConversionSink.withCallback(
//            (bytes) => completer.complete(Uint8List.fromList(bytes)));
//    listen(sink.add,
//        onError: completer.completeError,
//        onDone: sink.close,
//        cancelOnError: true);
//    return completer.future;
//  }

  @override
  int get contentLength => _response.contentLength;

  @override
  DateTime get validTill {
    // Without a cache-control header we keep the file for a week
    var ageDuration = const Duration(days: 7);
    if (_hasHeader(HttpHeaders.cacheControlHeader)) {
      final controlSettings =
      _header(HttpHeaders.cacheControlHeader).split(',');
      for (final setting in controlSettings) {
        final sanitizedSetting = setting.trim().toLowerCase();
        if (sanitizedSetting == 'no-cache') {
          ageDuration = const Duration();
        }
        if (sanitizedSetting.startsWith('max-age=')) {
          var validSeconds = int.tryParse(sanitizedSetting.split('=')[1]) ?? 0;
          if (validSeconds > 0) {
            ageDuration = Duration(seconds: validSeconds);
          }
        }
      }
    }

    return _receivedTime.add(ageDuration);
  }

  @override
  String get eTag => _hasHeader(HttpHeaders.etagHeader)
      ? _header(HttpHeaders.etagHeader)
      : null;

  @override
  String get fileExtension {

    return 'png';
  }

}
class CrpytHttpFileService extends FileService {
  HttpClient _httpClient;

  CrpytHttpFileService({HttpClient httpClient}) {
    _httpClient = httpClient ?? HttpClient();
    _httpClient.badCertificateCallback = (cert, host, port) => true;
  }

  @override
  Future<CrytFileServiceResponse> get(String url,
      {Map<String, String> headers = const {}}) async {
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest req = await _httpClient.getUrl(resolved);
    headers?.forEach((key, value) {
      req.headers.add(key, value);
    });
    HttpClientResponse httpResponse = await req.close();
    http.StreamedResponse _response = http.StreamedResponse(
      httpResponse.timeout(Duration(seconds: 60)), httpResponse.statusCode,
      contentLength: httpResponse.contentLength,
      reasonPhrase: httpResponse.reasonPhrase,
      isRedirect: httpResponse.isRedirect,
    );


    return await CrytFileServiceResponse(_response,url);
  }
}