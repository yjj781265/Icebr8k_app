import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/models/icebreaker_models/icebreaker.dart';
import '../ib_widgets/ib_dialog.dart';
import '../ib_widgets/ib_text_field.dart';

class EditIcebreakerPage extends StatefulWidget {
  final Icebreaker icebreaker;
  final IbCollection ibCollection;
  const EditIcebreakerPage(this.icebreaker, this.ibCollection, {Key? key})
      : super(key: key);

  @override
  State<EditIcebreakerPage> createState() => _EditIcebreakerPageState();
}

class _EditIcebreakerPageState extends State<EditIcebreakerPage> {
  TextEditingController nameEtController = TextEditingController();

  late Icebreaker newIcebreaker;
  FontStyle fontStyle = FontStyle.normal;
  int? selectedIndex;
  List<bool> fontStyleSelection = [true, false];
  List<TextStyle> items = [];

  @override
  void initState() {
    super.initState();
    newIcebreaker = Icebreaker(
        text: widget.icebreaker.text,
        id: widget.icebreaker.id,
        collectionId: widget.icebreaker.collectionId,
        textStyleIndex: widget.icebreaker.textStyleIndex,
        timestamp: widget.icebreaker.timestamp,
        isItalic: widget.icebreaker.isItalic,
        textColor: widget.icebreaker.textColor,
        bgColor: widget.icebreaker.bgColor);

    if (widget.icebreaker.text.isEmpty) {
      newIcebreaker.bgColor = widget.ibCollection.bgColor;
      newIcebreaker.textColor = widget.ibCollection.textColor;
      newIcebreaker.textStyleIndex = widget.ibCollection.textStyleIndex;
    }

    nameEtController.addListener(() {
      setState(() {
        newIcebreaker.text = nameEtController.text.trim();
      });
    });

    nameEtController.text = newIcebreaker.text;

    fontStyleSelection = [!newIcebreaker.isItalic, newIcebreaker.isItalic];
    fontStyle = newIcebreaker.isItalic ? FontStyle.italic : FontStyle.normal;
    selectedIndex = newIcebreaker.textStyleIndex;
  }

  @override
  Widget build(BuildContext context) {
    items = IbUtils.getIbFonts(TextStyle(
        fontSize: IbConfig.kNormalTextSize,
        fontWeight: FontWeight.bold,
        fontStyle: fontStyle,
        color: Theme.of(context).indicatorColor));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Icebreaker'),
        actions: [
          IconButton(
              onPressed: () {
                showColorPicker();
              },
              icon: const Icon(Icons.color_lens_outlined)),
          IconButton(
              onPressed: () async {
                widget.ibCollection.icebreakers
                    .removeWhere((element) => element.id == newIcebreaker.id);
                await IbAdminDbService()
                    .addIcebreakerCollection(widget.ibCollection);
                Get.back();
              },
              icon: const Icon(
                Icons.delete,
                color: IbColors.errorRed,
              )),
          TextButton(
              onPressed: () async {
                if (newIcebreaker.text.trim().isEmpty) {
                  return;
                }

                if (widget.ibCollection.icebreakers.firstWhereOrNull(
                            (element) =>
                                element.text == newIcebreaker.text.trim()) ==
                        null ||
                    newIcebreaker != widget.icebreaker) {
                  newIcebreaker.timestamp = Timestamp.now();
                  try {
                    final index = widget.ibCollection.icebreakers.indexWhere(
                        (element) => element.id == newIcebreaker.id);
                    if (index != -1) {
                      widget.ibCollection.icebreakers[index] = newIcebreaker;
                    } else {
                      widget.ibCollection.icebreakers.add(newIcebreaker);
                    }
                    await IbAdminDbService()
                        .addIcebreakerCollection(widget.ibCollection);
                    Get.back();
                    IbUtils.showSimpleSnackBar(
                        msg: 'Icebreaker Updated',
                        backgroundColor: IbColors.accentColor);
                  } catch (e) {
                    Get.dialog(IbDialog(
                      title: 'Error',
                      subtitle: e.toString(),
                      showNegativeBtn: false,
                    ));
                  }
                } else {
                  IbUtils.showSimpleSnackBar(
                      msg: 'Question already exists',
                      backgroundColor: IbColors.errorRed);
                }
              },
              child: Text('confirm'.tr))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: newIcebreaker.id,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      height: 350 * 1.44,
                      width: 350,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        onTap: () {
                          showColorPicker();
                        },
                        child: IbCard(
                          color: Color(newIcebreaker.bgColor),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                  onTap: showNameColorPicker,
                                  child: AutoSizeText(
                                    newIcebreaker.text,
                                    textAlign: TextAlign.center,
                                    minFontSize: IbConfig.kNormalTextSize,
                                    maxFontSize: IbConfig.kSloganSize,
                                    maxLines: 5,
                                    style: IbUtils.getIbFonts(TextStyle(
                                        color: Color(newIcebreaker.textColor),
                                        fontWeight: FontWeight.bold,
                                        fontStyle: fontStyle,
                                        fontSize: IbConfig
                                            .kSloganSize))[selectedIndex ?? 0],
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 16,
                    right: 4,
                    child: LimitedBox(
                      maxWidth: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          widget.ibCollection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IbUtils.getIbFonts(TextStyle(
                                  fontSize: IbConfig.kDescriptionTextSize,
                                  color: Color(widget.ibCollection.textColor),
                                  fontWeight: FontWeight.bold,
                                  fontStyle: widget.ibCollection.isItalic
                                      ? FontStyle.italic
                                      : FontStyle.normal))[
                              widget.ibCollection.textStyleIndex],
                        ),
                      ),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
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
                          fontStyleSelection[index] =
                              !fontStyleSelection[index];
                          if (index == 0 && fontStyleSelection[index]) {
                            fontStyle = FontStyle.normal;
                            newIcebreaker.isItalic = false;
                          } else {
                            fontStyle = FontStyle.italic;
                            newIcebreaker.isItalic = true;
                          }
                          items = IbUtils.getIbFonts(TextStyle(
                              fontSize: IbConfig.kNormalTextSize,
                              fontWeight: FontWeight.bold,
                              fontStyle: fontStyle,
                              color: Theme.of(context).indicatorColor));
                        });
                      },
                      isSelected: fontStyleSelection,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(FontAwesomeIcons.font,
                              size: 16, color: IbColors.lightGrey),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            FontAwesomeIcons.italic,
                            size: 16,
                            color: IbColors.lightGrey,
                          ),
                        ),
                      ]),
                  DropdownButton2(
                    buttonWidth: 120,
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
                          newIcebreaker.textStyleIndex = selectedIndex ?? 0;
                        }
                      });
                    },
                    value: selectedIndex == null
                        ? null
                        : items[selectedIndex ?? 0],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  IbTextField(
                    titleIcon: const Icon(Icons.drive_file_rename_outline),
                    titleTrKey: 'Text',
                    hintTrKey: 'Enter icebreaker text here',
                    charLimit: 200,
                    maxLines: 10,
                    controller: nameEtController,
                    suffixIcon: CircleAvatar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: IconButton(
                        icon: Icon(
                          Icons.color_lens_outlined,
                          color: Color(newIcebreaker.textColor),
                        ),
                        onPressed: () {
                          showNameColorPicker();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          pickerColor: Color(newIcebreaker.bgColor),
          onColorChanged: (Color value) {
            setState(() {
              newIcebreaker.bgColor = value.value;
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
      title: 'Pick a color for title',
      subtitle: '',
      content: SizedBox(
        height: 300,
        child: MaterialPicker(
          portraitOnly: true,
          pickerColor: Color(newIcebreaker.textColor),
          onColorChanged: (Color value) {
            setState(() {
              newIcebreaker.textColor = value.value;
            });
          },
        ),
      ),
      showNegativeBtn: false,
    ));
  }
}
