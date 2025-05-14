import 'package:flutter/material.dart';
import '../../core/models/ui_model.dart';

/// A factory class that converts dynamic UI component definitions into Flutter widgets
class WidgetFactory {
  /// Main method to convert a UIComponent into a Flutter Widget
  static Widget buildWidget(BuildContext context, UIComponent component) {
    switch (component.type.toLowerCase()) {
      case 'container':
        return _buildContainer(context, component);
      case 'text':
        return _buildText(context, component);
      case 'button':
        return _buildButton(context, component);
      case 'row':
        return _buildRow(context, component);
      case 'column':
        return _buildColumn(context, component);
      case 'card':
        return _buildCard(context, component);
      case 'image':
        return _buildImage(context, component);
      case 'icon':
        return _buildIcon(context, component);
      case 'divider':
        return _buildDivider(context, component);
      case 'switch':
        return _buildSwitch(context, component);
      case 'slider':
        return _buildSlider(context, component);
      case 'textfield':
        return _buildTextField(context, component);
      case 'listview':
        return _buildListView(context, component);
      case 'gridview':
        return _buildGridView(context, component);
      case 'spacer':
        return _buildSpacer(context, component);
      default:
        return _buildUnknownWidget(context, component);
    }
  }

  // Container widget builder
  static Widget _buildContainer(BuildContext context, UIComponent component) {
    return Container(
      width: _getDoubleProperty(component, 'width'),
      height: _getDoubleProperty(component, 'height'),
      padding: _getPadding(component),
      margin: _getMargin(component),
      decoration: BoxDecoration(
        color: _getColorProperty(component, 'backgroundColor'),
        borderRadius: _getBorderRadius(component),
        border: _getBorder(component),
      ),
      child: component.children.isNotEmpty
          ? _buildChildrenWidget(context, component)
          : null,
    );
  }

  // Text widget builder
  static Widget _buildText(BuildContext context, UIComponent component) {
    return Text(
      component.properties['text'] ?? '',
      style: TextStyle(
        fontSize: _getDoubleProperty(component, 'fontSize') ?? 14.0,
        fontWeight: _getFontWeight(component),
        color: _getColorProperty(component, 'color'),
      ),
      textAlign: _getTextAlign(component),
      overflow: _getTextOverflow(component),
      maxLines: component.properties['maxLines'],
    );
  }

  // Button widget builder
  static Widget _buildButton(BuildContext context, UIComponent component) {
    final buttonType = component.properties['buttonType'] ?? 'elevated';
    final onPressed = component.actions['onPressed'] != null
        ? () => _handleAction(context, component.actions['onPressed'])
        : null;

    Widget child = Text(component.properties['text'] ?? 'Button');
    if (component.properties['icon'] != null) {
      final iconData = _getIconData(component.properties['icon']);
      if (component.properties['iconPosition'] == 'start') {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData),
            const SizedBox(width: 8),
            child,
          ],
        );
      } else {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(width: 8),
            Icon(iconData),
          ],
        );
      }
    }

    switch (buttonType) {
      case 'elevated':
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColorProperty(component, 'backgroundColor'),
            foregroundColor: _getColorProperty(component, 'textColor'),
            padding: _getPadding(component),
            shape: RoundedRectangleBorder(
              borderRadius: _getBorderRadius(component) ?? BorderRadius.circular(4),
            ),
          ),
          child: child,
        );
      case 'outlined':
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _getColorProperty(component, 'textColor'),
            padding: _getPadding(component),
            side: BorderSide(
              color: _getColorProperty(component, 'borderColor') ?? Colors.blue,
              width: _getDoubleProperty(component, 'borderWidth') ?? 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: _getBorderRadius(component) ?? BorderRadius.circular(4),
            ),
          ),
          child: child,
        );
      case 'text':
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _getColorProperty(component, 'textColor'),
            padding: _getPadding(component),
          ),
          child: child,
        );
      default:
        return ElevatedButton(
          onPressed: onPressed,
          child: child,
        );
    }
  }

  // Row widget builder
  static Widget _buildRow(BuildContext context, UIComponent component) {
    return Row(
      mainAxisAlignment: _getMainAxisAlignment(component),
      crossAxisAlignment: _getCrossAxisAlignment(component),
      mainAxisSize: _getMainAxisSize(component),
      children: component.children
          .map((child) => buildWidget(context, child))
          .toList(),
    );
  }

  // Column widget builder
  static Widget _buildColumn(BuildContext context, UIComponent component) {
    return Column(
      mainAxisAlignment: _getMainAxisAlignment(component),
      crossAxisAlignment: _getCrossAxisAlignment(component),
      mainAxisSize: _getMainAxisSize(component),
      children: component.children
          .map((child) => buildWidget(context, child))
          .toList(),
    );
  }

  // Card widget builder
  static Widget _buildCard(BuildContext context, UIComponent component) {
    return Card(
      elevation: _getDoubleProperty(component, 'elevation') ?? 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(component) ?? BorderRadius.circular(4),
      ),
      color: _getColorProperty(component, 'backgroundColor'),
      margin: _getMargin(component),
      child: Padding(
        padding: _getPadding(component) ?? const EdgeInsets.all(8.0),
        child: _buildChildrenWidget(context, component),
      ),
    );
  }

  // Image widget builder
  static Widget _buildImage(BuildContext context, UIComponent component) {
    final imageUrl = component.properties['src'] ?? '';
    final width = _getDoubleProperty(component, 'width');
    final height = _getDoubleProperty(component, 'height');
    final fit = _getBoxFit(component);

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }
  }

  // Icon widget builder
  static Widget _buildIcon(BuildContext context, UIComponent component) {
    final iconName = component.properties['name'] ?? 'help_outline';
    final size = _getDoubleProperty(component, 'size') ?? 24.0;
    final color = _getColorProperty(component, 'color');

    return Icon(
      _getIconData(iconName),
      size: size,
      color: color,
    );
  }

  // Divider widget builder
  static Widget _buildDivider(BuildContext context, UIComponent component) {
    return Divider(
      height: _getDoubleProperty(component, 'height') ?? 1.0,
      thickness: _getDoubleProperty(component, 'thickness') ?? 1.0,
      color: _getColorProperty(component, 'color') ?? Colors.grey.shade300,
      indent: _getDoubleProperty(component, 'indent') ?? 0.0,
      endIndent: _getDoubleProperty(component, 'endIndent') ?? 0.0,
    );
  }

  // Switch widget builder
  static Widget _buildSwitch(BuildContext context, UIComponent component) {
    return Switch(
      value: component.properties['value'] ?? false,
      onChanged: (value) {
        if (component.actions['onChanged'] != null) {
          _handleAction(context, component.actions['onChanged'], {'value': value});
        }
      },
      activeColor: _getColorProperty(component, 'activeColor'),
      activeTrackColor: _getColorProperty(component, 'activeTrackColor'),
      inactiveThumbColor: _getColorProperty(component, 'inactiveThumbColor'),
      inactiveTrackColor: _getColorProperty(component, 'inactiveTrackColor'),
    );
  }

  // Slider widget builder
  static Widget _buildSlider(BuildContext context, UIComponent component) {
    return Slider(
      value: (component.properties['value'] ?? 0.0).toDouble(),
      min: (component.properties['min'] ?? 0.0).toDouble(),
      max: (component.properties['max'] ?? 100.0).toDouble(),
      divisions: component.properties['divisions'],
      label: component.properties['label'],
      activeColor: _getColorProperty(component, 'activeColor'),
      inactiveColor: _getColorProperty(component, 'inactiveColor'),
      onChanged: (value) {
        if (component.actions['onChanged'] != null) {
          _handleAction(context, component.actions['onChanged'], {'value': value});
        }
      },
    );
  }

  // TextField widget builder
  static Widget _buildTextField(BuildContext context, UIComponent component) {
    return TextField(
      decoration: InputDecoration(
        labelText: component.properties['label'],
        hintText: component.properties['hint'],
        helperText: component.properties['helper'],
        prefixIcon: component.properties['prefixIcon'] != null
            ? Icon(_getIconData(component.properties['prefixIcon']))
            : null,
        suffixIcon: component.properties['suffixIcon'] != null
            ? Icon(_getIconData(component.properties['suffixIcon']))
            : null,
        border: _getInputBorder(component),
      ),
      obscureText: component.properties['obscureText'] ?? false,
      maxLines: component.properties['maxLines'] ?? 1,
      keyboardType: _getTextInputType(component),
      onChanged: (value) {
        if (component.actions['onChanged'] != null) {
          _handleAction(context, component.actions['onChanged'], {'value': value});
        }
      },
    );
  }

  // ListView widget builder
  static Widget _buildListView(BuildContext context, UIComponent component) {
    final scrollDirection = component.properties['scrollDirection'] == 'horizontal'
        ? Axis.horizontal
        : Axis.vertical;

    return SizedBox(
      height: scrollDirection == Axis.horizontal
          ? _getDoubleProperty(component, 'height') ?? 200.0
          : null,
      child: ListView.builder(
        scrollDirection: scrollDirection,
        itemCount: component.children.length,
        padding: _getPadding(component),
        itemBuilder: (context, index) {
          return buildWidget(context, component.children[index]);
        },
      ),
    );
  }

  // GridView widget builder
  static Widget _buildGridView(BuildContext context, UIComponent component) {
    final crossAxisCount = component.properties['crossAxisCount'] ?? 2;
    final childAspectRatio = _getDoubleProperty(component, 'childAspectRatio') ?? 1.0;
    final mainAxisSpacing = _getDoubleProperty(component, 'mainAxisSpacing') ?? 10.0;
    final crossAxisSpacing = _getDoubleProperty(component, 'crossAxisSpacing') ?? 10.0;

    return GridView.builder(
      shrinkWrap: component.properties['shrinkWrap'] ?? true,
      physics: component.properties['shrinkWrap'] == true
          ? const NeverScrollableScrollPhysics()
          : null,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: component.children.length,
      padding: _getPadding(component),
      itemBuilder: (context, index) {
        return buildWidget(context, component.children[index]);
      },
    );
  }

  // Spacer widget builder
  static Widget _buildSpacer(BuildContext context, UIComponent component) {
    final flex = component.properties['flex'] ?? 1;
    return Spacer(flex: flex);
  }

  // Unknown widget builder (fallback)
  static Widget _buildUnknownWidget(BuildContext context, UIComponent component) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Unknown widget type: ${component.type}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  // Helper method to build children widgets
  static Widget _buildChildrenWidget(BuildContext context, UIComponent component) {
    if (component.children.isEmpty) {
      return const SizedBox.shrink();
    }

    if (component.children.length == 1) {
      return buildWidget(context, component.children.first);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: component.children
          .map((child) => buildWidget(context, child))
          .toList(),
    );
  }

  // Helper method to handle actions
  static void _handleAction(BuildContext context, Map<String, dynamic> action, [Map<String, dynamic>? params]) {
    final actionType = action['type'];
    final actionParams = {...?action['params'], ...?params};

    switch (actionType) {
      case 'navigate':
        // Handle navigation
        final route = actionParams['route'];
        if (route != null) {
          Navigator.pushNamed(context, route, arguments: actionParams['arguments']);
        }
        break;
      case 'api':
        // Handle API call (implement in a separate service)
        break;
      case 'deviceControl':
        // Handle device control action (implement in a separate service)
        break;
      case 'showDialog':
        // Show dialog
        break;
      default:
        print('Unknown action type: $actionType');
    }
  }

  // Helper methods for property parsing
  static double? _getDoubleProperty(UIComponent component, String propertyName) {
    final value = component.properties[propertyName];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Color? _getColorProperty(UIComponent component, String propertyName) {
    final value = component.properties[propertyName];
    if (value == null) return null;
    if (value is String && value.startsWith('#')) {
      return Color(int.parse('0xFF${value.substring(1)}'));
    }
    return null;
  }

  static EdgeInsets? _getPadding(UIComponent component) {
    if (component.properties['padding'] is Map) {
      final padding = component.properties['padding'];
      return EdgeInsets.only(
        left: (padding['left'] ?? 0.0).toDouble(),
        top: (padding['top'] ?? 0.0).toDouble(),
        right: (padding['right'] ?? 0.0).toDouble(),
        bottom: (padding['bottom'] ?? 0.0).toDouble(),
      );
    } else if (component.properties['padding'] is num) {
      return EdgeInsets.all(component.properties['padding'].toDouble());
    }
    return null;
  }

  static EdgeInsets? _getMargin(UIComponent component) {
    if (component.properties['margin'] is Map) {
      final margin = component.properties['margin'];
      return EdgeInsets.only(
        left: (margin['left'] ?? 0.0).toDouble(),
        top: (margin['top'] ?? 0.0).toDouble(),
        right: (margin['right'] ?? 0.0).toDouble(),
        bottom: (margin['bottom'] ?? 0.0).toDouble(),
      );
    } else if (component.properties['margin'] is num) {
      return EdgeInsets.all(component.properties['margin'].toDouble());
    }
    return null;
  }

  static BorderRadius? _getBorderRadius(UIComponent component) {
    if (component.properties['borderRadius'] is num) {
      return BorderRadius.circular(component.properties['borderRadius'].toDouble());
    }
    return null;
  }

  static Border? _getBorder(UIComponent component) {
    if (component.properties['borderWidth'] != null) {
      return Border.all(
        color: _getColorProperty(component, 'borderColor') ?? Colors.grey,
        width: _getDoubleProperty(component, 'borderWidth') ?? 1.0,
      );
    }
    return null;
  }

  static FontWeight _getFontWeight(UIComponent component) {
    final weight = component.properties['fontWeight'];
    switch (weight) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  static TextAlign _getTextAlign(UIComponent component) {
    final align = component.properties['textAlign'];
    switch (align) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  static TextOverflow? _getTextOverflow(UIComponent component) {
    final overflow = component.properties['overflow'];
    switch (overflow) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'clip':
        return TextOverflow.clip;
      case 'fade':
        return TextOverflow.fade;
      case 'visible':
        return TextOverflow.visible;
      default:
        return null;
    }
  }

  static MainAxisAlignment _getMainAxisAlignment(UIComponent component) {
    final alignment = component.properties['mainAxisAlignment'];
    switch (alignment) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _getCrossAxisAlignment(UIComponent component) {
    final alignment = component.properties['crossAxisAlignment'];
    switch (alignment) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  static MainAxisSize _getMainAxisSize(UIComponent component) {
    return component.properties['mainAxisSize'] == 'min'
        ? MainAxisSize.min
        : MainAxisSize.max;
  }

  static BoxFit? _getBoxFit(UIComponent component) {
    final fit = component.properties['fit'];
    switch (fit) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return null;
    }
  }

  static IconData _getIconData(String iconName) {
    // This is a simplified implementation
    // In a real app, you would have a more comprehensive mapping
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'notifications':
        return Icons.notifications;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'add':
        return Icons.add;
      case 'delete':
        return Icons.delete;
      case 'edit':
        return Icons.edit;
      case 'search':
        return Icons.search;
      case 'menu':
        return Icons.menu;
      case 'close':
        return Icons.close;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'check':
        return Icons.check;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'thermostat':
        return Icons.thermostat;
      case 'security':
        return Icons.security;
      case 'camera':
        return Icons.camera_alt;
      case 'lock':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      default:
        return Icons.help_outline;
    }
  }

  static TextInputType? _getTextInputType(UIComponent component) {
    final keyboardType = component.properties['keyboardType'];
    switch (keyboardType) {
      case 'text':
        return TextInputType.text;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      default:
        return null;
    }
  }

  static InputBorder? _getInputBorder(UIComponent component) {
    final borderType = component.properties['borderType'];
    final borderRadius = _getDoubleProperty(component, 'borderRadius') ?? 4.0;
    
    switch (borderType) {
      case 'outline':
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case 'underline':
        return const UnderlineInputBorder();
      case 'none':
        return InputBorder.none;
      default:
        return null;
    }
  }
}