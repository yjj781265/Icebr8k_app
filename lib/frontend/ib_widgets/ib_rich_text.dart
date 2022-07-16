import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../backend/controllers/user_controllers/profile_controller.dart';
import '../../backend/services/user_services/ib_user_db_service.dart';
import '../ib_pages/profile_pages/my_profile_page.dart';
import '../ib_pages/profile_pages/profile_page.dart';
import '../ib_utils.dart';

class IbRichText extends StatelessWidget {
  final String string;
  final Color highlightColor;
  final TextStyle defaultTextStyle;
  final String errorImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/admin_files%2Ferror.PNG?alt=media&token=04a4d688-7b4d-4c5a-8d8c-1fdbe4a28db1';

  const IbRichText(
      {required this.string,
      required this.defaultTextStyle,
      this.highlightColor = IbColors.darkPrimaryColor});

  HighLightComponent getHighlightComponent(String word) {
    if (checkIfUserName(word)) {
      return HighLightComponent.username;
    } else if (GetUtils.isURL(word)) {
      return HighLightComponent.url;
    } else if (GetUtils.isPhoneNumber(word)) {
      return HighLightComponent.phoneNumber;
    } else if (GetUtils.isEmail(word)) {
      return HighLightComponent.email;
    }
    return HighLightComponent.none;
  }

  bool checkIfUserName(String word) {
    if (word.length >= 4 && word.length <= 21) {
      //since we include @ as well,its 4,21 instead of 3,20
      final String strToRegEx = word.length == 4 ? word : word.substring(0, 5);
      final RegExp regExp =
          RegExp(r"@(\w|\.){3}"); //@ followed by any 3 letter or _ or .
      if (regExp.hasMatch(strToRegEx)) {
        return true;
      }
    }
    return false;
  }

  void addNonHighlightedTextFromStringBufferToTextSpanList(
      List<Widget> textSpanListWithStyle, StringBuffer stringBuffer) {
    if (stringBuffer.isNotEmpty) {
      textSpanListWithStyle.add(RichText(
          text: TextSpan(
              text: stringBuffer.toString(), style: defaultTextStyle)));
    }
    stringBuffer.clear();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> words = string.split(" ");
    final List<Widget> textSpanListWithStyle = [];
    final StringBuffer stringBuffer = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      final String aWord = words[i];
      final highLightComponent = getHighlightComponent(aWord);
      final TextStyle highLightedTextStyle = defaultTextStyle.copyWith(
          color: highlightColor,
          decoration: highLightComponent == HighLightComponent.username &&
                  highLightComponent != HighLightComponent.none
              ? null
              : TextDecoration.underline);
      switch (highLightComponent) {
        case HighLightComponent.none:
          stringBuffer.write(aWord);
          if (i < words.length - 1) {
            //add space if not the last word
            stringBuffer.write(" ");
          }
          break;
        case HighLightComponent.url:
          final widget = AnyLinkPreview(
            key: ValueKey(aWord),
            link: aWord.contains('http') ? aWord : 'https://$aWord',
            displayDirection: UIDirection.uiDirectionHorizontal,
            titleStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: IbConfig.kSecondaryTextSize,
            ),
            bodyStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            errorBody: "Can't parse this url",
            errorTitle: 'Url',
            placeholderWidget: Text(
              aWord,
              style: defaultTextStyle,
            ),
            errorWidget: Container(
              color: Colors.transparent,
              child: Text(
                aWord,
                style: defaultTextStyle,
              ),
            ),
            errorImage: errorImageUrl,
            backgroundColor: Colors.grey[300],
            borderRadius: 8,
            boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.grey)],
            onTap: () async {
              final link = aWord.contains('http') ? aWord : 'https://$aWord';
              final Uri _url = Uri.parse(link);
              if (await canLaunchUrl(_url)) {
                await launchUrl(_url);
              }
            }, // This disables tap event
          );
          textSpanListWithStyle.add(widget);
          break;
        case HighLightComponent.username:
        case HighLightComponent.phoneNumber:
        case HighLightComponent.email:
          addNonHighlightedTextFromStringBufferToTextSpanList(
              textSpanListWithStyle, stringBuffer);
          textSpanListWithStyle.add(
            RichText(
                text: TextSpan(
                    text: aWord,
                    style: highLightedTextStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (HighLightComponent.username == highLightComponent) {
                          final userId = await IbUserDbService()
                              .queryUserIdFromUserName(aWord.substring(1));
                          if (userId == null) {
                            IbUtils.showSimpleSnackBar(
                                msg: 'Invalid User.',
                                backgroundColor: IbColors.primaryColor);
                            return;
                          } else if (userId == IbUtils.getCurrentUid()) {
                            Get.to(() => MyProfilePage());
                          } else {
                            Get.to(() => ProfilePage(
                                Get.put(ProfileController(userId))));
                          }
                        } else if (HighLightComponent.phoneNumber ==
                            highLightComponent) {
                          if (await canLaunchUrlString("tel:$aWord")) {
                            await launchUrlString("tel:$aWord");
                          }
                        } else if (HighLightComponent.email ==
                            highLightComponent) {
                          if (await canLaunchUrlString("mailto:$aWord")) {
                            await launchUrlString("mailto:$aWord");
                          } else {
                            print('cant launch email');
                          }
                        }
                      })),
          );
          if (i < words.length - 1) {
            //add space if not the last word
            stringBuffer.write(" ");
          }
          break;
      }
    }
    addNonHighlightedTextFromStringBufferToTextSpanList(
        textSpanListWithStyle, stringBuffer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textSpanListWithStyle,
    );
  }
}

enum HighLightComponent { none, username, url, phoneNumber, email }
