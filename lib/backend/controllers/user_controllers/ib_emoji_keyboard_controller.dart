import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbEmojiKeyboardController extends GetxController {
  final searchKeyword = ''.obs;
  final searchResults = <Emoji>[].obs;
  final TextEditingController textEditingController = TextEditingController();
  final isSearching = false.obs;
  @override
  void onInit() {
    textEditingController.addListener(() {
      searchKeyword.value = textEditingController.text;
      if (searchKeyword.value.isNotEmpty) {
        isSearching.value = true;
      } else {
        isSearching.value = false;
      }
    });

    debounce(searchKeyword, (value) async {
      searchResults.clear();
      searchResults.addAll(await EmojiPickerUtils()
          .searchEmoji(textEditingController.text.trim()));
      isSearching.value = false;
    }, time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    super.onInit();
  }
}
