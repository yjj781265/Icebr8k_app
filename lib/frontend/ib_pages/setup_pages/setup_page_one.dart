import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/setup_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';

import '../../ib_colors.dart';

class SetupPageOne extends StatelessWidget {
  final SetupController _controller;

  const SetupPageOne(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 56,
                          child: IbElevatedButton(
                            color: IbColors.errorRed,
                            textTrKey: 'sign_out',
                            onPressed: () {
                              Get.find<AuthController>().signOut();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 56,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: IbElevatedButton(
                              color: IbColors.primaryColor,
                              textTrKey: 'next',
                              onPressed: () {
                                _controller.validatePageOne();
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
        ),
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
              height: 20,
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
                  const SizedBox(
                    width: 8,
                  ),
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
                        textInputType: TextInputType.name,
                        titleTrKey: 'fName',
                        hintTrKey: 'fNameHint',
                        onChanged: (text) {}),
                    IbTextField(
                        controller: _controller.lNameTeController,
                        titleIcon: const Icon(
                          Icons.person_rounded,
                          color: IbColors.primaryColor,
                        ),
                        textInputType: TextInputType.name,
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
                              child: Text(
                                IbUser.kGenders[0],
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                IbUser.kGenders[1],
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                IbUser.kGenders[2],
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor),
                              ),
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
    _controller.birthdateTeController.text = IbUtils.readableDateTime(
        DateTime.fromMillisecondsSinceEpoch(_controller.birthdateInMs.value));
    Get.bottomSheet(
        IbCard(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: Get.width,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('ok'.tr),
                ),
              ),
              SizedBox(
                height: 256,
                width: Get.width,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                      _controller.birthdateInMs.value),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (value) async {
                    await HapticFeedback.selectionClick();
                    _controller.birthdateTeController.text =
                        IbUtils.readableDateTime(value);
                    _controller.birthdateTeController.text;
                    _controller.birthdateInMs.value =
                        value.millisecondsSinceEpoch;
                  },
                  dateOrder: DatePickerDateOrder.mdy,
                ),
              ),
            ],
          ),
        )),
        ignoreSafeArea: false);
  }
}
