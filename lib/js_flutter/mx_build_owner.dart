import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mx_json_to_dart.dart';
import 'dart:convert';

import 'mx_js_framework.dart';
import 'mx_js_flutter_common.dart';

typedef Future<dynamic> MXJsonWidgetCallbackFun(String callID, {dynamic p});

Map<String, dynamic> g_mirrorObjectMap = {};

//buildOwner 除了根节点，于 MXJSWidgetState 一一对应，形成树状结构，持有MXJSWidgetState，
//并接收JS调用操作MXJSWidgetState
class MXJsonBuildOwner {
  MXJSFlutterApp ownerApp;
  MXJsonBuildOwner parentBuildOwner;
  Map<String, MXJsonBuildOwner> childrenBuildOwner = {};

  List mirrorObjKeyList = [];

  dynamic widget;
  Map<String, dynamic> _widgetMap;

  var widgetName;

  MXJsonBuildOwner(dynamic jsWidget, MXJsonBuildOwner parentBuildOwner) {
    this.ownerApp = parentBuildOwner?.ownerApp;
    this.widget = jsWidget;
    this.parentBuildOwner = parentBuildOwner;

    String ownerWidgetID = this.widget.widgetID;
    assert(ownerWidgetID != null && ownerWidgetID.isNotEmpty);

    parentBuildOwner?.addChildBuildOwner(ownerWidgetID, this);
  }

  MXJsonBuildOwner.rootBuildOwner(this.ownerApp) {}

  void addChildBuildOwner(String widgetID, MXJsonBuildOwner bo) {
    if (widgetID == null || widgetID.isEmpty || bo == null) {
      return;
    }

    childrenBuildOwner[widgetID] = bo;
  }

  removeChildBuildOwner(String widgetID) {
    childrenBuildOwner.remove(widgetID);
  }

  dynamic findWidget(Key key) {
    if (key == null) {
      return null;
    }

    for (MXJsonBuildOwner bo in childrenBuildOwner.values) {
      if (bo.widget.key == key) {
        return bo.widget;
      }
    }

    return null;
  }

  dynamic buildRootWidget(Map widgetData) {
    dynamic w = MXJsonObjToDartObject.jsonToDartObj(this, widgetData);
    return w;
  }

  Widget build(Map widgetData, BuildContext context) {
    var w =
        MXJsonObjToDartObject.jsonToDartObj(this, widgetData, context: context);

    if (w == null) {
      w = Center(
        child: Text("MXJsonBuildOwner error return null"),
      );
    }

    return w;
  }

  //事件回调
  //flutter->JS
  dynamic eventCallback(String callID, {dynamic p}) async {
    var ownerWidgetID = this.widget?.widgetID;
    String buildSeq = this.widget?.buildWidgetDataSeq;

    return await callJSWidgetOnEventCallback(
        widgetID: ownerWidgetID, buildSeq: buildSeq, callID: callID, args: p);
  }

  dynamic callJSWidgetOnEventCallback(
      {String widgetID, String buildSeq, String callID, dynamic args}) async {
    MethodCall jsMethodCall = MethodCall("flutterCallOnEventCallback", {
      "widgetID": widgetID,
      "buildSeq": buildSeq,
      "callID": callID,
      "args": args
    });

    return await ownerApp.callJS(jsMethodCall);
  }

  callJSOnBuildEnd() {
    MXJSLog.debug(
        "MXJSWidgetState:callJSOnBuildEnd:  this.widget.widgetID:${this.widget.widgetID} buildSeq:${this.widget.buildWidgetDataSeq}");

    var ownerWidgetID = this.widget.widgetID;
    String buildSeq = this.widget.buildWidgetDataSeq;

    dynamic parentWidget = this.parentBuildOwner.widget;
    var parentWidgetID = "";
    if (parentWidget != null) {
      parentWidgetID = parentWidget.widgetID;
    }

    MethodCall jsMethodCall = MethodCall("flutterCallOnBuildEnd", {
      "widgetID": ownerWidgetID,
      "buildSeq": buildSeq,
      "rootWidgetID": parentWidgetID,
    });

    ownerApp.callJS(jsMethodCall);
  }

  callJSOnDispose() {
    var ownerWidgetID = this.widget.widgetID;
    MethodCall jsMethodCall = MethodCall("flutterCallOnDispose", {
      "widgetID": ownerWidgetID,
      "mirrorObjIDList": mirrorObjKeyList,
    });

    ownerApp.callJS(jsMethodCall);
  }

  ///动态创建Widget回调，如List
  ///
  Future<dynamic> widgetBuilderCallback(String callID, {dynamic p}) {}

  //js->flutter

  void jsCallRebuild(args) {
    String widgetDataStr = args["widgetData"];
    bool isRootWidget = args["isRootWidget"];

    Map widgetMap = json.decode(widgetDataStr);
    String widgetID = widgetMap["widgetID"];
    String name = widgetMap["name"];
    String className = widgetMap["className"];
    Map widgetData = widgetMap["widgetData"];
    String buildWidgetDataSeq = widgetMap["buildWidgetDataSeq"];

    if (className != "MXJSStatefulWidget" &&
        className != "MXJSStatelessWidget") {
      MXJSLog.error(
          "jsCallRebuild(jsWidget == null || (jsWidget is! MXJSStatefulWidget && jsWidget is! MXJSStatelessWidget)): name:$name widgetData:$widgetData");
      return;
    }

    // MXJsonBuildOwner bo;
    // if (isRootWidget != true) {
    //   bo = findBuildOwner(widgetID);
    // } else {
    //   // 针对从flutter侧push进来的js页面，作为根页面，统一通过jsWidget.name来获取BuildOwner。解决根页面是StatelessWidget，获取BuildOwner错误的问题
    //   bo = findBuildOwner(name);
    // }

    // if (bo == null) {
    //   MXJSLog.log(
    //       "findBuildOwner(widgetID) == null: name:$name id:$widgetID");
    //   bo = findBuildOwner(name);
    // }

    //------
    MXJsonBuildOwner bo = findBuildOwner(widgetID);

    if (bo == null) {
      //TODO:errormx
      MXJSLog.error(
          "findBuildOwner(jsWidget.widgetID)== null: name:$name id:$widgetID");
      return;
    }

    bo.clearAllChildBuildOwner();
    bo.rebuildJSWidget(name, widgetID, widgetData, buildWidgetDataSeq);
  }

  void rebuildJSWidget(
      String name, String widgetID, Map widgetData, String buildWidgetDataSeq) {
    var ownerWidgetID = this.widget.widgetID;

    if (ownerWidgetID != null && ownerWidgetID != widgetID) {
      MXJSLog.log(
          "MXJSStatefulWidget:rebuildJSWidget: error: this.widget.widgetID != jsWidget.widgetID");
    }

    MXJSWidgetHelper helper = this.widget.helper;
    helper.jsRebuild(widgetID, widgetData, buildWidgetDataSeq);

    //更新为widgetid
    // parentBuildOwner?.addChildBuildOwner(widgetID, this);
    // removeChildBuildOwner(name);
  }

  //js->flutter
  jsCallNavigatorPush(args) {
    String widgetDataStr = args["widgetData"];

    Map widgetMap = json.decode(widgetDataStr);
    dynamic jsWidget = buildRootWidget(widgetMap);

    if (jsWidget == null ||
        (jsWidget is! MXJSStatefulWidget && jsWidget is! MXJSStatelessWidget)) {
      MXJSLog.error(
          "jsCallNavigatorPush(jsWidget == null || (jsWidget is! MXJSStatefulWidget && jsWidget is! MXJSStatelessWidget)): name:${jsWidget.name} widgetData:${jsWidget.widgetData}");
      return;
    }

    //谁push jsWidget，找到对应的build owner
    String navPushingWidgetID = jsWidget.navPushingWidgetID;
    MXJsonBuildOwner bo = findBuildOwner(navPushingWidgetID);

    if (bo == null) {
      MXJSLog.error(
          "jsCallNavigatorPush(bo == null: name:${jsWidget.name} navPushingWidgetID:$navPushingWidgetID");
      return;
    }

    bo.widget.helper.jsNavigatorPush(jsWidget, bo.widget.context);
  }

  jsCallNavigatorPop(args) {
    String widgetID = args["widgetID"];
    var bo = findBuildOwner(widgetID);

    if (bo == null) {
      MXJSLog.error("jsCallNavigatorPop(bo == null: widgetID:$widgetID");
      return;
    }

    bo.widget.helper.jsNavigatorPop(bo.widget.context);
  }

  MXJsonBuildOwner findBuildOwner(widgetID) {
    MXJsonBuildOwner bo = childrenBuildOwner[widgetID];

    if (bo != null) {
      return bo;
    }

    for (var k in childrenBuildOwner.keys) {
      var v = childrenBuildOwner[k];
      MXJsonBuildOwner bo = v.findBuildOwner(widgetID);
      if (bo != null) {
        return bo;
      }
    }

    return null;
  }

  void jsCallInvokeCommon(widgetDataStr) {
    Map argMap = json.decode(widgetDataStr);

    String widgetID = argMap["widgetID"];
    String className = argMap["className"];
    String funcName = argMap["funcName"];
    Map args = argMap["args"];
    invokeFunctionCommon(widgetID, className, funcName, args);
  }

  void invokeFunctionCommon(
      String widgetID, String className, String funcName, Map args) {
    var bo = findBuildOwner(widgetID);
    if (bo == null) {
      MXJSLog.error("jsCallNavigatorPop(bo == null: widgetID:$widgetID");
      return;
    }

    final context = bo.widget.buildContext;
    if (className == 'Scaffold') {
      if (funcName == 'of') {
        //查找scaffoldState
        final scaffoldState = Scaffold.of(context); //
        //动态构建snackbar
        var snackBar = MXJsonObjToDartObject.jsonToDartObj(
            this, args["snackBar"],
            context: context);
        //设置snackbar
        scaffoldState.showSnackBar(snackBar);
      }
    }
  }

  void jsCallInvoke(widgetDataStr) {
    Map argMap = json.decode(widgetDataStr);
    String mirrorID = argMap["mirrorID"];
    dynamic mirrorObj = getMirrorObjectFromID(mirrorID);
    if (mirrorObj != null) {
      String className = argMap["className"];
      String funcName = argMap["funcName"];
      Map args = argMap["args"];
      invokeFunction(mirrorID, mirrorObj, className, funcName, args);
    }
  }

  // 先写在一起跑通再说，后面再考虑把代码写得优雅些
  void invokeFunction(String mirrorID, dynamic mirrorObj, String className,
      String funcName, Map args) {
    if (className == 'AnimationController') {
      if (funcName == 'forward') {
        (mirrorObj as AnimationController).forward();
        return;
      } else if (funcName == 'reverse') {
        (mirrorObj as AnimationController).reverse();
        return;
      } else if (funcName == 'repeat') {
        (mirrorObj as AnimationController).repeat();
        return;
      } else if (funcName == 'drive') {
        Animatable animatable = args['animatable'];
        (mirrorObj as AnimationController).drive(animatable);
        return;
      }
    }

    if (className == 'RefreshController') {
      if (funcName == 'loadComplete') {
        mirrorObj.loadComplete();
        return;
      } else if (funcName == 'loadFailed') {
        mirrorObj.loadFailed();
        return;
      } else if (funcName == 'loadNoData') {
        mirrorObj.loadNoData();
        return;
      }
    }
  }

  //MirrorObj事件回调
  //flutter->JS
  Future<dynamic> mirrorObjEventCallback(dynamic mirrorID, String functionName,
      {dynamic p}) async {
    callJSWidgetOnmirrorObjEventCallback(
        mirrorID: mirrorID, functionName: functionName, args: p);
  }

  callJSWidgetOnmirrorObjEventCallback(
      {dynamic mirrorID, String functionName, dynamic args}) async {
    MethodCall jsMethodCall = MethodCall("flutterCallOnMirrorObjInvoke",
        {"mirrorID": mirrorID, "functionName": functionName, "args": args});

    ownerApp.callJS(jsMethodCall);
  }

  String getJsonObjMirrorID(Map jsonMap) {
    dynamic mirrorID = jsonMap["mirrorID"];
    return mirrorID;
  }

  dynamic getMirrorObjectFromMap(Map jsonMap) {
    dynamic mirrorID = jsonMap["mirrorID"];
    if (mirrorID != null) {
      return g_mirrorObjectMap[mirrorID];
    }
    return null;
  }

  dynamic getMirrorObjectFromID(dynamic mirrorID) {
    return g_mirrorObjectMap[mirrorID];
  }

  void setMirrorObject(dynamic mirrorObj, Map jsonMap) {
    String mirrorID = getJsonObjMirrorID(jsonMap);
    if (mirrorID != null) {
      if (!mirrorObjKeyList.contains(mirrorID)) {
        mirrorObjKeyList.add(mirrorID);
      }
      g_mirrorObjectMap[mirrorID] = mirrorObj;
    }
  }

  void removeMirrorObject(dynamic mirrorID) {
    g_mirrorObjectMap.remove(mirrorID);
  }

  void disposeMirrorObjs() {
    mirrorObjKeyList.forEach((dynamic mirrorID) {
      dynamic mirrorObj = g_mirrorObjectMap[mirrorID];
      if (mirrorObj is AnimationController) {
        mirrorObj.dispose();
      }

      removeMirrorObject(mirrorID);
    });
  }

  void clearAllChildBuildOwner() {
    this.childrenBuildOwner.clear();
  }

  void onDispose() {
    // 移除parentBuildOwner中当前的widget
    parentBuildOwner.removeChildBuildOwner(this.widget.widgetID);

    //告诉JS，可以销毁这个JSWidget了
    callJSOnDispose();

    // 移除镜像对象
    disposeMirrorObjs();
  }
}

class MXProxyMXJSStatefulWidget extends MXJsonObjProxy {
  static Map<String, CreateJsonObjProxyFun> registerProxy() {
    ///**@@@  2 替换类名字符串
    final String regClassName1 = "MXJSStatefulWidget";

    ///**@@@  3 替换类构造函数
    return {
      regClassName1: () =>
          MXProxyMXJSStatefulWidget()..init(className: regClassName1)
    };
  }

  @override
  MXJSStatefulWidget constructor(
      MXJsonBuildOwner bo, Map<String, dynamic> jsonMap,
      {BuildContext context}) {
    var widget = MXJSStatefulWidget(
        key: mxj2d(bo, jsonMap["key"]),
        name: mxj2d(bo, jsonMap["name"]),
        widgetID: mxj2d(bo, jsonMap["widgetID"]),
        widgetData: jsonMap["widgetData"],
        buildingWidgetDataSeq: mxj2d(bo, jsonMap["buildWidgetDataSeq"]),
        navPushingWidgetID: jsonMap["navPushingWidgetID"],
        parentBuildOwner: bo);
    return widget;
  }
}

class MXProxyMXJSStatelessWidget extends MXJsonObjProxy {
  static Map<String, CreateJsonObjProxyFun> registerProxy() {
    ///**@@@  2 替换类名字符串
    final String regClassName1 = "MXJSStatelessWidget";

    ///**@@@  3 替换类构造函数
    return {
      regClassName1: () =>
          MXProxyMXJSStatelessWidget()..init(className: regClassName1)
    };
  }

  @override
  MXJSStatelessWidget constructor(
      MXJsonBuildOwner bo, Map<String, dynamic> jsonMap,
      {BuildContext context}) {
    var widget = MXJSStatelessWidget(
        key: mxj2d(bo, jsonMap["key"]),
        name: mxj2d(bo, jsonMap["name"]),
        widgetID: mxj2d(bo, jsonMap["widgetID"]),
        widgetData: jsonMap["widgetData"],
        buildingWidgetDataSeq: mxj2d(bo, jsonMap["buildWidgetDataSeq"]),
        navPushingWidgetID: jsonMap["navPushingWidgetID"],
        parentBuildOwner: bo);
    return widget;
  }
}
