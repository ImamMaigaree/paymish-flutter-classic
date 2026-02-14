import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../apis/apimanager/user_api_manager.dart';
import '../apis/base_model.dart';
import '../ui/profile/useragentprofile/model/req_upload_picture.dart';
import '../utils/color_utils.dart';
import '../utils/common_methods.dart';
import '../utils/dialog_utils.dart';
import '../utils/image_constants.dart';
import '../utils/localization/localization.dart';
import '../utils/permission_util.dart';
import '../utils/preference_key.dart';
import '../utils/preference_utils.dart';

class UserProfilePicture extends StatefulWidget {
  const UserProfilePicture({Key? key}) : super(key: key);

  @override
  _UserProfilePictureState createState() => _UserProfilePictureState();
}

class _UserProfilePictureState extends State<UserProfilePicture> {
  final _isLoading = ValueNotifier<bool>(false);

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Platform.isAndroid
            ? _getImageSourceBottomSheet()
            : _getImageSourceActionSheet();
      },
      child: Stack(
        clipBehavior: Clip.none, alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(2.0),
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              border: Border.all(color: ColorUtils.secondaryTextColor),
              borderRadius: BorderRadius.circular(35.0),
            ),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) => isLoading
                    ? _getProgressIndicator()
                    : ClipOval(
                        child: getString(PreferenceKey.profilePicture).isEmpty
                            ? Container(
                                color: Colors.white,
                                child: Image.asset(
                                  ImageConstants.icDefaultProfileImage,
                                ),
                              )
                            : Image.network(
                                getString(PreferenceKey.profilePicture),
                                fit: BoxFit.cover,
                                height: 70,
                                width: 70,
                              ),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            child: Image.asset(
              ImageConstants.icCamera,
              scale: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  void _uploadProfilePictureApiCall({required File image}) {
    _isLoading.value = true;
    UserApiManager()
        .uploadProfilePicture(ReqUploadProfilePicture(image: image))
        .then((value) async {
      await setString(
          PreferenceKey.profilePicture, value.data?.thumbnail ?? '');
      _isLoading.value = false;
    }).catchError((dynamic e) {
      _isLoading.value = false;
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          debugPrint(e.error);
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  Widget _getBottomSheetAction(bool isGallery) => FittedBox(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: isGallery
                  ? () {
                      Navigator.of(context).pop();
                      _askGalleryPermission();
                    }
                  : () {
                      Navigator.of(context).pop();
                      _askCameraPermission();
                    },
              child: Icon(
                isGallery ? Icons.photo : Icons.camera_alt,
                color: ColorUtils.primaryColor,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
            Text(
              isGallery
                  ? Localization.of(context).galleryTitle
                  : Localization.of(context).cameraTitle,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      );

  void _getImageSourceBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => FittedBox(
              fit: BoxFit.cover,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _getBottomSheetAction(false),
                    _getBottomSheetAction(true),
                  ],
                ),
              ),
            ));
  }

  void _getImageSourceActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              Localization.of(context).cameraTitle,
              style: const TextStyle(
                color: Color(0xff006fff),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _askCameraPermission();
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              Localization.of(context).galleryTitle,
              style: const TextStyle(
                color: Color(0xff006fff),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _askGalleryPermission();
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            Localization.of(context).cancel,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _askCameraPermission() {
    PermissionUtils.requestPermission([Permission.camera], context,
        isOpenSettings: true,
        permissionGrant: _getImageFromCamera,
        permissionDenied: () {});
  }

  void _askGalleryPermission() {
    PermissionUtils.requestPermission(
        Platform.isAndroid
            ? [Permission.storage]
            : [Permission.photos],
        context,
        isOpenSettings: true,
        permissionGrant: _getImageFromGallery,
        permissionDenied: () {});
  }

  Future _getImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        _uploadProfilePictureApiCall(image: File(pickedFile.path));
      }
    } on Exception catch (e) {
      DialogUtils.displaySnackBar(message: e.toString());
    }
  }

  Future _getImageFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 50,
    );
    if (image != null) {
      _uploadProfilePictureApiCall(image: File(image.path));
    }
  }

  Widget _getProgressIndicator() => SizedBox(
        height: 20,
        width: 20,
        child: Center(
          child: SizedBox(
            height: 34,
            width: 35,
            child: const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ColorUtils.whiteColorLight),
            ),
          ),
        ),
      );
}
