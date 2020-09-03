//  MXFlutterFramework
//  Copyright 2019 The MXFlutter Authors. All rights reserved.
//
//  Use of this source code is governed by a MIT-style license that can be
//  found in the LICENSE file.

import 'package:mxflutter/src/mirror/mx_mirror.dart';
import 'package:flutter/src/widgets/route_notification_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

///把自己能处理的类注册到分发器中
Map<String, MXFunctionInvoke> registerRouteNotificationMessagesSeries() {
  var m = <String, MXFunctionInvoke>{};
  m[_routeNotificationMessagesMaybeNotifyRouteChange.funName] =
      _routeNotificationMessagesMaybeNotifyRouteChange;
  return m;
}

var _routeNotificationMessagesMaybeNotifyRouteChange = MXFunctionInvoke(
  "RouteNotificationMessages.maybeNotifyRouteChange",
  ({
    String routeName,
    String previousRouteName,
  }) =>
      RouteNotificationMessages.maybeNotifyRouteChange(
    routeName,
    previousRouteName,
  ),
  [
    "routeName",
    "previousRouteName",
  ],
);