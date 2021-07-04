import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'ib_card.dart';

class IbSingleDatePicker extends StatelessWidget {
  final String titleTrKey;
  final Function(DateRangePickerSelectionChangedArgs) onSelectionChanged;
  final List<Widget> buttons;
  const IbSingleDatePicker(
      {Key? key,
      this.titleTrKey = 'date_picker_instruction',
      required this.onSelectionChanged,
      this.buttons = const <Widget>[]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Get.width * 0.95,
        child: IbCard(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                titleTrKey.tr,
                style: const TextStyle(
                    color: IbColors.errorRed,
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SfDateRangePicker(
              initialDisplayDate: DateTime(1990),
              showNavigationArrow: true,
              maxDate: DateTime.now(),
              view: DateRangePickerView.decade,
              headerStyle:
                  const DateRangePickerHeaderStyle(textAlign: TextAlign.center),
              onSelectionChanged: (arg) => onSelectionChanged(arg),
              monthViewSettings:
                  const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: buttons,
              ),
            ),
          ],
        )),
      ),
    );
  }
}
