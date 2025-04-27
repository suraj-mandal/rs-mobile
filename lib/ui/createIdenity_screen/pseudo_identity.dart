import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/image_picker_dialog.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/identity.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class PseudoSignedIdenityTab extends StatefulWidget {
  const PseudoSignedIdenityTab(this.isFirstId, {super.key});
  final bool isFirstId;

  @override
  PseudoSignedIdenityTabState createState() => PseudoSignedIdenityTabState();
}

class PseudoSignedIdenityTabState extends State<PseudoSignedIdenityTab> {
  bool _isLoading = false;
  final TextEditingController pseudosignednameController =
      TextEditingController();
  RsGxsImage? _image;

  bool _showError = false;

  @override
  void dispose() {
    pseudosignednameController.dispose();
    super.dispose();
  }

  void _setImage(File? image) {
    Navigator.pop(context);
    if (!mounted) return;
    setState(() {
      if (image != null) {
        try {
          final bytes = image.readAsBytesSync();
          _image = RsGxsImage.fromBytes(bytes);
        } catch (e) {
          debugPrint('Error reading image file: $e');
          _image = null;
        }
      } else {
        _image = null;
      }
    });
  }

  bool _validate() {
    return pseudosignednameController.text.length >= 3;
  }

  Future<void> _createIdentity() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final avatarBase64 = _image?.base64String;
      await Provider.of<Identities>(context, listen: false).createnewIdenity(
        Identity(
          mId: '',
          signed: false,
          name: pseudosignednameController.text,
          avatar: avatarBase64,
          isContact: false,
        ),
        _image ?? RsGxsImage(),
      );
      if (!mounted) return;
      if (widget.isFirstId) {
        await Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error creating identity: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating identity: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            IntrinsicHeight(
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isLoading) return;
                          imagePickerDialog(context, _setImage);
                        },
                        child: Container(
                          height: 300 * 0.7,
                          width: 300 * 0.7,
                          decoration: BoxDecoration(
                            image: (_image?.mData != null)
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: MemoryImage(_image!.mData!),
                                  )
                                : null,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            color: Colors.grey[200],
                          ),
                          child: (_image?.mData == null)
                              ? Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          height: 40,
                          child: TextField(
                            controller: pseudosignednameController,
                            enabled: !_isLoading,
                            onChanged: (text) {
                              if (!mounted) return;
                              setState(() {
                                _showError = !_validate();
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.person_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 22,
                              ),
                              hintText: 'Name',
                              hintStyle:
                                  TextStyle(color: Theme.of(context).hintColor),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _showError && !_isLoading,
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 52, top: 4),
                            child: Text(
                              'Name must be at least 3 characters',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Visibility(
              visible: !_isLoading,
              child: BottomBar(
                child: Center(
                  child: SizedBox(
                    height: 2 * appBarHeight / 3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        final isValid = _validate();
                        if (!mounted) return;
                        setState(() {
                          _showError = !isValid;
                        });
                        if (isValid) {
                          _createIdentity();
                        }
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF00FFFF),
                              Color(0xFF29ABE2),
                            ],
                            begin: Alignment(-1, -4),
                            end: Alignment(1, 4),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 50),
                          child: FittedBox(
                            child: Text(
                              'Create Identity',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: _isLoading,
          child: const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.1)),
              child: Center(
                child: ColorLoader3(
                  radius: 15,
                  dotRadius: 6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
