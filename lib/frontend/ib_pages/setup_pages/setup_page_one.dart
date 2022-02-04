import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/setup_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:intl/intl.dart';

import '../../ib_colors.dart';

class SetupPageOne extends StatelessWidget {
  final SetupController _controller;

  const SetupPageOne(this._controller);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: IbUtils.hideKeyboard,
        child: SafeArea(
            child: Container(
          color: Theme.of(context).primaryColorLight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: bodyWidget(context)),
              const SizedBox(
                height: 16,
              ),
              Container(
                height: 80,
                width: Get.width,
                padding: const EdgeInsets.only(
                    left: 8, right: 8, bottom: 16, top: 8),
                child: IbElevatedButton(
                  color: IbColors.primaryColor,
                  textTrKey: 'Next',
                  onPressed: () {
                    IbUtils.hideKeyboard();
                    _controller.validatePageOne();
                  },
                  icon: const Icon(Icons.navigate_next),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                      flex: 8,
                      child: Text(
                        'Create Your Unique Profile',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: IbConfig.kSloganSize,
                            fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          color: Theme.of(context).backgroundColor,
                        ),
                        child: const Text(
                          'Step 1/3',
                          style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                        ),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            IbCard(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IbTextField(
                        controller: _controller.fNameTeController,
                        titleIcon: const Icon(
                          Icons.person_rounded,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'fName',
                        hintTrKey: 'fNameHint',
                        onChanged: (text) {}),
                    IbTextField(
                        controller: _controller.lNameTeController,
                        titleIcon: const Icon(
                          Icons.person_rounded,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'lName',
                        hintTrKey: 'lNameHint',
                        onChanged: (text) {}),
                    InkWell(
                      onTap: _showDateTimePicker,
                      child: IbTextField(
                        titleIcon: const Icon(
                          Icons.cake_outlined,
                          color: IbColors.primaryColor,
                        ),
                        controller: _controller.birthdateTeController,
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        titleTrKey: 'birthdate',
                        hintTrKey: 'birthdate_hint',
                        enabled: false,
                        onChanged: (birthdate) {},
                      ),
                    ),
                    Obx(
                      () => ToggleButtons(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          selectedColor: IbColors.primaryColor,
                          selectedBorderColor: IbColors.accentColor,
                          borderWidth: 2,
                          onPressed: (index) {
                            _controller.onGenderSelect(index);
                          },
                          isSelected: _controller.genderSelections,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(IbUser.kGenders[0]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(IbUser.kGenders[1]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(IbUser.kGenders[2]),
                            )
                          ]),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  void _showDateTimePicker() {
    IbUtils.hideKeyboard();
    Get.bottomSheet(
        IbCard(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 256,
                width: Get.width,
                child: CupertinoDatePicker(
                  initialDateTime:
                      DateTime.fromMillisecondsSinceEpoch(631170000000),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (value) async {
                    await HapticFeedback.selectionClick();
                    _controller.birthdateTeController.text =
                        _readableDateTime(value);
                    _controller.birthdateTeController.text;
                    _controller.birthdateInMs.value =
                        value.millisecondsSinceEpoch;
                  },
                  dateOrder: DatePickerDateOrder.mdy,
                ),
              ),
              SizedBox(
                width: Get.width,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('ok'.tr),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        )),
        ignoreSafeArea: false);
  }

  String _readableDateTime(DateTime _dateTime) {
    final f = DateFormat('MM/dd/yyyy');
    return f.format(_dateTime);
  }
}
