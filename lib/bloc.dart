/*
 * @discripe: bloc全局状态管理
 */
import 'package:bloc/bloc.dart';
import './models.dart';

abstract class BlocObj {
  static final user=UserBloc();
  static final index = IndexBloc();
  static final longVideoIndex=LongVideoIndexBloc();
}
abstract class  PagerEvent {}
abstract class  UserEvent {}
class UpdatePageIndex implements PagerEvent {
  final Map page;
  UpdatePageIndex(this.page);
}


abstract class IndexEvent {}
abstract class LongVideoIndexEvent{}

class UpdateTab implements IndexEvent {
  final List tab;
  UpdateTab(this.tab);
}
class UpdateCategory implements LongVideoIndexEvent {
  final List category;
  UpdateCategory(this.category);
}
class UpdateUser implements UserEvent{
  final User user;
  UpdateUser(this.user);
}
class UpdateLiveData implements IndexEvent {
  final Map liveData;
  UpdateLiveData(this.liveData);
}

class UpdateSwiper implements IndexEvent {
  final List swiper;
  UpdateSwiper(this.swiper);
}
class UpdateUserLoginState implements UserEvent{
  final bool isLogin;
  UpdateUserLoginState(this.isLogin);
}
class LongVideoIndexBloc extends Bloc<LongVideoIndexEvent,Map>
{
  LongVideoIndexBloc():super({
    'category':[]
  });
  @override
  Stream<Map> mapEventToState(LongVideoIndexEvent event) async* {
    if (event is UpdateCategory) {
      yield { ...state, 'category': event.category };
    }
  }
}
class IndexBloc extends Bloc<IndexEvent, Map> {
  IndexBloc() : super({
    'nav': [],
    'videolist':[],
    'swiper': []
  });

  @override
  Stream<Map> mapEventToState(IndexEvent event) async* {
    if (event is UpdateTab) {
      yield { ...state, 'nav': event.tab };
    } else if (event is UpdateLiveData) {
      yield { ...state, 'videolist': event.liveData };
    } else if (event is UpdateSwiper) {
      yield { ...state, 'swiper': event.swiper };
    }
  }
}
class UserBloc extends Bloc<UserEvent,Map> {
  UserBloc() : super({
    'user': [],
    'isLogin':false,
  }
  );

  @override
  Stream<Map> mapEventToState(UserEvent event) async* {
    if (event is UpdateUser) {
      yield { ...state, 'user': event.user};

    }else if(event is UpdateUserLoginState)
    {
      yield { ...state, 'isLogin': event.isLogin};
    }
  }
}