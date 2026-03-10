import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimens.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/permission_util.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import 'model/req_upload_documents.dart';
import 'model/res_my_documents.dart';

class UploadDocumentScreen extends StatefulWidget {
  final bool isFromUpload;

  const UploadDocumentScreen({Key? key, this.isFromUpload = false})
    : super(key: key);

  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isFromUpload', isFromUpload));
  }
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  List<MyDocumentsModel> _documentsList = <MyDocumentsModel>[];
  late Future<ResMyDocumentsModel> _futureDocumentsList;
  List<MyDocumentsModel> _filesForIndividual = <MyDocumentsModel>[];
  List<MyDocumentsModel> _filesForCorporate = <MyDocumentsModel>[];
  final ImagePicker _picker = ImagePicker();
  String _userType = '';
  bool _didInitLocalizedDocs = false;

  @override
  void initState() {
    super.initState();
    _userType = getString(PreferenceKey.businessCategories) ?? '';
    if (!widget.isFromUpload) {
      _getDocumentsApiCall();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitLocalizedDocs) {
      return;
    }
    _didInitLocalizedDocs = true;
    _initDocumentTemplates();
  }

  void _initDocumentTemplates() {
    _filesForIndividual = [
      MyDocumentsModel(documentType: Localization.of(context).idCard),
      MyDocumentsModel(documentType: Localization.of(context).bankStatement),
    ];
    _filesForCorporate = [
      MyDocumentsModel(documentType: Localization.of(context).cacCertificate),
      MyDocumentsModel(documentType: Localization.of(context).cacFormA),
      MyDocumentsModel(
        documentType: Localization.of(context).meansOfIdentification,
      ),
      MyDocumentsModel(documentType: Localization.of(context).utilitybill),
    ];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: !widget.isFromUpload
            ? Localization.of(context).myDocumentHeader
            : Localization.of(context).uploadDocumentHeader,
        isBackGround: false,
        isHideBackButton: widget.isFromUpload,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.isFromUpload
                  ? SingleChildScrollView(child: _getDocumentBody())
                  : FutureBuilder<ResMyDocumentsModel>(
                      future: _futureDocumentsList,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container();
                        } else if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done) {
                          return SingleChildScrollView(
                            child: _getDocumentBody(),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              backgroundColor: ColorUtils.primaryColor,
                            ),
                          );
                        }
                      },
                    ),
            ),
            getInt(PreferenceKey.isApprovedByAdmin) == 0
                ? _getSubmitButton(context: context)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _getDocumentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_getDocumentList(), if (isUserApp()) _getFaceCaptureCard()],
    );
  }

  Widget _getDocumentList() {
    return ListView.builder(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userType == BusinessCategories.individual.getName()
          ? _filesForIndividual.length
          : _filesForCorporate.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemBuilder: (context, index) {
        return _getBrowseWidget(
          file: _userType == BusinessCategories.individual.getName()
              ? _filesForIndividual[index]
              : _filesForCorporate[index],
          index: index,
        );
      },
    );
  }

  Widget _getFaceCaptureCard() {
    return Container(
      margin: const EdgeInsets.only(
        left: spacingLarge,
        right: spacingLarge,
        top: spacingLarge,
      ),
      padding: const EdgeInsets.all(spacingMedium),
      decoration: BoxDecoration(
        color: ColorUtils.bvnBgColor,
        border: Border.all(color: ColorUtils.bvnBorderColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Face Capture (Liveness Check)',
                  style: TextStyle(
                    fontFamily: fontFamilyPoppinsMedium,
                    fontSize: 14.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingSmall,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF7E8),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xffF0D9AD)),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Color(0xff8B5A00),
                    fontSize: fontSmall,
                    fontFamily: fontFamilyPoppinsMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: spacingSmall),
          _getFaceCaptureStatusRow(isComplete: true, text: 'Face captured'),
          const SizedBox(height: spacingTiny),
          _getFaceCaptureStatusRow(
            isComplete: false,
            text: 'Liveness check running',
          ),
        ],
      ),
    );
  }

  Widget _getFaceCaptureStatusRow({
    required bool isComplete,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
          color: isComplete ? const Color(0xff1f7a32) : const Color(0xff8b5a00),
          size: spacingMedium,
        ),
        const SizedBox(width: spacingTiny),
        Text(
          text,
          style: const TextStyle(
            fontSize: fontSmall,
            fontFamily: fontFamilyPoppinsRegular,
          ),
        ),
      ],
    );
  }

  Widget _getBrowseWidget({
    required MyDocumentsModel file,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            file.documentType ?? '',
            style: const TextStyle(
              color: ColorUtils.primaryTextColor,
              fontSize: 14.0,
              fontFamily: fontFamilyPoppinsMedium,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          InkWell(
            onTap: () {
              if ((file.isApproved ?? 0) == 0) {
                if (Platform.isIOS) {
                  _getImageSourceActionSheet(file: file);
                } else {
                  _getImageSourceBottomSheet(file: file);
                }
              }
            },
            child: Container(
              height: 225,
              margin: const EdgeInsets.only(top: 10.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColorUtils.homeBackgroundColor),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: AlignmentDirectional.topEnd,
                fit: StackFit.expand,
                children: [
                  file.type == DocumentExt.img.getName() &&
                          (file.document?.isNotEmpty ?? false)
                      ? Image.network(file.document ?? '', fit: BoxFit.cover)
                      : Image.asset(ImageConstants.icPDF),
                  (file.isApproved ?? 0) == 0
                      ? Positioned(
                          top: -10,
                          right: -10,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                file.id = null;
                                file.document = null;
                              });
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: ColorUtils.primaryColor,
                              ),
                              child: Image.asset(
                                ImageConstants.icClose,
                                scale: 2.5,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSubmitButton({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).save,
        isBackground: true,
        onButtonClick: () {
          changeScreen(context);
        },
      ),
    );
  }

  void changeScreen(BuildContext context) {
    setBool(PreferenceKey.isDocumentUploaded, true);
    if (getString((PreferenceKey.kycStatus)) == DicParams.notVerified) {
      NavigationUtils.pushAndRemoveUntil(
        context,
        routeCompleteKYC,
        arguments: {
          NavigationParams.showBackButton: false,
          NavigationParams.completeTransactionDetails: false,
        },
      );
    } else {
      if (isUserApp()) {
        NavigationUtils.pushAndRemoveUntil(context, routeMainTab);
      } else {
        NavigationUtils.pushAndRemoveUntil(context, routeMerchantMainTab);
      }
    }
  }

  Future<void> _pickedPdf({required MyDocumentsModel file}) async {
    final result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final pickedFile = result?.files.single;
    if (pickedFile != null && pickedFile.path != null) {
      _uploadDocumentApiCall(
        document: File(pickedFile.path!),
        file: file,
        mimeType: DicParams.mediaTypeApplication,
        mimeSubType: DicParams.mediaTypePdf,
      );
    }
  }

  Future<void> _getImageFromGallery({required MyDocumentsModel file}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );
      if (pickedFile != null) {
        _uploadDocumentApiCall(
          document: File(pickedFile.path),
          file: file,
          mimeType: DicParams.mediaTypeImage,
          mimeSubType: DicParams.mediaTypejpg,
        );
      }
    } on Exception catch (e) {
      DialogUtils.displaySnackBar(message: e.toString());
    }
  }

  Future<void> _getImageFromCamera({required MyDocumentsModel file}) async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 40,
    );
    if (image != null) {
      _uploadDocumentApiCall(
        document: File(image.path),
        file: file,
        mimeType: DicParams.mediaTypeImage,
        mimeSubType: DicParams.mediaTypejpg,
      );
    }
  }

  void _getImageSourceBottomSheet({required MyDocumentsModel file}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.1,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: GestureDetector(
                        onTap: () {
                          PermissionUtils.requestPermission(
                            [Permission.camera],
                            context,
                            isOpenSettings: true,
                            permissionGrant: () {
                              _getImageFromCamera(file: file);
                            },
                            permissionDenied: () {},
                          );
                          NavigationUtils.pop(context);
                        },
                        child: Icon(
                          Icons.camera_alt,
                          color: ColorUtils.primaryColor,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                      ),
                    ),
                    Text(
                      Localization.of(context).cameraTitle,
                      style: const TextStyle(fontSize: 12.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: GestureDetector(
                      onTap: () {
                        PermissionUtils.requestPermission(
                          Platform.isAndroid
                              ? [Permission.storage]
                              : [Permission.photos],
                          context,
                          isOpenSettings: true,
                          permissionGrant: () {
                            _getImageFromGallery(file: file);
                          },
                          permissionDenied: () {},
                        );
                        NavigationUtils.pop(context);
                      },
                      child: Icon(
                        Icons.photo,
                        color: ColorUtils.primaryColor,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                    ),
                  ),
                  Text(
                    Localization.of(context).galleryTitle,
                    style: const TextStyle(fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: GestureDetector(
                      onTap: () {
                        _pickedPdf(file: file);
                        NavigationUtils.pop(context);
                      },
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: ColorUtils.primaryColor,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                    ),
                  ),
                  Text(
                    Localization.of(context).pdfTitle,
                    style: const TextStyle(fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getImageSourceActionSheet({required MyDocumentsModel file}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              Localization.of(context).cameraTitle,
              style: const TextStyle(color: Color(0xff006fff)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              PermissionUtils.requestPermission(
                [Permission.camera],
                context,
                isOpenSettings: true,
                permissionGrant: () {
                  _getImageFromCamera(file: file);
                },
                permissionDenied: () {},
              );
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              Localization.of(context).galleryTitle,
              style: const TextStyle(color: Color(0xff006fff)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              PermissionUtils.requestPermission(
                Platform.isAndroid ? [Permission.storage] : [Permission.photos],
                context,
                isOpenSettings: true,
                permissionGrant: () {
                  _getImageFromGallery(file: file);
                },
                permissionDenied: () {},
              );
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              Localization.of(context).pdfTitle,
              style: const TextStyle(color: Color(0xff006fff)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _pickedPdf(file: file);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            Localization.of(context).cancel,
            style: const TextStyle(color: Colors.red),
          ),
          onPressed: () {
            NavigationUtils.pop(context);
          },
        ),
      ),
    );
  }

  void _uploadDocumentApiCall({
    required File document,
    required MyDocumentsModel file,
    required String mimeType,
    required String mimeSubType,
  }) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .uploadDocument(
          request: ReqUploadDocuments(
            image: document,
            documentType: file.documentType,
          ),
          mimeType: mimeType,
          mimeSubType: mimeSubType,
        )
        .then((value) async {
          ProgressDialogUtils.dismissProgressDialog();
          await setInt(
            PreferenceKey.isApprovedByAdmin,
            value.data?.isApproved ?? 0,
          );
          await DialogUtils.displayToast(value.message ?? '');
          setState(() {
            file.id = value.data?.id;
            file.documentType = value.data?.documentType;
            file.document = value.data?.document;
            file.isApproved = 0;
            file.type = value.data?.type;
          });
        })
        .catchError((dynamic e) {
          ProgressDialogUtils.dismissProgressDialog();
          if (e is ResBaseModel) {
            if (!checkSessionExpire(e, context)) {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
  }

  void _getDocumentsApiCall() {
    _futureDocumentsList = UserApiManager().getDocumentes();

    _futureDocumentsList.then((value) {
      setState(() {
        _documentsList = value.data ?? <MyDocumentsModel>[];
        if (_userType == BusinessCategories.individual.getName()) {
          for (final doc in _documentsList) {
            if (doc.documentType == Localization.of(context).idCard) {
              _filesForIndividual[0] = doc;
            } else if (doc.documentType ==
                Localization.of(context).bankStatement) {
              _filesForIndividual[1] = doc;
            }
          }
        } else {
          for (final doc in _documentsList) {
            if (doc.documentType == Localization.of(context).cacCertificate) {
              _filesForCorporate[0] = doc;
            } else if (doc.documentType == Localization.of(context).cacFormA) {
              _filesForCorporate[1] = doc;
            } else if (doc.documentType ==
                Localization.of(context).meansOfIdentification) {
              _filesForCorporate[2] = doc;
            } else if (doc.documentType ==
                Localization.of(context).utilitybill) {
              _filesForCorporate[3] = doc;
            }
          }
        }
      });
    });
  }
}
