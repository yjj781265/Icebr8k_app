import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_widgets/ib_card.dart';

class EditIbCoverPage extends StatefulWidget {
  final IbCollection _collection;
  const EditIbCoverPage(this._collection, {Key? key}) : super(key: key);

  @override
  State<EditIbCoverPage> createState() => _EditIbCoverPageState();
}

class _EditIbCoverPageState extends State<EditIbCoverPage> {
  TextEditingController nameEtController = TextEditingController();
  TextEditingController linkEtController = TextEditingController();
  FontStyle fontStyle = FontStyle.normal;
  int? selectedIndex;
  List<bool> fontStyleSelection = [true, false];
  List<TextStyle> items = [];

  @override
  void initState() {
    super.initState();
    nameEtController.addListener(() {
      setState(() {
        widget._collection.name = nameEtController.text.trim();
      });
    });
    items = IbUtils.getIbFonts(TextStyle(
        fontSize: IbConfig.kNormalTextSize,
        fontStyle: fontStyle,
        color: IbColors.accentColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Cover '),
        actions: [
          IconButton(
              onPressed: () {
                showColorPicker();
              },
              icon: const Icon(Icons.color_lens_outlined)),
          TextButton(onPressed: () {}, child: Text('confirm'.tr))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              height: 350 * 1.44,
              width: 350,
              child: IbCard(
                color: Color(widget._collection.bgColor),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      widget._collection.name,
                      textAlign: TextAlign.center,
                      minFontSize: IbConfig.kNormalTextSize,
                      maxFontSize: IbConfig.kSloganSize,
                      maxLines: 4,
                      style: IbUtils.getIbFonts(TextStyle(
                          color: Color(widget._collection.textColor),
                          fontStyle: fontStyle,
                          fontSize: IbConfig.kSloganSize))[selectedIndex ?? 0],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleButtons(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderColor: IbColors.lightGrey,
                    selectedColor: IbColors.primaryColor,
                    selectedBorderColor: IbColors.accentColor,
                    borderWidth: 2,
                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < fontStyleSelection.length; i++) {
                          fontStyleSelection[i] = false;
                        }
                        fontStyleSelection[index] = !fontStyleSelection[index];
                        if (index == 0 && fontStyleSelection[index]) {
                          fontStyle = FontStyle.normal;
                        } else {
                          fontStyle = FontStyle.italic;
                        }
                        items = IbUtils.getIbFonts(TextStyle(
                            fontSize: IbConfig.kNormalTextSize,
                            fontStyle: fontStyle,
                            color: Theme.of(context).indicatorColor));
                      });
                    },
                    isSelected: fontStyleSelection,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(FontAwesomeIcons.font,
                            color: IbColors.lightGrey),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          FontAwesomeIcons.italic,
                          color: IbColors.lightGrey,
                        ),
                      ),
                    ]),
                DropdownButton2(
                  buttonWidth: 150,
                  dropdownWidth: 100,
                  itemHeight: 40,
                  hint: const Text(
                    'Select Font',
                    style: TextStyle(
                      fontSize: 14,
                      color: IbColors.lightGrey,
                    ),
                  ),
                  items: items
                      .map((e) => DropdownMenuItem<TextStyle>(
                            value: e,
                            child: Text(
                              'Icebr8k',
                              style: e,
                            ),
                          ))
                      .toList(),
                  onChanged: (style) {
                    setState(() {
                      if (style != null) {
                        selectedIndex = items.indexOf(style as TextStyle);
                      }
                    });
                  },
                  value:
                      selectedIndex == null ? null : items[selectedIndex ?? 0],
                )
              ],
            ),
            Column(
              children: [
                IbTextField(
                  titleIcon: const Icon(Icons.drive_file_rename_outline),
                  titleTrKey: 'name',
                  hintTrKey: 'Enter cover name here',
                  controller: nameEtController,
                  suffixIcon: CircleAvatar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: IconButton(
                      icon: Icon(
                        Icons.color_lens_outlined,
                        color: Color(widget._collection.textColor),
                      ),
                      onPressed: () {
                        showNameColorPicker();
                      },
                    ),
                  ),
                ),
              ],
            ),
            IbTextField(
              titleIcon: const Icon(Icons.link),
              titleTrKey: 'Link',
              hintTrKey: 'Enter source link here',
              controller: linkEtController,
            )
          ],
        ),
      ),
    );
  }

  void showColorPicker() {
    IbUtils.hideKeyboard();
    Get.dialog(IbDialog(
      title: 'Pick a color',
      subtitle: '',
      content: SizedBox(
        height: 300,
        child: MaterialPicker(
          portraitOnly: true,
          pickerColor: Color(widget._collection.bgColor),
          onColorChanged: (Color value) {
            setState(() {
              widget._collection.bgColor = value.value;
            });
          },
        ),
      ),
      showNegativeBtn: false,
    ));
  }

  void showNameColorPicker() {
    IbUtils.hideKeyboard();
    Get.dialog(IbDialog(
      title: 'Pick a color',
      subtitle: '',
      content: SizedBox(
        height: 300,
        child: MaterialPicker(
          portraitOnly: true,
          pickerColor: Color(widget._collection.textColor),
          onColorChanged: (Color value) {
            setState(() {
              widget._collection.textColor = value.value;
            });
          },
        ),
      ),
      showNegativeBtn: false,
    ));
  }
}
