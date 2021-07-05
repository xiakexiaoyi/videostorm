
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_aes/flutter_aes.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_cipher/flutter_cipher.dart' as cipher;
import 'dart:convert';
import 'base.dart';
import './bloc.dart';
import './models.dart';
import 'common/events.dart';
// 接口URL
abstract class API {
  static const categoryList='/category/list';
  static const videoList='/video/list';
  static const videoFollow='/video/follow';
  static const config='/config';
  static const update_avatar='/user/update_avatar';
  static const modify_password='/user/modify_password';
  static const videoM3u8='/video/m3u8/';
  static const favorite_add='/favorites/add';
  static const favorite_remove='/favorites/remove';
  static const favorite_list='/favorites/list';
  static const like_add='/like/add';
  static const like_remove='/like/remove';
  static const follow_add='/follow/add';
  static const follow_remove='/follow/remove';

  static const history_add='/history/add';
  static const history_list='/history/list';
  static const history_remove='/history/remove';
  static const tag_list='/tag/list';
  static const tag_hot='/tag/hot';
  static const video_top='/video/top';
  static const video_upload='/video/upload';
  static const video_add='/video/add2';
  static const follow_top='/follow/top';
  static const video_search='/video/search';
  static const video_user='/video/user';
  static const verify_code='/user/verify_code';
  static const register='/user/register';
  static const login='/user/login';
  static const user_info='/user/user_info';
  static const user_ext_info='/user/user_ext_info';
  static const user_follow='/user/follow';
  static const user_fans='/user/fans';
  static const user_modify='/user/user_modify';
}

// http请求
final dioManager = DioCacheManager(
    CacheConfig(
        skipDiskCache: true
    )
);
var httpClientGlobal= Dio(BaseOptions(
responseType: ResponseType.json,
connectTimeout: 5000,
receiveTimeout: 3000,
))..interceptors.add(
dioManager.interceptor,
);
final publicKey = cipher.RSAKeyParser().parse(TTBase.publicRsaKeyStr);
final cipher.Asymmetric rsaBase = cipher.Cipher.getAsymmetricInstance(cipher.RSA(publicKey: publicKey));
void initHttpClient(){
  httpClientGlobal = Dio(BaseOptions(
    baseUrl: TTBase.serverUrl,
    responseType: ResponseType.json,
    connectTimeout: 5000,
    receiveTimeout: 3000,
  ))..interceptors.add(
    dioManager.interceptor,
  );
}

class netHelper {
  static MediaType getMediaType(final String fileExt) {
    switch (fileExt.toLowerCase()) {
      case ".jpg":
      case ".jpeg":
      case ".jpe":
        return new MediaType("image", "jpeg");
      case ".png":
        return new MediaType("image", "png");
      case ".bmp":
        return new MediaType("image", "bmp");
      case ".gif":
        return new MediaType("image", "gif");
      case ".json":
        return new MediaType("application", "json");
      case ".svg":
      case ".svgz":
        return new MediaType("image", "svg+xml");
      case ".mp3":
        return new MediaType("audio", "mpeg");
      case ".mp4":
        return new MediaType("video", "mp4");
      case ".mov":
        return new MediaType("video", "mov");
      case ".htm":
      case ".html":
        return new MediaType("text", "html");
      case ".css":
        return new MediaType("text", "css");
      case ".csv":
        return new MediaType("text", "csv");
      case ".txt":
      case ".text":
      case ".conf":
      case ".def":
      case ".log":
      case ".in":
        return new MediaType("text", "plain");
    }
    return null;
  }

  static Future<Map> httpPost(Map data, String url, {token = ''}) async {
    try {
      String requestId = Guid.newGuid.toString().replaceAll('-', '').substring(
          0, 16);
      print(requestId);
      var header = rsaBase.encryptPublic(requestId);
      var header_token = token
          .toString()
          .length > 0 ? token : (BlocObj.user.state['isLogin'] ? (BlocObj.user
          .state['user'] as User).token : '');
      print(base64.encode(header.bytes));
      var httpClient = Dio(BaseOptions(
          baseUrl: TTBase.serverUrl,
          responseType: ResponseType.json,
          connectTimeout: 5000,
          receiveTimeout: 3000,
          headers: {
            'Request-Id': base64.encode(header.bytes),
            'Request-Key': TTBase.UUID.substring(0, 16),
            'Token': header_token,
          }

      ))
        ..interceptors.add(
          dioManager.interceptor,
        );


      String pd = base64.encode(await FlutterAes.encrypt(
          utf8.encode(json.encode(data)), utf8.encode(requestId + requestId),
          utf8.encode(requestId)));

      String postData = json.encode({'s': pd});
      var res = await httpClient.post(url, data: postData.toString());
      httpClient = null;
      String onceKeyStr = res.headers['Response-Id'].first.toString();
      String aespublicKey = rsaBase.decryptPublic(
          cipher.Encrypted.fromBase64(onceKeyStr));
      String result = utf8.decode(await FlutterAes.decrypt(
          base64.decode(res.data['s'].toString()),
          utf8.encode(aespublicKey + aespublicKey), utf8.encode(aespublicKey)));
      print('发送请求：' + res.request.uri.toString() + ' token：' + header_token +
          '  postdata：' +
          data.toString() + '  返回结果：' + result);
      return json.decode(result);
    } catch (e) {
      return {'code': -66, 'error': '网络请求失败：' + e.toString()};
    }
  }

  static Future<Map> uploadFile(String url, String filePath,
      {Map<String, String> headers = const {}, Map<String,
          String> body = const {}, Function progressCallback}) async {
    String requestId = Guid.newGuid.toString().replaceAll('-', '').substring(
        0, 16);
    print(requestId);
    var header = rsaBase.encryptPublic(requestId);
    var header_token = (BlocObj.user.state['isLogin'] ? (BlocObj.user
        .state['user'] as User).token : '');
    Map<String, dynamic> data = Map.of(body);
    var file = await MultipartFile.fromFile(
        filePath, filename: basename(filePath),
        contentType: getMediaType(extension(filePath)));
    FormData formData = FormData.fromMap(data);
    Dio dio = new Dio(BaseOptions(
      baseUrl: TTBase.serverUrl,));
    CancelToken cancelToken = CancelToken();
    Response res = await dio.post(url, data: file,
        options: Options(headers: {
          'Request-Id': base64.encode(header.bytes),
          'Request-Key': TTBase.UUID.substring(0, 16),
          'Token': header_token,
        }),
        onSendProgress: (int count, int data) {
          progressCallback(count, data, cancelToken);
        });
    if (res.statusCode == 200) {
      String onceKeyStr = res.headers['Response-Id'].first.toString();
      String aespublicKey = rsaBase.decryptPublic(
          cipher.Encrypted.fromBase64(onceKeyStr));
      String result = utf8.decode(await FlutterAes.decrypt(
          base64.decode(res.data['s'].toString()),
          utf8.encode(aespublicKey + aespublicKey), utf8.encode(aespublicKey)));
      print(
          '上传文件：' + url + ' token：' + header_token + ' data' + data.toString() +
              '返回结果：' + result);
      return json.decode(result);
    } else {
      return {'code': -66, 'error': '网络请求失败：' + res.statusCode.toString()};
    }
  }

  static Future<Map> uploadFileHttp(String url, String filePath,
      { Function progressCallback}) async {
    bool stop = false;
    String requestId = Guid.newGuid.toString().replaceAll('-', '').substring(
        0, 16);
    print(requestId);
    var header = rsaBase.encryptPublic(requestId);
    var header_token = (BlocObj.user.state['isLogin'] ? (BlocObj.user
        .state['user'] as User).token : '');
    Uri uri = Uri.parse(TTBase.serverUrl + url);
    var req = await HttpClient().postUrl(uri);
    var stopUploadFileEventListener = await Application.eventBus.on<
        StopUploadFileEvent>().listen((event) async {
      if (req != null && event.filePath == filePath) {
        stop = true;
      }
    });

    File file = new File(filePath);
    req.headers.add('Request-Id', base64.encode(header.bytes));
    req.headers.add('Request-Key', TTBase.UUID.substring(0, 16));
    req.headers.add('Token', header_token);
    var s = await file.open();
    var x = 0;
    var size = file.lengthSync();
    List val;
    var chunkSize = 65536;
    while (x < size) {
      if (stop) {
        break;
      }
      var _len = size - x >= chunkSize ? chunkSize : size - x;
      val = s.readSync(_len).toList();
      x = x + _len;
      progressCallback(x, size);
      req.add(val);
      await req.flush();
    }
    await s.close();
    stopUploadFileEventListener?.cancel();
    await req.close();
    final res = await req.done;
    String responseBody = await res.transform(utf8.decoder).join();
    String onceKeyStr = res.headers['Response-Id'].first.toString();
    String aespublicKey = rsaBase.decryptPublic(
        cipher.Encrypted.fromBase64(onceKeyStr));
    String result = utf8.decode(await FlutterAes.decrypt(
        base64.decode(json.decode(responseBody)['s']),
        utf8.encode(aespublicKey + aespublicKey), utf8.encode(aespublicKey)));
    print('上传文件：' + req.uri.toString() + ' 返回结果：' + result);
    if (res.statusCode == 200) {
      return json.decode(result);
    } else {
      return {'code': -66, 'error': '上传文件网络异常，' + res.statusCode.toString()};
    }
  }
}
