import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_strategy/url_strategy.dart';
import 'settings/settings.dart';
import 'theme/theme.dart';

const String appTitle = 'Initial Flutter web app';

late bool darkMode;

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  // The platforms the plugin support (01/04/2021 - DD/MM/YYYY):
  //   - Windows
  //   - Web
  //   - Android
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.android ||
      kIsWeb) {
    darkMode = await SystemTheme.darkMode;
    await SystemTheme.accentInstance.load();
  } else {
    darkMode = true;
  }
  if (!kIsWeb &&
      [TargetPlatform.windows, TargetPlatform.linux]
          .contains(defaultTargetPlatform)) {
    await flutter_acrylic.Window.initialize();
  }

  runApp(const MyApp());

  if (isDesktop) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = const Size(410, 540);
      win.size = const Size(755, 545);
      win.alignment = Alignment.center;
      win.title = appTitle;
      win.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {'/': (_) => const MyHomePage()},
          theme: ThemeData(
            accentColor: appTheme.color,
            brightness: appTheme.mode == ThemeMode.system
                ? darkMode
                    ? Brightness.dark
                    : Brightness.light
                : appTheme.mode == ThemeMode.dark
                    ? Brightness.dark
                    : Brightness.light,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool value = false;

  int index = 0;

  final colorsController = ScrollController();
  final settingsController = ScrollController();

  @override
  void dispose() {
    colorsController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
        // height: !kIsWeb ? appWindow.titleBarHeight : 31.0,
        title: () {
          if (kIsWeb) return const Text(appTitle);
        }(),
        actions: kIsWeb
            ? null
            : MoveWindow(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [Spacer(),],
                ),
              ),
      ),
      pane: NavigationPane(
        ///navigation dans le drawer
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          ///taille du drawer en fonction de sa forme et/ou son emplacement
          openMinWidth: 250,
          openMaxWidth: 320,
        ),
        header: Container(
          height: kOneLineTileHeight,///taille du header du drawer
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const FlutterLogo(
            style: FlutterLogoStyle.horizontal,
            size: 100,
          ),
        ),
        displayMode: appTheme.displayMode,
        ///permet de definirnle type d'indicateur du du drawer
        indicatorBuilder: ({
          required BuildContext context,
          required NavigationPane pane,
          Axis? axis,
          required Widget child,
        }) {
          if (pane.selected == null) return child;
          axis ??= Axis.horizontal;
          assert(debugCheckHasFluentTheme(context));
          final theme = NavigationPaneTheme.of(context);
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return EndNavigationIndicator(
                index: pane.selected!,
                offsets: () =>
                    pane.effectiveItems.getPaneItemsOffsets(pane.paneKey),
                sizes: pane.effectiveItems.getPaneItemsSizes,
                child: child,
                color: theme.highlightColor,
                curve: theme.animationCurve ?? Curves.linear,
                axis: axis,
              );
            case NavigationIndicators.sticky:
              return NavigationPane.defaultNavigationIndicator(
                context: context,
                axis: axis,
                pane: pane,
                child: child,
              );
            default:
              return NavigationIndicator(
                index: pane.selected!,
                offsets: () =>
                    pane.effectiveItems.getPaneItemsOffsets(pane.paneKey),
                sizes: pane.effectiveItems.getPaneItemsSizes,
                child: child,
                color: theme.highlightColor,
                curve: theme.animationCurve ?? Curves.linear,
                axis: axis,
              );
          }
        },
        items: [
          // It doesn't look good when resizing from compact to open
          // PaneItemHeader(header: Text('User Interaction')),
          PaneItemSeparator(),

        ],
        ///correspond à la barre de recherche
        autoSuggestBox: AutoSuggestBox<String>(
          controller: TextEditingController(),
          items: const ['Item 1', 'Item 2', 'Item 3', 'Item 4'],
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: [
          /// items qui se placent tout en bas du drawer
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
          ),
        ],
      ),
      ///le contenue de chaque section du drawer
      content: NavigationBody(index: index, children: [
        Settings(controller: settingsController),
      ]),
    );
  }
}


