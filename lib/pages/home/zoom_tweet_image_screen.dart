import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';

class ZoomImageScreen extends StatefulWidget {
  static const routeName = '/zoom-image-screen';

  ZoomImageScreen({
    @required this.heroTagName,
    this.imagePath,
  });

  final String heroTagName;
  final String imagePath;

  @override
  _ZoomImageScreenState createState() => _ZoomImageScreenState();
}

class _ZoomImageScreenState extends State<ZoomImageScreen> {
  bool displayBottomSection = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Color.fromARGB(63, 63, 63, 1),
      body: SafeArea(
        bottom: false,
        child: ColoredBox(
          color: theme.isLightTheme ? black : darkBlack,
          child: InkWell(
            onTap: () {
              displayBottomSection = !displayBottomSection;
              setState(() {});
            },
            child: Column(
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(height: 56.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Icon(
                            Icons.more_vert,
                            color: white,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * .2),
                SizedBox(
                  height: size.width,
                  child: Hero(
                    tag: widget.heroTagName,
                    child: PhotoView(
                      imageProvider: NetworkImage(
                        widget.imagePath,
                      ),
                      initialScale: PhotoViewComputedScale.contained * 1,
                      gaplessPlayback: true,
                      backgroundDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.width * .08),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
