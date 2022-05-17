import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../backend/controllers/user_controllers/profile_controller.dart';
import '../../backend/services/user_services/ib_user_db_service.dart';
import '../ib_pages/profile_pages/my_profile_page.dart';
import '../ib_pages/profile_pages/profile_page.dart';
import '../ib_utils.dart';

class IbRichText extends StatelessWidget {
  final String string;
  final TextStyle defaultTextStyle;

  const IbRichText({required this.string
    , required this.defaultTextStyle});

  HighLightComponent getHighlightComponent(String word){
    if(checkIfUserName(word)) {return HighLightComponent.username;}
    else if(GetUtils.isURL(word)) {return HighLightComponent.url;}
    else if(GetUtils.isPhoneNumber(word)) {return HighLightComponent.phoneNumber;}
    return HighLightComponent.none;
  }

  bool checkIfUserName(String word){
    if(word.length>=4 && word.length<=21) { //since we include @ as well,its 4,21 instead of 3,20
      final String strToRegEx = word.length == 4 ? word : word.substring(0,5);
      final RegExp regExp = RegExp(r"@(\w|\.){3}");//@ followed by any 3 letter or _ or .
      if(regExp.hasMatch(strToRegEx)){
        return true;
      }
    }
    return false;
  }

  void addNonHighlightedTextFromStringBufferToTextSpanList(List<TextSpan> textSpanListWithStyle , StringBuffer stringBuffer){
    if(stringBuffer.isNotEmpty){
      textSpanListWithStyle.add(
          TextSpan(
              text: stringBuffer.toString(),
              style: defaultTextStyle
          )
      );
    }
    stringBuffer.clear();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle highLightedTextStyle = defaultTextStyle.copyWith(color: IbColors.darkPrimaryColor);

    final List<String> words = string.split(" ");
    final List<TextSpan> textSpanListWithStyle = <TextSpan>[];
    final StringBuffer stringBuffer = StringBuffer();
    for(int i = 0; i < words.length ;i++){
      final String aWord = words[i];
      final highLightComponent = getHighlightComponent(aWord);
      if( highLightComponent != HighLightComponent.none){
        //first add anything on the string buffer and empty it
        addNonHighlightedTextFromStringBufferToTextSpanList(textSpanListWithStyle,stringBuffer);
        textSpanListWithStyle.add(
            TextSpan(
                text: aWord,
                style: highLightedTextStyle,
                recognizer: TapGestureRecognizer()..onTap=() async {
                  if(HighLightComponent.username == highLightComponent){
                    final userId = await IbUserDbService().queryUserIdFromUserName(aWord.substring(1));
                    if(userId==null){
                      IbUtils.showSimpleSnackBar(
                          msg: 'Invalid User.',
                          backgroundColor: IbColors.primaryColor);
                      return;
                    }else if(userId == IbUtils.getCurrentUid()){
                      Get.to(() => MyProfilePage());
                    }
                    else {
                      Get.to(() => ProfilePage(Get.put(ProfileController(userId))));
                    }
                  }
                  else if(HighLightComponent.url == highLightComponent){
                    /*if(await canLaunchUrlString("http:$aWord")){
                      await launchUrlString("http:$aWord");
                    }*/// This opens the link in internal web browser
                    if(await canLaunch("http:$aWord")){
                      await launch("http:$aWord");
                    }
                  }
                  else if(HighLightComponent.phoneNumber == highLightComponent){
                    if(await canLaunchUrlString("tel:$aWord")){
                      await launchUrlString("tel:$aWord");
                    }
                  }
                }
            )
        );
        if(i<words.length-1) {//add space if not the last word
          stringBuffer.write(" ");
        }
      }//not high lighting
      else{
        stringBuffer.write(aWord);
        if(i<words.length-1) {//add space if not the last word
          stringBuffer.write(" ");
        }
      }
    }
    addNonHighlightedTextFromStringBufferToTextSpanList(textSpanListWithStyle,stringBuffer);

    return RichText(
      text: TextSpan(
        text: "",
        children:textSpanListWithStyle,
      ),
    );
  }

}

enum HighLightComponent { none, username, url, phoneNumber }