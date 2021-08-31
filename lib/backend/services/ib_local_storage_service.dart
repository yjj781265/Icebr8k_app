import 'package:get_storage/get_storage.dart';
import 'package:icebr8k/backend/models/ib_question.dart';

class IbLocalStorageService {
  final _box = GetStorage();
  static final _ibLocalStorageService = IbLocalStorageService._();

  factory IbLocalStorageService() => _ibLocalStorageService;
  IbLocalStorageService._();

  List<String>? getUnAnsweredIbQidList() {
    final list = _box.read('unAnsweredIbQList');
    if (list == null) {
      return null;
    }
    return (list as List).map((e) => e as String).toList();
  }

  void updateUnAnsweredIbQList(List<IbQuestion> ibQuestions) {
    for (final q in ibQuestions) {
      appendUnAnsweredIbQidList(q);
    }
  }

  void appendUnAnsweredIbQidList(IbQuestion ibQuestion) {
    final List<String> list = getUnAnsweredIbQidList() ?? <String>[];
    if (!list.contains(ibQuestion.id)) {
      list.add(ibQuestion.id);
      _box.write('unAnsweredIbQList', list);
    }
  }

  void removeUnAnsweredIbQid(String questionId) {
    final List<String> list = getUnAnsweredIbQidList() ?? <String>[];
    list.remove(questionId);
    _box.write('unAnsweredIbQList', list);
  }
}
