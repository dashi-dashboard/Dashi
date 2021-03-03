import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashi/app/theme_data.dart';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  final List<Apps> apps;
  final List tags;
  final String viewType;

  const HomeView({
    Key key,
    this.apps,
    this.tags,
    this.viewType,
  }) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_cardBody(String viewType, Apps app) {
  var toReturn;
  switch (viewType) {
    case "grid":
      toReturn = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          app.icon.isNotEmpty
              ? Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        app.icon.toString(),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                )
              : Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                  ),
                ),
          Flexible(
            child: FractionallySizedBox(
              widthFactor: 1.2,
              child: AutoSizeText(
                app.name,
                textAlign: TextAlign.start,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Flexible(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      );
      break;
    case "filter":
      toReturn = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          app.icon.isNotEmpty
              ? Flexible(
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        app.icon.toString(),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                )
              : Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                  ),
                ),
          AutoSizeText(
            app.name,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
      break;
  }
  return toReturn;
}

_appCard(Apps app, String type) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: app.color != Color(0x000000ff)
              ? [app.color, app.color.withAlpha(150)]
              : [Colors.black, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            hoverColor: Colors.grey.shade600,
            splashColor: Colors.white,
            onTap: () {
              _launchURL(app.url);
            },
            borderRadius: BorderRadius.circular(10),
            child: _cardBody(type, app)),
      ),
    ),
  );
}

_fullGrid(List<Apps> apps, String type) {
  return Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < apps.length; i++)
            Container(
              width: 420,
              child: AspectRatio(
                aspectRatio: 3 / 1,
                child: _appCard(apps[i], type),
              ),
            ),
        ],
      ),
    ),
  );
}

_tagHeader(String text) {
  if (text == "") {
    text = "Not Tagged";
  }
  return Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.primary,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.primaryVariant,
          theme.colorScheme.primary,
        ],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    ),
  );
}

_filteredRows(List<Apps> apps, List tags, String type) {
  return Center(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tags.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _tagHeader(tags[i]),
                ),
                SizedBox(
                  height: 250,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: ClampingScrollPhysics(),
                    children: [
                      for (var x = 0; x < apps.length; x++)
                        if (apps[x].tag == tags[i])
                          Container(
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: _appCard(apps[x], type),
                            ),
                          ),
                    ],
                  ),
                )
              ],
            ),
        ],
      ),
    ),
  );
}

getView(List<Apps> apps, List tags, String type) {
  var toReturn;
  switch (type) {
    case "grid":
      toReturn = _fullGrid(apps, type);
      break;
    case "filter":
      toReturn = _filteredRows(apps, tags, type);
      break;
    default:
      toReturn = _fullGrid(apps, type);
  }
  return toReturn;
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          getView(
            widget.apps,
            widget.tags,
            widget.viewType,
          )
        ],
      ),
    );
  }
}
