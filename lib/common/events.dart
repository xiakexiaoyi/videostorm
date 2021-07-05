import 'package:event_bus/event_bus.dart';

class Application{
  static EventBus eventBus = EventBus();
}
class StopPlayLongVideoEvent{

}
class StopUploadFileEvent{
String filePath;
StopUploadFileEvent(this.filePath);
}
class UpdateAvatarEvent{

}