import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens.dart';

class ShopListRouteConfig {
  final int? id;
  final String? selectedItem;
  final String? selectedRoute;
  final bool show404;

  ShopListRouteConfig.list()
      : selectedRoute = null,
        selectedItem = null,
        show404 = false,
        id = null;

  ShopListRouteConfig.newRoute(this.selectedRoute)
      : selectedItem = null,
        id = null,
        show404 = false;

  ShopListRouteConfig.nestedItemRoute(
      this.selectedRoute, this.selectedItem, this.id)
      : show404 = false;

  ShopListRouteConfig.details(this.selectedItem, this.id)
      : selectedRoute = null,
        show404 = false;

  ShopListRouteConfig.error()
      : selectedRoute = null,
        selectedItem = null,
        show404 = true,
        id = null;

  bool get isListPage => selectedItem == null && selectedRoute == null;

  bool get isDetailsPage => selectedItem != null && selectedRoute == null;

  bool get isNewPage => selectedRoute != null && selectedItem == null;

  bool get isNestedPage => selectedRoute != null && selectedItem != null;
}


class ShopListRouterInformationParser
    extends RouteInformationParser<ShopListRouteConfig> {
  @override
  Future<ShopListRouteConfig> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return ShopListRouteConfig.list();
    }

    // Handle '/items/:itemId'
    // Handle '/route/:itemId'
    if (uri.pathSegments.length == 2) {
      var secondSegment = uri.pathSegments[1];
      var id = int.tryParse(secondSegment);

      if (id == null) return ShopListRouteConfig.error();

      if (uri.pathSegments[0] != 'items') {

        return ShopListRouteConfig.nestedItemRoute(uri.pathSegments[0], 'item $id', id);
      }

      // return example items 0
      return ShopListRouteConfig.details(
          'item $id', id);
    }

    // Handle '/route'
    if (uri.pathSegments.length == 1) {
      if (!routes.contains(uri.pathSegments[0])) {
        return ShopListRouteConfig.error();
      }
      return ShopListRouteConfig.newRoute(uri.pathSegments[0]);
    }


    // Handle /404
    return ShopListRouteConfig.error();
  }

  @override
  RouteInformation? restoreRouteInformation(ShopListRouteConfig configuration) {
    if (configuration.show404) {
      return const RouteInformation(location: '/404');
    }
    if (configuration.isListPage) {
      return const RouteInformation(location: '/');
    }
    if (configuration.isNewPage) {
      return RouteInformation(location: '/${configuration.selectedRoute!}');
    }

    if (configuration.isNestedPage) {
      return RouteInformation(
          location: '/${configuration.selectedRoute!}/${configuration.id}');
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(location: '/items/${configuration.id}');
    }
    return null;
  }
}

class ShopListRouterDelegate extends RouterDelegate<ShopListRouteConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ShopListRouteConfig> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  ShopListRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  String? _selectedItem;
  String? _selectedRoute;
  bool show404 = false;

  // get current route based on the show404 flag and _selectedItem & _selectedRoute value
  @override
  ShopListRouteConfig get currentConfiguration {
    if (show404) {
      return ShopListRouteConfig.error();
    }

    if (_selectedRoute != null && _selectedItem == null) {
      return ShopListRouteConfig.newRoute(_selectedRoute);
    }

    if (_selectedRoute != null && _selectedItem != null) {
      final splitItem = _selectedItem!.split(" ");
      final itemId = int.parse(splitItem[1]);
      return ShopListRouteConfig.nestedItemRoute(
          _selectedRoute, _selectedItem, itemId);
    }

    if (_selectedItem != null) {
      final splitItem = _selectedItem!.split(" ");
      final itemId = int.parse(splitItem[1]);
      return ShopListRouteConfig.details(_selectedItem, itemId);
    }


    return ShopListRouteConfig.list();
  }

  // code same as with pages except it uses notify listeners instead of setState and adds Navigator Key
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('ItemListScreen'),
          child: ItemsListScreen(
            onItemTapped: _handleItemTapped,
            onRouteTapped: _handleRouteTapped,
          ),
        ),
        if (show404)
          const MaterialPage(
            key: ValueKey('Error Page'),
            child: Center(
              child: Text('404'),
            ),
          )
        else if (_selectedItem != null)
          MaterialPage(
            key: ValueKey(_selectedItem!),
            child: ItemDetailsScreen(
              item: _selectedItem!,
            ),
          )
        else if (_selectedRoute != null && _selectedRoute == cartRoute)
          // you can use switch statement if you have multiple routes to check the exact route
          // in this case we have one extra route, cart, hence check added in if statement
            MaterialPage(
              key: ValueKey(_selectedRoute!),
              child: CartScreen(
                onItemTapped: _handleItemTapped,
              ),
            )
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_selectedItem != null && _selectedRoute != null) {
          _selectedItem = null;
          notifyListeners();
          return true;
        }

        _selectedRoute = null;
        _selectedItem = null;
        notifyListeners();

        return true;
      },
    );
  }

  // update app state to set new route based on the configuration set
  @override
  Future<void> setNewRoutePath(ShopListRouteConfig configuration) async {
    isInvalidCartItem(id) => id < 0 || id % 2 != 0 || id >= 10 ;
    if (configuration.show404) {
      _selectedItem = null;
      _selectedRoute = null;
      show404 = true;
      return;
    }

    if (configuration.isDetailsPage) {
      if (configuration.id! >= 10) {
        show404 = true;
        return;
      }
      _selectedItem = configuration.selectedItem;
    }
    else if (configuration.isNewPage) {
      if (configuration.selectedRoute != cartRoute) {
        show404 = true;
        return;
      }
      _selectedRoute = configuration.selectedRoute;
    }
    else if (configuration.isNestedPage) {
      if (isInvalidCartItem(configuration.id!)) {
        show404 = true;
        return;
      }

      _selectedItem = configuration.selectedItem;
      _selectedRoute = configuration.selectedRoute;
    } else {
      _selectedItem = null;
      _selectedRoute = null;
    }

    show404 = false;
  }

  void _handleItemTapped(String item) {
    _selectedItem = item;
    notifyListeners();
  }

  void _handleRouteTapped(String route) {
    _selectedItem = null;
    _selectedRoute = route;
    notifyListeners();
  }
}