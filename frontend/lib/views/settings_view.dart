import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashi/app/theme_data.dart';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/api_service.dart';
import 'package:dashi/services/auth_service.dart';
import 'package:dashi/views/settings_viewmodel.dart';
import 'package:dashi/widgets/register_popup.dart';
import 'package:dashi/widgets/sign_in_popup.dart';
import 'package:dashi/widgets/text_entry_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

heading(String text) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Text(
      text,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
  );
}

subHeading(String text) {
  return Text(
    text,
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  );
}

_divider() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Divider(),
  );
}

funcButton(String text, [Function func]) {
  return Container(
    decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10)),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        child: Center(
          child: Padding(
              padding: EdgeInsets.all(8),
              child: AutoSizeText(
                text,
                maxLines: 1,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              )),
        ),
        onTap: func,
      ),
    ),
  );
}

final urlCont = TextEditingController();

class SettingsView extends StatefulWidget {
  final Dashboard background;
  SettingsView({Key key, this.background}) : super(key: key);
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
        onModelReady: (model) async {
          await model.getInfo();
        },
        viewModelBuilder: () => SettingsViewModel(),
        builder: (context, model, child) {
          return Stack(
            children: [
              Container(
                child: Padding(
                  padding:
                      EdgeInsets.all((MediaQuery.of(context).size.height / 22)),
                  child: Card(
                    child: Column(
                      children: [
                        Row(
                          children: [Spacer(), heading("Settings")],
                        ),
                        _divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              subHeading("API Url"),
                              Spacer(),
                              Container(
                                child: InkWell(
                                    child: Padding(
                                      child: subHeading(
                                          APIService.instance.baseUrl),
                                      padding: EdgeInsets.all(10),
                                    ),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return TextEntryPopUp(
                                              controller: urlCont,
                                              function: () async {
                                                if (urlCont.text != "") {
                                                  await model
                                                      .setBaseUrl(urlCont.text);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              key: Key("Base URL"),
                                              title: "Update Base URL",
                                            );
                                          });
                                    }),
                              )
                            ],
                          ),
                        ),
                        _divider(),
                        if (AuthService.instance.currentUser != null)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                subHeading("Username"),
                                Spacer(),
                                Padding(
                                  child: subHeading(
                                      AuthService.instance.currentUser.name),
                                  padding: EdgeInsets.all(10),
                                ),
                              ],
                            ),
                          ),
                        Spacer(),
                        if (AuthService.instance.currentUser != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                    child: FractionallySizedBox(
                                        widthFactor: 1 / 4,
                                        child: funcButton(
                                          "Sign Out",
                                          () {
                                            model.signOut();
                                          },
                                        ))),
                              ],
                            ),
                          ),
                        AuthService.instance.currentUser != null
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: FractionallySizedBox(
                                        widthFactor: 1 / 1.2,
                                        child: funcButton(
                                          "Register",
                                          () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return RegisterPopup();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                        child: FractionallySizedBox(
                                      widthFactor: 1 / 3,
                                    )),
                                    Flexible(
                                        child: FractionallySizedBox(
                                            widthFactor: 1 / 1.2,
                                            child: funcButton(
                                              "Sign In",
                                              () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return SignInPopup();
                                                  },
                                                );
                                              },
                                            )))
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
