import 'package:dashi/app/theme_data.dart';
import 'package:dashi/views/settings_viewmodel.dart';
import 'package:dashi/widgets/register_popup_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

heading(String text) {
  return Text(
    text,
    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  );
}

subHeading(String text) {
  return Text(
    text,
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  );
}

PageController pageCont = PageController(initialPage: 0);
final nameCont = TextEditingController();
final passCont = TextEditingController();

funcButton(h, String text, [Function func]) {
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
              child: Text(
                text,
                style: TextStyle(fontSize: 20, color: Colors.white),
              )),
        ),
        onTap: func == null
            ? () {
                pageCont.nextPage(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic);
              }
            : func,
      ),
    ),
  );
}

back() {
  return Container(
    child: InkWell(
      child: Icon(Icons.arrow_back),
      onTap: () {
        pageCont.previousPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic);
      },
    ),
  );
}

nextPage() {
  pageCont.nextPage(
      duration: Duration(milliseconds: 200), curve: Curves.easeInOutCubic);
}

code(text) {
  return SelectableText(
    text,
    textAlign: TextAlign.start,
    style: TextStyle(fontFamily: "RobotoMono", fontWeight: FontWeight.w500),
  );
}

class RegisterPopup extends StatelessWidget {
  const RegisterPopup({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String _passwordHash = "";
    return ViewModelBuilder<RegisterViewModel>.reactive(
        viewModelBuilder: () => RegisterViewModel(),
        builder: (context, model, child) {
          submitFunc() async {
            _passwordHash = await model.generatePassword(passCont.text);
            nextPage();
          }

          return Dialog(
              elevation: 0,
              backgroundColor: Colors.white,
              child: Container(
                  height: MediaQuery.of(context).size.height / 2.4,
                  width: MediaQuery.of(context).size.width / 3,
                  child: new PageView(
                      controller: pageCont,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FractionallySizedBox(
                              widthFactor: 1 / 2,
                              child: Row(
                                children: [
                                  heading("Name"),
                                  Spacer(),
                                ],
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1 / 2,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: nameCont,
                                    autofocus: true,
                                    onFieldSubmitted: (value) {
                                      nextPage();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1 / 2,
                              child: Center(
                                  child: funcButton(
                                      MediaQuery.of(context).size.height,
                                      "Next")),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FractionallySizedBox(
                              widthFactor: 1 / 2,
                              child: Row(
                                children: [
                                  back(),
                                  Spacer(),
                                  heading("Password"),
                                ],
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1 / 2,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    obscureText: true,
                                    controller: passCont,
                                    onFieldSubmitted: (value) {
                                      submitFunc();
                                    },
                                    autofocus: true,
                                  ),
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1 / 2,
                              child: Center(
                                  child: funcButton(
                                      MediaQuery.of(context).size.height,
                                      "Submit",
                                      submitFunc)),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            heading("Generated Config"),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "Send the following config to your server admin:"),
                                ),
                                Container(
                                  color: Colors.grey.shade300,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 10),
                                    child: Stack(
                                      children: [
                                        code(
                                            "[[Users]] \nname     = \"${nameCont.text}\" \npassword = \"${model.passwordHash}\" \nrole     = \"TBD\""),
                                        Positioned(
                                            right: 0,
                                            child: Container(
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    splashColor: Colors.white,
                                                    onTap: () {
                                                      Clipboard.setData(
                                                          new ClipboardData(
                                                              text:
                                                                  "[[Users]] \nname     = \"${nameCont.text}\" \npassword = \"${model.passwordHash}\" \nrole     = \"TBD\""));
                                                    },
                                                    child: Icon(Icons.copy)),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            FractionallySizedBox(
                                widthFactor: 1 / 2,
                                child: Center(
                                    child: funcButton(
                                        MediaQuery.of(context).size.height,
                                        "Done", () {
                                  nameCont.clear();
                                  passCont.clear();

                                  Navigator.of(context).pop();
                                }))),
                          ],
                        )
                      ])));
        });
  }
}
