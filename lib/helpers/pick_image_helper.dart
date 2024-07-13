import 'package:commute_guide/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> chooseAndCropImage({
  required BuildContext context,
  required ImageSource source,
  CropAspectRatio? aspectRatio,
}) async {
  final ImagePicker picker = ImagePicker();
  final photo = await picker.pickImage(
    source: source,
    requestFullMetadata: false,
    preferredCameraDevice: CameraDevice.front,
  );

  if (photo == null) return null;
  if (!context.mounted) return null;
  return await _cropImage(photo, aspectRatio, context);
}

Future<XFile?> _cropImage(
  XFile? file,
  CropAspectRatio? aspectRatio,
  BuildContext context,
) async {
  if (file == null) return null;

  return await _cropAndCompressImage(file, aspectRatio, context);
}

Future<XFile?> _cropAndCompressImage(
  XFile image,
  CropAspectRatio? aspectRatio,
  BuildContext context,
) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: image.path,
    compressQuality: 100,
    aspectRatio: aspectRatio,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Image Crop',
        toolbarColor: AppColors.primaryBlue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
        activeControlsWidgetColor: AppColors.primaryBlue,
      ),
      IOSUiSettings(
        title: 'Image Crop',
        aspectRatioLockEnabled: true,
        cancelButtonTitle: 'Cancel',
        doneButtonTitle: 'Done',
        showCancelConfirmationDialog: true,
      ),
      WebUiSettings(context: context),
    ],
  );
  if (croppedFile == null) return null;

  image = XFile.fromData(
    await croppedFile.readAsBytes(),
    mimeType: 'image/jpeg',
    name: image.name,
    path: croppedFile.path,
  );

  return image;
}
