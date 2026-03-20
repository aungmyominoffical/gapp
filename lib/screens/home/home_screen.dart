import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/dynamic_widget_parser.dart';
import 'home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final parser = DynamicWidgetParser(
          actionsRegistry: {
          'getData': (index, item) {
            final f = provider.getData as dynamic;
            try { return Function.apply(f, [index, item]); } catch (_) {}
            try { return Function.apply(f, [index]); } catch (_) {}
            try { return Function.apply(f, [item]); } catch (_) {}
            return Function.apply(f, []);
          },
          'addUser': (index, item) {
            final f = provider.addUser as dynamic;
            try { return Function.apply(f, [index, item]); } catch (_) {}
            try { return Function.apply(f, [index]); } catch (_) {}
            try { return Function.apply(f, [item]); } catch (_) {}
            return Function.apply(f, []);
          },
          },
          stateAccessor: {
          'userLists': () => provider.userLists,
          'navArgs': () => ModalRoute.of(context)?.settings.arguments,
          },
          context: context,
        );

        return parser.parse(_widgetJson);
      },
    );
  }
}

final Map<String, dynamic> _widgetJson = {
    "widget": "Scaffold",
    "backgroundColor": "#FFFFFF",
    "floatingActionButtonLocation": "endFloat",
    "resizeToAvoidBottomInset": true,
    "primary": true,
    "extendBody": false,
    "extendBodyBehindAppBar": false,
    "body": {
      "widget": "Padding",
      "padding": {
        "all": 20
      },
      "child": {
        "widget": "ListView",
        "dataSource": "@@state:userLists@@",
        "scrollDirection": "vertical",
        "padding": {
          "all": 8
        },
        "itemSpacing": 8,
        "dataFields": [
          "email"
        ],
        "itemTemplate": {
          "widget": "Text",
          "data": "@@binding:item.email@@",
          "maxLines": 1,
          "style": {
            "fontSize": 16,
            "fontWeight": "400",
            "color": "#000000",
            "textAlign": "left"
          }
        }
      }
    },
    "appBar": {
      "widget": "AppBar",
      "title": "Title",
      "color": "#FFFFFF",
      "textColor": "#000000",
      "centerTitle": false,
      "children": []
    },
    "floatingActionButton": {
      "widget": "FloatingActionButton",
      "onPressed": "@@function:addUser@@",
      "icon": "add",
      "size": 18,
      "mini": false,
      "color": "#2196F3",
      "textColor": "#FFFFFF"
    }
  };
