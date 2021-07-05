

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';


class VideoModel{
  int id;
  String image;
  String hash;
  String title;
  int duration;
  int played;
  List tags;
  int   add_time;
  int category;
  VideoModel_ExtInfo ext_info;
 VideoModel(this.id,this.image,this.played,this.hash,this.title,this.duration,this.add_time,this.category);
  VideoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        image = json['image'],
         played=json['played'],
        hash = json['hash'],
        tags=json['tags'],
        title = json['title'],
        duration = json['duration'],
        add_time=json['add_time'],
        category=json['category'],
        ext_info=new VideoModel_ExtInfo(json['ext_info']['user_id'],json['ext_info']['user_name'],json['ext_info']['is_favorites']==0?false:true,json['ext_info']['is_follow']==0?false:true,json['ext_info']['is_like']==0?false:true,json['ext_info']['like_count'],json['ext_info']['favorites_count'],
            new User_ExtInfo(json['ext_info']['user_ext_info']['long_video_count'], json['ext_info']['user_ext_info']['short_video_count'], json['ext_info']['user_ext_info']['like_count'], json['ext_info']['user_ext_info']['follow'], json['ext_info']['user_ext_info']['fans'],json['ext_info']['is_follow']==0?false:true,)
            );



  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'image': image,
        'hash': hash,
        'title': title,
        'played':played,
        'duration': duration,
        'add_time': add_time,
        'tags':tags,
      };
}
class VideoModel_ExtInfo{
int user_id;
String user_name;
bool is_favorites=false;
bool is_follow=false;
bool is_like=false;
int like_count=0;
int favorites_count=0;
User_ExtInfo user_ext_info;
VideoModel_ExtInfo(this.user_id,this.user_name,this.is_favorites,this.is_follow,this.is_like,this.like_count,this.favorites_count,this.user_ext_info);

}
class LongVideoCategory{
  int id;
  String name;
  int showIndex;
  LongVideoCategory(this.id,this.name,this.showIndex);
}
@JsonSerializable()
class User_ExtInfo{
  int long_video_count;
  int short_video_count;
  int like_count=0;
int follow=0;
bool is_follow=false;
  int fans=0;
  Map<String, dynamic> toJson() =>
  {
    'long_video_count':long_video_count,
    'short_video_count':short_video_count,
    'like_count':like_count,
    'follow':follow,
    'fans':fans


  };
  User_ExtInfo(this.long_video_count,this.short_video_count,this.like_count,this.follow,this.fans,this.is_follow);

}
@JsonSerializable()
class LocalData {
  String theme = 'System';
  int play_lastdate = 0;
  int played_free = 0;
  List<int>played_videoids = [];

  LocalData();

  LocalData.fromJson(Map<String, dynamic> json)
      : play_lastdate = json['play_lastdate'],
        played_videoids = json['played_videoids'].cast<int>(),
        played_free = json['played_free'],
        theme=json['theme'];

  Map<String, dynamic> toJson() =>
      {
        'play_lastdate': play_lastdate,
        'played_free': played_free,
        'played_videoids': played_videoids,
        'theme': theme,
      };
}
@JsonSerializable()
class User {
  User(this.token,
      this.password,
      this.id,
      this.phone,
      this.username,
      this.vip_time,
      this.balance,this.last_update_time);

  String token;
  String password;
  int id;
  String phone;
  String username;
  int vip_time;
  int balance;
  int last_update_time=0;
  User_ExtInfo ext_info;
  bool following=false;

  User.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        password = json['password'],
        id = json['id'],
        phone = json['phone'],
        username = json['username'],
        vip_time =json['vip_time'],
        balance=json['balance'],
  last_update_time=json['last_update_time'],
        ext_info=new User_ExtInfo(json['ext_info']['long_video_count'],
            json['ext_info']['short_video_count'],
            json['ext_info']['like_count'], json['ext_info']['follow'],
            json['ext_info']['fans'],json['ext_info']['is_follow']==1?true:false);


  Map<String, dynamic> toJson() =>
      {
        'token': token,
        'password': password,
        'id': id,
        'phone': phone,
        'username': username,
        'vip_time': vip_time,
        'balance': balance,
        'last_update_time':last_update_time,
        'ext_info': ext_info.toJson(),
      };

}

@JsonSerializable()
class AppConfig {
  AppConfig(this.res_server,);


  String res_server;
  int play_count_free=5;
  int play_count_free_login=5;


  AppConfig.fromJson(Map<String, dynamic> json)
      : res_server = json['res_server'];


  Map<String, dynamic> toJson() =>
      {
        'res_server': res_server,
      };

}

@JsonSerializable()
class SearchHistory {
  SearchHistory(this.keyword,this.date,);


  String keyword;
  int date=0;


  SearchHistory.fromJson(Map<String, dynamic> json)
      : keyword = json['keyword'],date=json['date'];


  Map<String, dynamic> toJson() =>
      {
        'keyword': keyword,
        'date':date
      };

}

@JsonSerializable()
class Tag {
  Tag(this.id,this.tag,this.count);


  int id;
  String tag;
  int count;


  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],tag=json['tag'],count=json['count'];


  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'tag':tag,
        'count':count
      };

}