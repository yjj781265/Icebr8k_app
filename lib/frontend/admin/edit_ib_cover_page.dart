import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late IbCollection newCollection;
  FontStyle fontStyle = FontStyle.normal;
  int? selectedIndex;
  List<bool> fontStyleSelection = [true, false];
  List<TextStyle> items = [];

  @override
  void initState() {
    super.initState();
    newCollection = IbCollection(
      name: widget._collection.name,
      link: widget._collection.link,
      textStyleIndex: widget._collection.textStyleIndex,
      id: widget._collection.id,
      timestamp: widget._collection.timestamp,
      creatorId: widget._collection.creatorId,
      bgColor: widget._collection.bgColor,
      textColor: widget._collection.textColor,
      isItalic: widget._collection.isItalic,
      icebreakers: widget._collection.icebreakers,
    );
    nameEtController.addListener(() {
      setState(() {
        newCollection.name = nameEtController.text.trim();
      });
    });

    linkEtController.addListener(() {
      if (linkEtController.text.trim().contains('http')) {
        setState(() {
          newCollection.link = linkEtController.text.trim();
        });
      } else {
        setState(() {
          newCollection.link = '';
        });
      }
    });
    nameEtController.text = widget._collection.name;
    linkEtController.text = widget._collection.link;
    fontStyleSelection = [
      !widget._collection.isItalic,
      widget._collection.isItalic
    ];
    fontStyle =
        widget._collection.isItalic ? FontStyle.italic : FontStyle.normal;
    selectedIndex = widget._collection.textStyleIndex;
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
        title: const Text('Edit Cover '),
        actions: [
          IconButton(
              onPressed: () {
                showColorPicker();
              },
              icon: const Icon(Icons.color_lens_outlined)),
          TextButton(
              onPressed: () async {
                if (newCollection.name.trim().isNotEmpty) {
                  newCollection.timestamp = FieldValue.serverTimestamp();
                  try {
                    await IbAdminDbService()
                        .addIcebreakerCollection(newCollection);
                    Get.back();
                    IbUtils.showSimpleSnackBar(
                        msg: 'Collection Updated',
                        backgroundColor: IbColors.accentColor);
                  } catch (e) {
                    Get.dialog(IbDialog(
                      title: 'Error',
                      subtitle: e.toString(),
                      showNegativeBtn: false,
                    ));
                  }
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
                Container(
                  padding: const EdgeInsets.all(8),
                  height: 350 * 1.44,
                  width: 350,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onTap: () {
                      showColorPicker();
                    },
                    child: IbCard(
                      color: Color(newCollection.bgColor),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: showNameColorPicker,
                            child: AutoSizeText(
                              newCollection.name,
                              textAlign: TextAlign.center,
                              minFontSize: IbConfig.kNormalTextSize,
                              maxFontSize: IbConfig.kSloganSize,
                              maxLines: 4,
                              style: IbUtils.getIbFonts(TextStyle(
                                  color: Color(newCollection.textColor),
                                  fontWeight: FontWeight.bold,
                                  fontStyle: fontStyle,
                                  fontSize: IbConfig
                                      .kSloganSize))[selectedIndex ?? 0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (newCollection.link.trim().isNotEmpty)
                  Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).backgroundColor.withOpacity(0.8),
                        child: IconButton(
                          icon: Icon(
                            Icons.link,
                            color: Theme.of(context).indicatorColor,
                          ),
                          onPressed: () async {
                            if (await canLaunch(newCollection.link.trim())) {
                              launch(newCollection.link);
                            }
                          },
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
                            newCollection.isItalic = false;
                          } else {
                            fontStyle = FontStyle.italic;
                            newCollection.isItalic = true;
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
                          newCollection.textStyleIndex = selectedIndex ?? 0;
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
                    titleTrKey: 'Title',
                    hintTrKey: 'Enter cover title here',
                    charLimit: 100,
                    maxLines: 6,
                    controller: nameEtController,
                    suffixIcon: CircleAvatar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: IconButton(
                        icon: Icon(
                          Icons.color_lens_outlined,
                          color: Color(newCollection.textColor),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IbTextField(
                titleIcon: const Icon(Icons.link),
                titleTrKey: 'Link',
                hintTrKey: 'Enter source link here',
                controller: linkEtController,
              ),
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
          pickerColor: Color(newCollection.bgColor),
          onColorChanged: (Color value) {
            setState(() {
              newCollection.bgColor = value.value;
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
          pickerColor: Color(newCollection.textColor),
          onColorChanged: (Color value) {
            setState(() {
              newCollection.textColor = value.value;
            });
          },
        ),
      ),
      showNegativeBtn: false,
    ));
  }
}
