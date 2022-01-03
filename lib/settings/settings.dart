import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';

import '../theme/theme.dart';
import '../main.dart';



class Settings extends StatelessWidget {
  const Settings({Key? key, this.controller}) : super(key: key);

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final tooltipThemeData = TooltipThemeData(decoration: () {
      const radius = BorderRadius.zero;
      final shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1, 1),
          blurRadius: 10.0,
        ),
      ];
      final border = Border.all(color: Colors.grey[100], width: 0.5);
      if (FluentTheme.of(context).brightness == Brightness.light) {
        return BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        );
      } else {
        return BoxDecoration(
          color: Colors.grey,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        );
      }
    }());

    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);
    return ScaffoldPage(
      header: const PageHeader(title: Text('Settings')),
      content: ListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        controller: controller,
        children: [
          Text('Theme mode',
              style: FluentTheme.of(context).typography.subtitle),
          spacer,
          ...List.generate(ThemeMode.values.length, (index) {
            final mode = ThemeMode.values[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RadioButton(
                checked: appTheme.mode == mode,
                onChanged: (value) {
                  if (value) {
                    appTheme.mode = mode;
                  }
                },
                content: Text('$mode'.replaceAll('ThemeMode.', '')),
              ),
            );
          }),
          biggerSpacer,
          Text(
            'Navigation Pane Display Mode',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          spacer,
          ...List.generate(PaneDisplayMode.values.length, (index) {
            final mode = PaneDisplayMode.values[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RadioButton(
                checked: appTheme.displayMode == mode,
                onChanged: (value) {
                  if (value) appTheme.displayMode = mode;
                },
                content: Text(
                  mode.toString().replaceAll('PaneDisplayMode.', ''),
                ),
              ),
            );
          }),
          biggerSpacer,
          Text('Navigation Indicator',
              style: FluentTheme.of(context).typography.subtitle),
          spacer,
          ...List.generate(NavigationIndicators.values.length, (index) {
            final mode = NavigationIndicators.values[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RadioButton(
                checked: appTheme.indicator == mode,
                onChanged: (value) {
                  if (value) appTheme.indicator = mode;
                },
                content: Text(
                  mode.toString().replaceAll('NavigationIndicators.', ''),
                ),
              ),
            );
          }),
          biggerSpacer,
        ],
      ),
    );
  }


}
