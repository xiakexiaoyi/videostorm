import 'package:flutter/material.dart';
import '../res/colours.dart';
import '../base.dart';

class LoadingDialog extends StatefulWidget with TTBase {
  final String text;
  Function dismissDialog;
  LoadingDialog({Key key, @required this.text,@required this.dismissDialog}) : super(key: key);
  @override
  State<LoadingDialog> createState() => _loadingDialogState();

}
class _loadingDialogState extends State<LoadingDialog> with TTBase {
  _dismissDialog() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.dismissDialog != null) {
      widget.dismissDialog(
              (){Navigator.of(context).pop();}
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: SizedBox(
              width: dp(120),
              height: dp(120),
              child: Container(
                decoration: ShapeDecoration(
                  color: Theme.of(context).backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(color: Colours.app_main,),
                    Padding(
                      padding: EdgeInsets.only(
                        top: dp(20),
                      ),
                      child: Text(
                        widget.text,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
