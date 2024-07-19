import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:june/june.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../main.dart';
import '../../../../config.dart';
import 'widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();
  bool _switchValue = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _setSelectedIndex(
                  (_selectedIndex - 1).clamp(0, widgets.length - 1));
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _setSelectedIndex(
                  (_selectedIndex + 1).clamp(0, widgets.length - 1));
            }
          }
        },
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 4,
              child: Container(
                color: Colors.black,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Gap(20),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_iphone,
                            color: Colors.white,
                            size: 30,
                          ),
                          Gap(10),
                          CupertinoSwitch(
                            value: _switchValue,
                            onChanged: (bool value) {
                              setState(() {
                                _switchValue = value;
                              });
                            },
                          ),
                          Spacer(),
                          // github icon
                          IconButton(
                              onPressed: () {
                                _openUrl(githubUrl);
                              },
                              // color: Colors.white,
                              icon: SvgPicture.asset(
                                'assets/github.svg',
                                width: 30,
                                height: 30,
                                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              )),

                        ],
                      ).padding(left: 20,right: 10),
                      Gap(20),
                      Text("${userName}'s\nWidget Book",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold))
                          .padding(left: 20, right: 10),
                      Gap(20),
                      ...List.generate(widgets.length, (index) {
                        return _buildTextButton(widgets[index].item1, index);
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 7,
              child: IndexedStack(
                index: _loading ? 0 : 1,
                children: <Widget>[
                  DevicePreview(
                    builder: (context) =>
                        CupertinoActivityIndicator().center(),
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    isToolbarVisible: false,
                  ),
                  _buildContent(_switchValue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, int index) {
    // Replace underscores with spaces
    String originalUrlName = text.split('.').first;

    text = text.replaceAll('_', ' ');

    // Split by dot and keep the first part
    if (text.contains('.')) {
      text = text.split('.').first;
    }

    // Capitalize each word
    text = text
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');

    // Remove " lego" if it exists, case insensitive
    if (text.toLowerCase().endsWith(' lego')) {
      text = text.substring(0, text.length - 5); // Remove the last 5 characters
    }

    // Return the TextButton widget
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              _setSelectedIndex(index);
            },
            style: ButtonStyle(
              alignment: Alignment.centerLeft, // 텍스트 왼쪽 정렬
            ),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.grey,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // pub dev icon
        IconButton(
            onPressed: () {
              _openUrl('https://pub.dev/packages/$originalUrlName');
            },
            // color: Colors.white,
            icon: SvgPicture.asset(
              'assets/pubdev.svg',
              width: 30,
              height: 30,
              // colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )),
      ],
    ).padding(vertical: 2, horizontal: 10);
  }

  _openUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  Widget _buildContent(bool switchMobileMode) {
    return DevicePreview(
      enabled: switchMobileMode,
      builder: (context) => Scaffold(
        body: widgets[_selectedIndex].item2.center(),
      ),
      backgroundColor: Colors.grey.withOpacity(0.1),
      isToolbarVisible: false,
    );
  }

  _setSelectedIndex(int index) {
    startLoading();
    setState(() {
      _selectedIndex = index;
    });
  }

  startLoading() {
    if (!_switchValue) return;
    setState(() {
      _loading = true;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

void main() async {
  runApp(MaterialApp(
    home: HomeView(),
  ));
}
