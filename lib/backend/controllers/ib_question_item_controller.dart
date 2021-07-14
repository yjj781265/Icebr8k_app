import 'package:get/get.dart';

class IbQuestionItemController extends GetxController {
  final result1 = 0.0.obs;
  final result2 = 0.0.obs;
  final isSelectedMap = RxMap<String, bool>();
  final isVoted = false.obs;

  List<String> answers = ['Coke', 'Pepsi'];

  @override
  void onInit() {
    print('IbQuestionItemController init');
    super.onInit();
    for (final String answer in answers) {
      isSelectedMap.putIfAbsent(answer, () => false);
    }
    print(isSelectedMap);
  }

  void updateSelected(String answer) {
    if (isSelectedMap.containsValue(true)) {
      return;
    }
    isSelectedMap.update(answer, (value) => true);
  }

  void onVote() {
    isSelectedMap.updateAll((key, value) => false);
    isVoted.value = true;
    result1.value = 0.6;
    result2.value = 0.4;
  }

  void reset() {
    isSelectedMap.updateAll((key, value) => false);
    isVoted.value = false;
    result1.value = 0.0;
    result2.value = 0.0;
  }

  void printMap() {
    print(isSelectedMap);
  }
}
