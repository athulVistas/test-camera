import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestPermission(Permission p) async {
  return await p.request().isGranted;
}

Future<bool> _hasAcceptedPermissions() async {
  if (Platform.isAndroid) {
    if (await _requestPermission(Permission.storage) &&
        // access media location needed for android 10/Q
        await _requestPermission(Permission.accessMediaLocation) &&
        // manage external storage needed for android 11/R
        await _requestPermission(Permission.manageExternalStorage)) {
      return true;
    } else {
      return false;
    }
  }
  if (Platform.isIOS) {
    if (await _requestPermission(Permission.photos)) {
      return true;
    } else {
      return false;
    }
  } else {
    // not android or ios
    return false;
  }
}

Future<bool> saveVideo(XFile xFile, String fileName) async {
  Directory? directory;
  try {
    _hasAcceptedPermissions();
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        print(directory);
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        // newPath = newPath + "/RPSApp";
        newPath += "/Download";
        directory = Directory(newPath);
      } else {
        return false;
      }
    } else {
      if (await Permission.videos.request().isGranted) {
        print("videos directory p granted");
        // directory = await getTemporaryDirectory();
      } else {
        return false;
      }
    }

    // if (!await directory.exists()) {
    //   await directory.create(recursive: true);
    // }
    if (await directory!.exists()) {
      // File saveFile = File(directory.path + "/$fileName");
      File videoFile = File(xFile.path);
      String fileFormat = videoFile.path.split('.').last;

      await videoFile.copy(
        '${directory.path}/temp.$fileFormat',
      );
      // if (Platform.isIOS) {
      //   await ImageGallerySaver.saveFile(saveFile.path,
      //       isReturnPathOfIOS: true);
      // }
      return true;
    }
  } catch (e) {
    print(e);
  }
  return false;
}
