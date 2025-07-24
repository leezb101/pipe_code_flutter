/*
 * @Author: LeeZB
 * @Date: 2025-07-24 08:54:14
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 08:58:14
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:go_router/go_router.dart';

extension GoRouterPopuntil on GoRouter {
  void popUntil({required bool Function(GoRoute route) predicate}) {
    var routes = routerDelegate.currentConfiguration.routes;
    var route = routerDelegate.currentConfiguration.routes.last;

    while (routerDelegate.canPop()) {
      final cIndex = routes.indexOf(route);

      if (routes.elementAt(cIndex - 1) is ShellRoute) {
        routerDelegate.currentConfiguration.matches.removeLast();
      }

      if (route is GoRoute) {
        if (predicate(route)) break;
        if (!routerDelegate.canPop()) break;
        routerDelegate.pop();
      }

      routes = routerDelegate.currentConfiguration.routes;
      route = routes.last;
    }
  }
}
