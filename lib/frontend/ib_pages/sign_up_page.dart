import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.primaryColor,
      body: Center(
        child: IbCard(
          child: SizedBox(
            width: Get.width * 0.9,
            height: Get.height * 0.8,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back_outlined),
                        ),
                        Text(
                          'sign_up'.tr,
                          style: const TextStyle(
                              fontSize: IbConfig.kPageTitleSize,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const IbTextField(
                        titleIcon: Icon(
                          Icons.person_outline,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'name',
                        hintTrKey: 'name_hint',
                        errorTrKey: ''),
                    const IbTextField(
                        titleIcon: Icon(
                          Icons.email_outlined,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'email_address',
                        hintTrKey: 'email_address_hint',
                        errorTrKey: ''),
                    const IbTextField(
                        titleIcon: Icon(
                          Icons.lock_outline,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'password',
                        hintTrKey: 'password_hint',
                        errorTrKey: ''),
                    const IbTextField(
                        titleIcon: Icon(
                          Icons.lock_outline,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'confirm_password',
                        hintTrKey: 'confirm_password_hint',
                        errorTrKey: ''),
                    IbElevatedButton(
                        textTrKey: 'sign_up',
                        onPressed: () => showDialog(
                            context: context,
                            builder: (context) => DatePicker())),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DatePicker extends StatelessWidget {
  const DatePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            width: Get.width * 0.9,
            height: Get.width * 0.9,
            child: IbCard(
              child: SfDateRangePicker(
                initialDisplayDate: DateTime(1990),
                showActionButtons: true,
                showNavigationArrow: true,
                view: DateRangePickerView.decade,
                confirmText: "Confirm",
                headerStyle: const DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center),
                onSubmit: (obj) {
                  print((obj as DateTime).millisecondsSinceEpoch);
                  Get.back(closeOverlays: true);
                },
                onCancel: () => Get.back(),
                onSelectionChanged: _onSelectionChanged,
                monthViewSettings:
                    DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
              ),
            ),
          ),
        ));
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    print(args.value);
  }
}
