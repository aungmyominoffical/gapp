import 'package:flutter/material.dart';

class DynamicWidgetParser {
  final Map<String, Function> actionsRegistry;
  final Map<String, dynamic Function()> stateAccessor;
  final BuildContext? context;

  DynamicWidgetParser({
    required this.actionsRegistry,
    this.stateAccessor = const {},
    this.context,
  });

  static const double _breakpointTablet = 600;
  static const double _breakpointDesktop = 1200;

  double _responsiveNum(dynamic value, double defaultVal) {
    if (value == null) return defaultVal;
    if (value is num) return value.toDouble();
    if (value is Map) {
      final w = context != null ? MediaQuery.of(context!).size.width : 600.0;
      if (w < _breakpointTablet) return (value['mobile'] as num?)?.toDouble() ?? defaultVal;
      if (w < _breakpointDesktop) return (value['tablet'] as num?)?.toDouble() ?? defaultVal;
      return (value['desktop'] as num?)?.toDouble() ?? defaultVal;
    }
    return defaultVal;
  }

  int _responsiveInt(dynamic value, int defaultVal) {
    if (value == null) return defaultVal;
    if (value is num) return value.toInt();
    if (value is Map) {
      final w = context != null ? MediaQuery.of(context!).size.width : 600.0;
      if (w < _breakpointTablet) return (value['mobile'] as num?)?.toInt() ?? defaultVal;
      if (w < _breakpointDesktop) return (value['tablet'] as num?)?.toInt() ?? defaultVal;
      return (value['desktop'] as num?)?.toInt() ?? defaultVal;
    }
    return defaultVal;
  }

  VoidCallback? _resolveActionWithContext(
    dynamic value, {
    int? index,
    Map<String, dynamic>? item,
  }) {
    if (value == null) return null;
    final str = value.toString();
    final match = RegExp(r'@@function:(.+?)@@').firstMatch(str);
    if (match != null) {
      final fnName = match.group(1)!;
      final fn = actionsRegistry[fnName];
      if (fn != null) {
        return () {
          try {
            return Function.apply(fn, [index, item]);
          } catch (_) {
            // Fallback for functions that don't accept (index,item)
            return Function.apply(fn, []);
          }
        };
      }
    }
    return null;
  }

  void _invokeActionWithValue(dynamic spec, dynamic value) {
    if (spec == null) return;
    final str = spec.toString();
    final match = RegExp(r'@@function:(.+?)@@').firstMatch(str);
    if (match != null) {
      final fnName = match.group(1)!;
      final fn = actionsRegistry[fnName];
      if (fn != null) {
        try {
          // Treat value as "index" for the registry function
          Function.apply(fn, [value, null]);
          return;
        } catch (_) {
          try {
            Function.apply(fn, [null, value]);
            return;
          } catch (_) {
            try {
              Function.apply(fn, [value]);
              return;
            } catch (_) {
              try {
                Function.apply(fn, [null, null]);
                return;
              } catch (_) {
                return;
              }
            }
          }
        }
      }
    }
  }

  Widget parse(Map<String, dynamic> json) {
    final String widgetType = json['widget'] ?? 'SizedBox';

    switch (widgetType) {
      case 'Container':
        return _buildContainer(json);
      case 'Column':
        return _buildColumn(json);
      case 'Row':
        return _buildRow(json);
      case 'Padding':
        return _buildPadding(json);
      case 'Center':
        return _buildCenter(json);
      case 'Align':
        return _buildAlign(json);
      case 'Stack':
        return _buildStack(json);
      case 'Wrap':
        return _buildWrap(json);
      case 'SafeArea':
        return _buildSafeArea(json);
      case 'Scaffold':
        return _buildScaffold(json);
      case 'AppBar':
        return _buildAppBar(json);
      case 'TabBar':
        return _buildTabBar(json);
      case 'NavigationBar':
        return _buildNavigationBar(json);
      case 'NavigationRail':
        return _buildNavigationRail(json);
      case 'Text':
        return _buildText(json);
      case 'ElevatedButton':
        return _buildElevatedButton(json);
      case 'Icon':
        return _buildIcon(json);
      case 'FloatingActionButton':
        return _buildFloatingActionButton(json);
      case 'ExtendedFloatingActionButton':
        return _buildExtendedFloatingActionButton(json);
      case 'IconButton':
        return _buildIconButton(json);
      case 'Image':
        return _buildImage(json);
      case 'TextField':
        return _buildTextField(json);
      case 'Switch':
        return _buildSwitch(json);
      case 'Checkbox':
        return _buildCheckbox(json);
      case 'Slider':
        return _buildSlider(json);
      case 'Card':
        return _buildCard(json);
      case 'SizedBox':
        return _buildSizedBox(json);
      case 'Divider':
        return _buildDivider(json);
      case 'CircularProgressIndicator':
        return _buildCircularProgressIndicator(json);
      case 'LinearProgressIndicator':
        return _buildLinearProgressIndicator(json);
      case 'ListTile':
        return _buildListTile(json);
      case 'Badge':
        return _buildBadge(json);
      case 'AlertDialog':
        return _buildAlertDialog(json);
      case 'SnackBar':
        return _buildSnackBar(json);
      case 'BottomSheet':
        return _buildBottomSheet(json);
      case 'ListView':
        return _buildListView(json);
      case 'GridView':
        return _buildGridView(json);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Layout Widgets ---

  Widget _buildContainer(Map<String, dynamic> json) {
    final colorVal = _resolveStateString(json['color']);
    final width = json['width'] != null ? _responsiveNum(json['width'], 0) : null;
    final height = json['height'] != null ? _responsiveNum(json['height'], 0) : null;
    final br = json['borderRadius'] != null ? _responsiveNum(json['borderRadius'], 0) : null;
    return GestureDetector(
      onTap: _resolveAction(json['onTap']),
      child: Container(
        width: width != null && width > 0 ? width : null,
        height: height != null && height > 0 ? height : null,
        padding: _parsePadding(json['padding']),
        decoration: BoxDecoration(
          color: _parseColor(colorVal),
          borderRadius: br != null && br > 0 ? BorderRadius.circular(br) : null,
        ),
        child: json['child'] != null ? parse(json['child']) : null,
      ),
    );
  }

  Widget _buildColumn(Map<String, dynamic> json) {
    return Column(
      mainAxisAlignment: _parseMainAxisAlignment(json['mainAxisAlignment']),
      crossAxisAlignment: _parseCrossAxisAlignment(json['crossAxisAlignment']),
      children: _parseChildren(json['children']),
    );
  }

  Widget _buildRow(Map<String, dynamic> json) {
    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(json['mainAxisAlignment']),
      crossAxisAlignment: _parseCrossAxisAlignment(json['crossAxisAlignment']),
      children: _parseChildren(json['children']),
    );
  }

  Widget _buildCard(Map<String, dynamic> json) {
    final elevation = json['elevation'] != null ? _responsiveNum(json['elevation'], 0) : null;
    final borderRadius = json['borderRadius'] != null ? _responsiveNum(json['borderRadius'], 0) : null;
    final padding = _parsePadding(json['padding']) ?? const EdgeInsets.all(16);
    return GestureDetector(
      onTap: _resolveAction(json['onTap']),
      child: Card(
        elevation: elevation,
        color: _parseColor(json['color']),
        shape: borderRadius != null && borderRadius > 0
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              )
            : null,
        child: json['child'] != null
            ? Padding(
                padding: padding,
                child: parse(json['child']),
              )
            : null,
      ),
    );
  }

  Widget _buildSizedBox(Map<String, dynamic> json) {
    final w = json['width'] != null ? _responsiveNum(json['width'], 0) : null;
    final h = json['height'] != null ? _responsiveNum(json['height'], 0) : null;
    return SizedBox(
      width: w != null && w > 0 ? w : null,
      height: h != null && h > 0 ? h : null,
      child: json['child'] != null ? parse(json['child']) : null,
    );
  }

  // --- Additional Layout Widgets ---
  Widget _buildPadding(Map<String, dynamic> json) {
    return Padding(
      padding: _parsePadding(json['padding']) ?? EdgeInsets.zero,
      child: json['child'] != null ? parse(json['child']) : const SizedBox.shrink(),
    );
  }

  Widget _buildCenter(Map<String, dynamic> json) {
    return Center(
      child: json['child'] != null ? parse(json['child']) : const SizedBox.shrink(),
    );
  }

  Widget _buildAlign(Map<String, dynamic> json) {
    final x = (json['alignmentX'] as num?)?.toDouble() ?? 0.0;
    final y = (json['alignmentY'] as num?)?.toDouble() ?? 0.0;
    return Align(
      alignment: Alignment(x, y),
      child: json['child'] != null ? parse(json['child']) : const SizedBox.shrink(),
    );
  }

  Widget _buildStack(Map<String, dynamic> json) {
    return Stack(
      children: _parseChildren(json['children']),
    );
  }

  Widget _buildWrap(Map<String, dynamic> json) {
    return Wrap(
      spacing: _responsiveNum(json['spacing'], 0),
      runSpacing: _responsiveNum(json['runSpacing'], 0),
      children: _parseChildren(json['children']),
    );
  }

  Widget _buildSafeArea(Map<String, dynamic> json) {
    return SafeArea(
      child: json['child'] != null ? parse(json['child']) : const SizedBox.shrink(),
    );
  }

  // --- Scaffold ---
  Widget _buildScaffold(Map<String, dynamic> json) {
    final bodyJson = json['body'];
    final body = bodyJson != null && bodyJson is Map<String, dynamic>
        ? parse(bodyJson as Map<String, dynamic>)
        : const SizedBox.shrink();

    PreferredSizeWidget? appBar;
    if (json['appBar'] != null && json['appBar'] is Map<String, dynamic>) {
      appBar = _buildAppBarPreferred(json['appBar'] as Map<String, dynamic>);
    }

    Widget? floatingActionButton;
    if (json['floatingActionButton'] != null &&
        json['floatingActionButton'] is Map<String, dynamic>) {
      final fabJson = json['floatingActionButton'] as Map<String, dynamic>;
      final type = fabJson['widget'] ?? 'FloatingActionButton';
      if (type == 'ExtendedFloatingActionButton') {
        floatingActionButton = _buildExtendedFloatingActionButton(fabJson);
      } else {
        floatingActionButton = _buildFloatingActionButton(fabJson);
      }
    }

    Widget? bottomNavigationBar;
    if (json['bottomNavigationBar'] != null &&
        json['bottomNavigationBar'] is Map<String, dynamic>) {
      bottomNavigationBar = parse(json['bottomNavigationBar'] as Map<String, dynamic>);
    }

    Widget? drawer;
    if (json['drawer'] != null && json['drawer'] is Map<String, dynamic>) {
      drawer = parse(json['drawer'] as Map<String, dynamic>);
    }

    final backgroundColor = _parseColor(_resolveStateString(json['backgroundColor']));
    final fabLocation = _parseFloatingActionButtonLocation(
        json['floatingActionButtonLocation']);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: json['resizeToAvoidBottomInset'] ?? true,
      primary: json['primary'] ?? true,
      extendBody: json['extendBody'] ?? false,
      extendBodyBehindAppBar: json['extendBodyBehindAppBar'] ?? false,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: fabLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }

  PreferredSizeWidget _buildAppBarPreferred(Map<String, dynamic> json) {
    final title = _resolveStateString(json['title']) ?? '';
    final bg = _parseColor(json['color']) ?? Colors.white;
    final fg = _parseColor(json['textColor']) ?? Colors.black;
    final centerTitle = json['centerTitle'] == true;

    final actions = (json['children'] as List?)
            ?.map((c) => c is Map<String, dynamic> ? parse(c) : const SizedBox.shrink())
            .toList() ??
        [];

    return AppBar(
      title: Text(title),
      backgroundColor: bg,
      foregroundColor: fg,
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  FloatingActionButtonLocation _parseFloatingActionButtonLocation(dynamic value) {
    switch (value?.toString()) {
      case 'startFloat': return FloatingActionButtonLocation.startFloat;
      case 'centerFloat': return FloatingActionButtonLocation.centerFloat;
      case 'endFloat': return FloatingActionButtonLocation.endFloat;
      case 'startTop': return FloatingActionButtonLocation.startTop;
      case 'centerTop': return FloatingActionButtonLocation.centerTop;
      case 'endTop': return FloatingActionButtonLocation.endTop;
      case 'miniStartTop': return FloatingActionButtonLocation.miniStartTop;
      case 'miniCenterTop': return FloatingActionButtonLocation.miniCenterTop;
      case 'miniEndTop': return FloatingActionButtonLocation.miniEndTop;
      default: return FloatingActionButtonLocation.endFloat;
    }
  }

  // --- Navigation UI Widgets ---
  Widget _buildAppBar(Map<String, dynamic> json) {
    final title = _resolveStateString(json['title']) ?? '';
    final bg = _parseColor(json['color']) ?? Colors.white;
    final fg = _parseColor(json['textColor']) ?? Colors.black;
    final centerTitle = json['centerTitle'] == true;

    final actions = (json['children'] as List?)
            ?.map((c) => c is Map<String, dynamic> ? parse(c) : const SizedBox.shrink())
            .toList() ??
        [];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (!centerTitle) ...actions,
        ],
      ),
    );
  }

  Widget _buildTabBar(Map<String, dynamic> json) {
    final selectedIndex = (json['selectedIndex'] as num?)?.toInt() ?? 0;
    final active = _parseColor(json['color']) ?? Colors.blue;
    final fg = _parseColor(json['textColor']) ?? Colors.black;
    final tabs = (json['children'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(tabs.length, (i) {
          final child = tabs[i] is Map<String, dynamic>
              ? parse(tabs[i] as Map<String, dynamic>)
              : const SizedBox.shrink();
          return GestureDetector(
            onTap: _resolveActionWithContext(json['onTap'], index: i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: i == selectedIndex
                    ? active.withOpacity(0.12)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: i == selectedIndex
                        ? active
                        : Colors.transparent,
                  ),
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: i == selectedIndex ? fg : Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                child: child,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationBar(Map<String, dynamic> json) {
    final selectedIndex = (json['selectedIndex'] as num?)?.toInt() ?? 0;
    final bg = _parseColor(json['color']) ?? Colors.white;
    final active = _parseColor(json['activeColor']) ?? Colors.blue;
    final items = (json['children'] as List?) ?? [];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final child = items[i] is Map<String, dynamic>
              ? parse(items[i] as Map<String, dynamic>)
              : const SizedBox.shrink();
          return Expanded(
            child: GestureDetector(
              onTap: _resolveActionWithContext(json['onTap'], index: i),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: i == selectedIndex ? active : Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationRail(Map<String, dynamic> json) {
    final selectedIndex = (json['selectedIndex'] as num?)?.toInt() ?? 0;
    final bg = _parseColor(json['color']) ?? Colors.white;
    final active = _parseColor(json['activeColor']) ?? Colors.blue;
    final items = (json['children'] as List?) ?? [];

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(items.length, (i) {
          final child = items[i] is Map<String, dynamic>
              ? parse(items[i] as Map<String, dynamic>)
              : const SizedBox.shrink();
          return GestureDetector(
            onTap: _resolveActionWithContext(json['onTap'], index: i),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == selectedIndex ? active.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: i == selectedIndex ? active : Colors.black.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                child: child,
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- Display Widgets ---

  Widget _buildText(Map<String, dynamic> json, {Map<String, dynamic>? item}) {
    final style = json['style'] as Map<String, dynamic>?;
    final rawData = json['data'] ?? '';
    String data;
    if (item != null) {
      data = _resolveBindings(rawData, item);
    } else {
      data = _resolveStateString(rawData) ?? '';
    }

    final maxLines = (json['maxLines'] as num?)?.toInt();
    final fontSize = style?['fontSize'] != null ? _responsiveNum(style!['fontSize'], 16) : null;

    return Text(
      data,
      textAlign: _parseTextAlign(style?['textAlign']),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: _parseFontWeight(style?['fontWeight']),
        color: _parseColor(style?['color']),
      ),
    );
  }

  Widget _buildIcon(Map<String, dynamic> json, {Map<String, dynamic>? item}) {
    final rawIcon = json['icon'] ?? 'star';
    final iconName = item != null ? _resolveBindings(rawIcon, item) : rawIcon.toString();

    return Icon(
      _parseIconData(iconName),
      size: (json['size'] as num?)?.toDouble(),
      color: _parseColor(json['color']),
    );
  }

  Widget _buildFloatingActionButton(Map<String, dynamic> json) {
    final iconName = _resolveStateString(json['icon']) ?? 'add';
    final mini = json['mini'] == true;
    final iconSize = (json['size'] as num?)?.toDouble() ?? 18;

    return FloatingActionButton(
      mini: mini,
      onPressed: _resolveAction(json['onPressed']),
      backgroundColor: _parseColor(_resolveStateString(json['color'])),
      foregroundColor: _parseColor(_resolveStateString(json['textColor'])),
      child: Icon(
        _parseIconData(iconName),
        size: iconSize,
      ),
    );
  }

  Widget _buildExtendedFloatingActionButton(Map<String, dynamic> json) {
    final iconName = _resolveStateString(json['icon']) ?? 'add';
    final label = _resolveStateString(json['label']) ?? 'Action';
    final iconSize = (json['size'] as num?)?.toDouble() ?? 18;

    return FloatingActionButton.extended(
      onPressed: _resolveAction(json['onPressed']),
      backgroundColor: _parseColor(_resolveStateString(json['color'])),
      foregroundColor: _parseColor(_resolveStateString(json['textColor'])),
      icon: Icon(_parseIconData(iconName), size: iconSize),
      label: Text(label),
    );
  }

  Widget _buildIconButton(Map<String, dynamic> json) {
    final iconName = _resolveStateString(json['icon']) ?? 'star';
    final iconSize = (json['size'] as num?)?.toDouble() ?? 20;

    return IconButton(
      onPressed: _resolveAction(json['onPressed']),
      icon: Icon(_parseIconData(iconName), size: iconSize),
      color: _parseColor(_resolveStateString(json['color'])),
    );
  }

  Widget _buildLinearProgressIndicator(Map<String, dynamic> json) {
    final rawVal = json['value'];
    final resolved = _resolveStateDynamic(rawVal);
    final val = resolved is num
        ? resolved.toDouble()
        : double.tryParse(resolved?.toString() ?? '') ?? 0.5;
    final minHeight = (json['minHeight'] as num?)?.toDouble() ?? 6.0;
    final color = _parseColor(_resolveStateString(json['color']));

    return SizedBox(
      height: minHeight,
      width: double.infinity,
      child: LinearProgressIndicator(
        value: val,
        color: color,
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> json) {
    final rawLabel = json['label'] ?? '';
    final label = _resolveStateString(rawLabel) ?? '';

    return Badge(
      label: Text(label),
      backgroundColor:
          _parseColor(_resolveStateString(json['color'])) ?? Colors.red,
      textColor: _parseColor(_resolveStateString(json['textColor'])) ?? Colors.white,
      child: json['child'] != null
          ? parse(json['child'])
          : const SizedBox.shrink(),
    );
  }

  Widget _buildAlertDialog(
    Map<String, dynamic> json, {
    Map<String, dynamic>? item,
    int? index,
  }) {
    final title = _resolveStateString(json['title']) ?? '';
    final content = _resolveStateString(json['content']) ?? '';
    final okText = _resolveStateString(json['okText']) ?? 'OK';
    final cancelText = _resolveStateString(json['cancelText']) ?? 'Cancel';

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed:
              _resolveActionWithContext(json['onCancel'], index: index, item: item),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed:
              _resolveActionWithContext(json['onOk'], index: index, item: item),
          child: Text(okText),
        ),
      ],
    );
  }

  Widget _buildSnackBar(
    Map<String, dynamic> json, {
    Map<String, dynamic>? item,
    int? index,
  }) {
    final message = _resolveStateString(json['message']) ?? '';
    final actionLabel = _resolveStateString(json['actionLabel']) ?? '';
    final durationMs =
        (json['durationMs'] as num?)?.toInt() ?? 3000;
    final onAction = _resolveActionWithContext(json['onAction'], index: index, item: item);

    return _SnackBarOnce(
      message: message,
      actionLabel: actionLabel,
      durationMs: durationMs,
      onAction: onAction,
    );
  }

  Widget _buildBottomSheet(Map<String, dynamic> json) {
    final child = json['child'] != null ? parse(json['child']) : const SizedBox.shrink();
    return _BottomSheetOnce(child: child);
  }

  Widget _buildImage(Map<String, dynamic> json, {Map<String, dynamic>? item}) {
    final rawUrl = json['url'] ?? '';
    String url;
    if (item != null) {
      url = _resolveBindings(rawUrl, item);
    } else {
      url = _resolveStateString(rawUrl) ?? '';
    }
    final w = json['width'] != null ? _responsiveNum(json['width'], 0) : null;
    final h = json['height'] != null ? _responsiveNum(json['height'], 0) : null;
    final radius = json['borderRadius'] != null ? _responsiveNum(json['borderRadius'], 0) : null;

    Widget image = Image.network(
      url,
      width: w != null && w > 0 ? w : null,
      height: h != null && h > 0 ? h : null,
      fit: _parseBoxFit(json['fit']),
      errorBuilder: (_, __, ___) => SizedBox(
        width: w != null && w > 0 ? w : null,
        height: h != null && h > 0 ? h : null,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );

    if (radius != null && radius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }

    return GestureDetector(
      onTap: _resolveAction(json['onTap']),
      child: image,
    );
  }

  Widget _buildDivider(Map<String, dynamic> json) {
    return Divider(
      height: (json['height'] as num?)?.toDouble(),
      thickness: (json['thickness'] as num?)?.toDouble(),
      color: _parseColor(json['color']),
    );
  }

  Widget _buildCircularProgressIndicator(Map<String, dynamic> json) {
    final size = (json['size'] as num?)?.toDouble() ?? 36;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 4,
        color: _parseColor(json['color']),
      ),
    );
  }

  Widget _buildListTile(
    Map<String, dynamic> json, {
    Map<String, dynamic>? item,
    int? index,
  }) {
    final rawTitle = json['title'] ?? '';
    final rawSubtitle = json['subtitle'] ?? '';
    String title;
    String subtitle;
    if (item != null) {
      title = _resolveBindings(rawTitle, item);
      subtitle = _resolveBindings(rawSubtitle, item);
    } else {
      title = _resolveStateString(rawTitle) ?? '';
      subtitle = _resolveStateString(rawSubtitle) ?? '';
    }

    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      leading: json['leadingIcon'] != null &&
              json['leadingIcon'].toString().isNotEmpty
          ? Icon(_parseIconData(json['leadingIcon']))
          : null,
      trailing: json['trailingIcon'] != null &&
              json['trailingIcon'].toString().isNotEmpty
          ? Icon(_parseIconData(json['trailingIcon']))
          : null,
      onTap: _resolveActionWithContext(
        json['onTap'],
        index: index,
        item: item,
      ),
    );
  }

  // --- Input Widgets ---

  Widget _buildElevatedButton(Map<String, dynamic> json) {
    final style = json['style'] as Map<String, dynamic>?;
    final padding = json['padding'] != null ? _responsiveNum(json['padding'], 0) : null;
    final borderRadius = json['borderRadius'] != null ? _responsiveNum(json['borderRadius'], 0) : null;
    return ElevatedButton(
      onPressed: _resolveAction(json['onPressed']),
      onLongPress: _resolveAction(json['onLongPress']),
      style: ElevatedButton.styleFrom(
        backgroundColor: _parseColor(style?['backgroundColor']),
        padding: padding != null && padding > 0 ? EdgeInsets.all(padding) : null,
        shape: borderRadius != null && borderRadius > 0
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))
            : null,
      ),
      child: json['child'] != null ? parse(json['child']) : const SizedBox.shrink(),
    );
  }

  Widget _buildTextField(Map<String, dynamic> json) {
    final hintText = _resolveStateString(json['hintText']) ?? '';
    final labelText = _resolveStateString(json['labelText']) ?? '';
    final obscure = json['obscureText'] == true;

    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hintText.isNotEmpty ? hintText : null,
        labelText: labelText.isNotEmpty ? labelText : null,
        border: const OutlineInputBorder(),
      ),
      onSubmitted: json['onSubmitted'] != null
          ? (value) => _invokeActionWithValue(json['onSubmitted'], value)
          : null,
    );
  }

  Widget _buildSwitch(Map<String, dynamic> json) {
    final rawVal = json['value'];
    final resolved = _resolveStateDynamic(rawVal);
    final boolVal = resolved is bool ? resolved : (resolved == true || resolved == 'true');

    return Switch(
      value: boolVal,
      activeColor: _parseColor(json['activeColor']),
      onChanged: json['onChanged'] != null
          ? (value) => _invokeActionWithValue(json['onChanged'], value)
          : null,
    );
  }

  Widget _buildCheckbox(Map<String, dynamic> json) {
    final rawVal = json['value'];
    final resolved = _resolveStateDynamic(rawVal);
    final boolVal = resolved is bool ? resolved : (resolved == true || resolved == 'true');

    return Checkbox(
      value: boolVal,
      activeColor: _parseColor(json['activeColor']),
      onChanged: json['onChanged'] != null
          ? (value) => _invokeActionWithValue(json['onChanged'], value)
          : null,
    );
  }

  Widget _buildSlider(Map<String, dynamic> json) {
    final rawVal = json['value'];
    final resolved = _resolveStateDynamic(rawVal);
    final doubleVal = resolved is num ? resolved.toDouble() : 0.5;

    return Slider(
      value: doubleVal,
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 1,
      activeColor: _parseColor(json['activeColor']),
      onChanged: json['onChanged'] != null
          ? (value) => _invokeActionWithValue(json['onChanged'], value)
          : null,
    );
  }

  // --- Dynamic List Widgets ---

  Widget _buildListView(Map<String, dynamic> json) {
    final dataList = _resolveStateList(json['dataSource']);
    final template = json['itemTemplate'] as Map<String, dynamic>?;
    final scrollDirection = json['scrollDirection'] == 'horizontal'
        ? Axis.horizontal
        : Axis.vertical;
    final padding = _parsePadding(json['padding']);
    final itemSpacing = _responsiveNum(json['itemSpacing'], 0);

    if (template == null || dataList == null || dataList.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      scrollDirection: scrollDirection,
      padding: padding,
      itemCount: dataList.length,
      separatorBuilder: (_, __) => SizedBox(
        width: scrollDirection == Axis.horizontal ? itemSpacing : 0,
        height: scrollDirection == Axis.vertical ? itemSpacing : 0,
      ),
      itemBuilder: (context, index) {
        final item = dataList[index] is Map<String, dynamic>
            ? dataList[index] as Map<String, dynamic>
            : <String, dynamic>{'value': dataList[index]};
        return _parseWithBindings(template, item, index: index);
      },
    );
  }

  Widget _buildGridView(Map<String, dynamic> json) {
    final dataList = _resolveStateList(json['dataSource']);
    final template = json['itemTemplate'] as Map<String, dynamic>?;
    final crossAxisCount = _responsiveInt(json['crossAxisCount'], 2);
    final mainAxisSpacing = _responsiveNum(json['mainAxisSpacing'], 0);
    final crossAxisSpacing = _responsiveNum(json['crossAxisSpacing'], 0);
    final padding = _parsePadding(json['padding']);

    if (template == null || dataList == null || dataList.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index] is Map<String, dynamic>
            ? dataList[index] as Map<String, dynamic>
            : <String, dynamic>{'value': dataList[index]};
        return _parseWithBindings(template, item, index: index);
      },
    );
  }

  // --- Binding Dispatch (inside ListView/GridView) ---

  Widget _parseWithBindings(Map<String, dynamic> json, Map<String, dynamic> item, {int? index}) {
    final String widgetType = json['widget'] ?? 'SizedBox';

    switch (widgetType) {
      case 'Scaffold':
        return _buildScaffold(json);
      case 'Text':
        return _buildText(json, item: item);
      case 'Icon':
        return _buildIcon(json, item: item);
      case 'Image':
        return _buildImage(json, item: item);
      case 'FloatingActionButton': {
        final iconName = _resolveStateString(_resolveBindings(json['icon'], item)) ?? 'add';
        final mini = json['mini'] == true;
        final iconSize = (json['size'] as num?)?.toDouble() ?? 18;
        return FloatingActionButton(
          mini: mini,
          onPressed: _resolveActionWithContext(json['onPressed'], index: index, item: item),
          backgroundColor: _parseColor(_resolveStateString(json['color'])),
          foregroundColor: _parseColor(_resolveStateString(json['textColor'])),
          child: Icon(
            _parseIconData(iconName),
            size: iconSize,
          ),
        );
      }
      case 'ExtendedFloatingActionButton': {
        final iconName = _resolveStateString(_resolveBindings(json['icon'], item)) ?? 'add';
        final labelRaw = json['label'] ?? '';
        final resolvedLabel = _resolveStateString(_resolveBindings(labelRaw, item)) ?? 'Action';
        final iconSize = (json['size'] as num?)?.toDouble() ?? 18;
        return FloatingActionButton.extended(
          onPressed: _resolveActionWithContext(json['onPressed'], index: index, item: item),
          backgroundColor: _parseColor(_resolveStateString(json['color'])),
          foregroundColor: _parseColor(_resolveStateString(json['textColor'])),
          icon: Icon(_parseIconData(iconName), size: iconSize),
          label: Text(resolvedLabel),
        );
      }
      case 'IconButton': {
        final iconName = _resolveStateString(_resolveBindings(json['icon'], item)) ?? 'star';
        final iconSize = (json['size'] as num?)?.toDouble() ?? 20;
        return IconButton(
          onPressed: _resolveActionWithContext(json['onPressed'], index: index, item: item),
          icon: Icon(_parseIconData(iconName), size: iconSize),
          color: _parseColor(_resolveStateString(json['color'])),
        );
      }
      case 'LinearProgressIndicator': {
        final rawVal = json['value'];
        final resolvedVal = _resolveStateDynamic(_resolveBindings(rawVal, item));
        final doubleVal =
            resolvedVal is num ? resolvedVal.toDouble() : double.tryParse(resolvedVal.toString()) ?? 0.5;
        final minHeight = (json['minHeight'] as num?)?.toDouble() ?? 6.0;
        return SizedBox(
          height: minHeight,
          width: double.infinity,
          child: LinearProgressIndicator(
            value: doubleVal,
            color: _parseColor(_resolveStateString(json['color'])),
          ),
        );
      }
      case 'Badge': {
        final rawLabel = json['label'] ?? '';
        final label = _resolveStateString(_resolveBindings(rawLabel, item)) ?? '';
        final childWidget = json['child'] != null ? _parseWithBindings(json['child'], item, index: index) : const SizedBox.shrink();
        return Badge(
          label: Text(label),
          backgroundColor: _parseColor(_resolveStateString(json['color'])),
          textColor: _parseColor(_resolveStateString(json['textColor'])),
          child: childWidget,
        );
      }
      case 'AlertDialog':
        return _buildAlertDialog(json);
      case 'SnackBar':
        return _buildSnackBar(json);
      case 'BottomSheet':
        return _buildBottomSheet(json);
      case 'ListTile':
        return _buildListTile(json, item: item, index: index);
      case 'Container':
        return GestureDetector(
          onTap: _resolveActionWithContext(json['onTap'], index: index, item: item),
          child: Container(
            width: (json['width'] as num?)?.toDouble(),
            height: (json['height'] as num?)?.toDouble(),
            padding: _parsePadding(json['padding']),
            decoration: BoxDecoration(
              color: _parseColor(_resolveBindings(json['color'], item)),
              borderRadius: json['borderRadius'] != null
                  ? BorderRadius.circular((json['borderRadius'] as num).toDouble())
                  : null,
            ),
            child: json['child'] != null
                ? _parseWithBindings(json['child'], item)
                : null,
          ),
        );
      case 'Card':
        return GestureDetector(
          onTap: _resolveActionWithContext(json['onTap'], index: index, item: item),
          child: Card(
            elevation: (json['elevation'] as num?)?.toDouble(),
            color: _parseColor(json['color']),
            shape: json['borderRadius'] != null
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      (json['borderRadius'] as num).toDouble(),
                    ),
                  )
                : null,
            child: json['child'] != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: _parseWithBindings(json['child'], item),
                  )
                : null,
          ),
        );
      case 'Column':
        return Column(
          mainAxisAlignment: _parseMainAxisAlignment(json['mainAxisAlignment']),
          crossAxisAlignment: _parseCrossAxisAlignment(json['crossAxisAlignment']),
          children: (json['children'] as List?)
              ?.map((c) => c is Map<String, dynamic>
                  ? _parseWithBindings(c, item)
                  : const SizedBox.shrink())
              .toList() ?? [],
        );
      case 'Row':
        return Row(
          mainAxisAlignment: _parseMainAxisAlignment(json['mainAxisAlignment']),
          crossAxisAlignment: _parseCrossAxisAlignment(json['crossAxisAlignment']),
          children: (json['children'] as List?)
              ?.map((c) => c is Map<String, dynamic>
                  ? _parseWithBindings(c, item)
                  : const SizedBox.shrink())
              .toList() ?? [],
        );
      case 'Padding':
        return Padding(
          padding: _parsePadding(json['padding']) ?? EdgeInsets.zero,
          child: json['child'] != null
              ? _parseWithBindings(json['child'], item, index: index)
              : const SizedBox.shrink(),
        );
      case 'Center':
        return Center(
          child: json['child'] != null
              ? _parseWithBindings(json['child'], item, index: index)
              : const SizedBox.shrink(),
        );
      case 'Align':
        {
          final x = (json['alignmentX'] as num?)?.toDouble() ?? 0.0;
          final y = (json['alignmentY'] as num?)?.toDouble() ?? 0.0;
          return Align(
            alignment: Alignment(x, y),
            child: json['child'] != null
                ? _parseWithBindings(json['child'], item, index: index)
                : const SizedBox.shrink(),
          );
        }
      case 'Stack':
        return Stack(
          children: (json['children'] as List?)
                  ?.map((c) => c is Map<String, dynamic>
                      ? _parseWithBindings(c, item, index: index)
                      : const SizedBox.shrink())
                  .toList() ??
              [],
        );
      case 'Wrap':
        return Wrap(
          spacing: (json['spacing'] as num?)?.toDouble() ?? 0.0,
          runSpacing: (json['runSpacing'] as num?)?.toDouble() ?? 0.0,
          children: (json['children'] as List?)
                  ?.map((c) => c is Map<String, dynamic>
                      ? _parseWithBindings(c, item, index: index)
                      : const SizedBox.shrink())
                  .toList() ??
              [],
        );
      case 'SafeArea':
        return SafeArea(
          child: json['child'] != null
              ? _parseWithBindings(json['child'], item, index: index)
              : const SizedBox.shrink(),
        );
      case 'AppBar': {
        final titleRaw = json['title'] ?? '';
        final title = _resolveBindings(titleRaw, item);
        final bg = _parseColor(_resolveBindings(json['color'], item)) ?? Colors.white;
        final fg = _parseColor(_resolveBindings(json['textColor'], item)) ?? Colors.black;
        final centerTitle = json['centerTitle'] == true;

        final actions = (json['children'] as List?)
                ?.map((c) => c is Map<String, dynamic>
                    ? _parseWithBindings(c, item, index: index)
                    : const SizedBox.shrink())
                .toList() ??
            [];

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                ),
              ),
              if (!centerTitle) ...actions,
            ],
          ),
        );
      }
      case 'TabBar': {
        final selectedIndex = (json['selectedIndex'] as num?)?.toInt() ?? 0;
        final active = _parseColor(_resolveBindings(json['color'], item)) ?? Colors.blue;
        final fg = _parseColor(_resolveBindings(json['textColor'], item)) ?? Colors.black;
        final tabs = (json['children'] as List?) ?? [];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(tabs.length, (i) {
              final child = tabs[i] is Map<String, dynamic>
                  ? _parseWithBindings(tabs[i] as Map<String, dynamic>, item, index: index)
                  : const SizedBox.shrink();
              return GestureDetector(
                onTap: _resolveActionWithContext(json['onTap'], index: i, item: item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? active.withOpacity(0.12) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: i == selectedIndex ? active : Colors.transparent,
                      ),
                    ),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: i == selectedIndex ? fg : Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    child: child,
                  ),
                ),
              );
            }),
          ),
        );
      }
      case 'NavigationBar': {
        final selectedIndex = (json['selectedIndex'] as num?)?.toInt() ?? 0;
        final bg = _parseColor(_resolveBindings(json['color'], item)) ?? Colors.white;
        final active = _parseColor(_resolveBindings(json['activeColor'], item)) ?? Colors.blue;
        final items = (json['children'] as List?) ?? [];

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final child = items[i] is Map<String, dynamic>
                  ? _parseWithBindings(items[i] as Map<String, dynamic>, item, index: index)
                  : const SizedBox.shrink();
              return Expanded(
                child: GestureDetector(
                  onTap: _resolveActionWithContext(json['onTap'], index: i, item: item),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: i == selectedIndex ? active : Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }
      case 'NavigationRail': {
        final selectedIndex = (json['selectedIndex'] as num?)?.toInt() ?? 0;
        final bg = _parseColor(_resolveBindings(json['color'], item)) ?? Colors.white;
        final active = _parseColor(_resolveBindings(json['activeColor'], item)) ?? Colors.blue;
        final items = (json['children'] as List?) ?? [];

        return Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            border: Border(right: BorderSide(color: Colors.black.withOpacity(0.08))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(items.length, (i) {
              final child = items[i] is Map<String, dynamic>
                  ? _parseWithBindings(items[i] as Map<String, dynamic>, item, index: index)
                  : const SizedBox.shrink();
              return GestureDetector(
                onTap: _resolveActionWithContext(json['onTap'], index: i, item: item),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? active.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: i == selectedIndex ? active : Colors.black.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    child: child,
                  ),
                ),
              );
            }),
          ),
        );
      }
      case 'ElevatedButton':
        return ElevatedButton(
          onPressed: _resolveActionWithContext(json['onPressed'], index: index, item: item),
          onLongPress: _resolveActionWithContext(json['onLongPress'], index: index, item: item),
          style: ElevatedButton.styleFrom(
            backgroundColor: _parseColor((json['style'] as Map<String, dynamic>?)?['backgroundColor']),
          ),
          child: json['child'] != null ? _parseWithBindings(json['child'], item, index: index) : const SizedBox.shrink(),
        );
      case 'Divider':
        return _buildDivider(json);
      case 'SizedBox':
        return _buildSizedBox(json);
      case 'CircularProgressIndicator':
        return _buildCircularProgressIndicator(json);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- State Resolution ---
  dynamic _resolveStateByPath(String varPath) {
    // Supports nested lookups like "navArgs.title"
    final parts = varPath.split('.');
    if (parts.isEmpty) return null;

    final baseVar = parts.first;
    final pathParts = parts.sublist(1);

    final getter = stateAccessor[baseVar];
    if (getter == null) return null;

    dynamic current = getter();
    for (final p in pathParts) {
      if (current == null) return null;
      if (current is Map) {
        final map = current as Map;
        if (!map.containsKey(p)) return null;
        current = map[p];
        continue;
      }
      return null;
    }

    return current;
  }

  String? _resolveStateString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    final match = RegExp(r'@@state:(.+?)@@').firstMatch(str);
    if (match != null) {
      final varPath = match.group(1)!.trim();
      final resolved = _resolveStateByPath(varPath);
      return resolved?.toString() ?? '';
    }
    return str;
  }

  dynamic _resolveStateDynamic(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final match = RegExp(r'@@state:(.+?)@@').firstMatch(value);
      if (match != null) {
        final varPath = match.group(1)!.trim();
        return _resolveStateByPath(varPath);
      }
    }
    return value;
  }

  List<dynamic>? _resolveStateList(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    final match = RegExp(r'@@state:(.+?)@@').firstMatch(str);
    if (match != null) {
      final varPath = match.group(1)!.trim();
      final resolved = _resolveStateByPath(varPath);
      if (resolved is List) return resolved;
    }
    return null;
  }

  String _resolveBindings(dynamic value, Map<String, dynamic>? item) {
    if (value == null) return '';
    final str = value.toString();
    if (item == null) return str;

    return str.replaceAllMapped(
      RegExp(r'@@binding:item\.(\w+)@@'),
      (match) {
        final field = match.group(1)!;
        return item[field]?.toString() ?? '';
      },
    );
  }

  // --- Resolvers ---

  VoidCallback? _resolveAction(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    final match = RegExp(r'@@function:(.+?)@@').firstMatch(str);
    if (match != null) {
      final fnName = match.group(1)!;
      final fn = actionsRegistry[fnName];
      if (fn != null) {
        return () {
          try {
            Function.apply(fn, [null, null]);
          } catch (_) {
            try {
              Function.apply(fn, []);
            } catch (_) {
              // ignore
            }
          }
        };
      }
    }
    return null;
  }

  List<Widget> _parseChildren(dynamic children) {
    if (children is! List) return [];
    return children
        .map((c) => c is Map<String, dynamic> ? parse(c) : const SizedBox.shrink())
        .toList();
  }

  // --- Parsers ---

  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    final hex = value.toString().replaceFirst('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return null;
  }

  EdgeInsets? _parsePadding(dynamic value) {
    if (value == null) return null;
    if (value is Map && value['all'] != null) {
      final all = value['all'];
      final n = all is Map
          ? _responsiveNum(all, 0)
          : (all is num ? all.toDouble() : 0.0);
      return EdgeInsets.all(n);
    }
    return null;
  }

  MainAxisAlignment _parseMainAxisAlignment(dynamic value) {
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(dynamic value) {
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return CrossAxisAlignment.start;
    }
  }

  TextAlign? _parseTextAlign(dynamic value) {
    switch (value) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      default: return null;
    }
  }

  FontWeight? _parseFontWeight(dynamic value) {
    switch (value) {
      case '100': return FontWeight.w100;
      case '200': return FontWeight.w200;
      case '300': return FontWeight.w300;
      case '400': return FontWeight.w400;
      case '500': return FontWeight.w500;
      case '600': return FontWeight.w600;
      case '700': return FontWeight.w700;
      case '800': return FontWeight.w800;
      case '900': return FontWeight.w900;
      default: return null;
    }
  }

  IconData _parseIconData(dynamic value) {
    const iconMap = {
      'star': Icons.star,
      'heart': Icons.favorite,
      'home': Icons.home,
      'settings': Icons.settings,
      'search': Icons.search,
      'add': Icons.add,
      'check': Icons.check,
      'close': Icons.close,
      'menu': Icons.menu,
      'person': Icons.person,
    };
    return iconMap[value?.toString()] ?? Icons.help_outline;
  }

  BoxFit _parseBoxFit(dynamic value) {
    switch (value) {
      case 'cover': return BoxFit.cover;
      case 'contain': return BoxFit.contain;
      case 'fill': return BoxFit.fill;
      case 'fitWidth': return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      case 'scaleDown': return BoxFit.scaleDown;
      default: return BoxFit.cover;
    }
  }
}

class _SnackBarOnce extends StatefulWidget {
  final String message;
  final String actionLabel;
  final int durationMs;
  final VoidCallback? onAction;

  const _SnackBarOnce({
    required this.message,
    required this.actionLabel,
    required this.durationMs,
    this.onAction,
  });

  @override
  State<_SnackBarOnce> createState() => _SnackBarOnceState();
}

class _SnackBarOnceState extends State<_SnackBarOnce> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shown) return;
      _shown = true;

      final hasAction = widget.actionLabel.isNotEmpty && widget.onAction != null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.message),
          duration: Duration(milliseconds: widget.durationMs),
          action: hasAction
              ? SnackBarAction(label: widget.actionLabel, onPressed: widget.onAction!)
              : null,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BottomSheetOnce extends StatefulWidget {
  final Widget child;

  const _BottomSheetOnce({required this.child});

  @override
  State<_BottomSheetOnce> createState() => _BottomSheetOnceState();
}

class _BottomSheetOnceState extends State<_BottomSheetOnce> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shown) return;
      _shown = true;
      showModalBottomSheet(
        context: context,
        builder: (ctx) => widget.child,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
