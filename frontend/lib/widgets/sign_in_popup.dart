import 'package:dashi/app/theme_data.dart';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/views/settings_viewmodel.dart';
import 'package:dashi/widgets/sign_in_popup_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

heading(String text) {
  return Text(
    text,
    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
            ),
          ),
        ),
        onTap: func,
      ),
    ),
  );
}

errorText(String text) {
  return Text(
    text,
    style:
        TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
  );
}

class SignInPopup extends StatelessWidget {
  const SignInPopup({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignInViewModel>.reactive(
      viewModelBuilder: () => SignInViewModel(),
      builder: (context, model, child) {
        submitFunc() async {
          AuthenticateResponse auth = await model.signIn(
              nameCont.text, passCont.text, model.keepLoggedIn);
          if (auth.success) {
            model.setLoginError(false);
            nameCont.clear();
            passCont.clear();

            Navigator.of(context).pop();
          } else {
            model.setLoginError(true);
          }
        }

        return Dialog(
          elevation: 0,
          backgroundColor: Colors.white,
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 1 / 2,
                    child: Row(
                      children: [
                        Spacer(),
                        heading("Log In"),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 1 / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        subHeading("Username"),
                        TextFormField(
                          autofocus: true,
                          controller: nameCont,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        subHeading("Password"),
                        TextFormField(
                          obscureText: true,
                          controller: passCont,
                          onFieldSubmitted: (value) {
                            submitFunc();
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            subHeading("Keep Me Logged in"),
                            Spacer(),
                            Checkbox(
                              value: model.keepLoggedIn,
                              onChanged: (value) {
                                model.updateKeepLoggedIn(value);
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                model.loginError
                    ? errorText(
                        "Invlid username or password. Please try again.")
                    : Container(),
                FractionallySizedBox(
                  widthFactor: 1 / 2,
                  child: funcButton(
                      MediaQuery.of(context).size.height, "Submit", submitFunc),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
