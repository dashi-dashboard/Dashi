import 'package:dashi/models/dashi_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key key}) : super(key: key);

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

_appCard(Apps app, double h) {
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
                    : [Colors.black, Colors.grey.shade700]),
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
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      app.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
          )));
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) async {
        await model.getInfo();
      },
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        body: SafeArea(
            child: model.apps.length > 0
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: GridView.extent(
                                    maxCrossAxisExtent: 500,
                                    childAspectRatio: 3 / 1,
                                    crossAxisSpacing: 5.0,
                                    children: model.apps.map((i) {
                                      return Container(
                                          child: _appCard(
                                              i,
                                              MediaQuery.of(context)
                                                  .size
                                                  .height));
                                    }).toList())),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
