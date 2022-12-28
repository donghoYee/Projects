import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';


void getPermission() async{
  final PermissionState _ps = await PhotoManager.requestPermissionExtend();
  if (_ps.isAuth) {
    print("Access granted!");
    // Granted.
  } else {
    print(_ps);
    print("Access not granted");
    PhotoManager.openSetting();
    // Limited(iOS) or Rejected, use `==` for more precise judgements.
    // You can call `PhotoManager.openSetting()` to open settings for further steps.
  }
}


Future<Widget> getImg() async {
  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(); // assets of folders and albums

  AssetPathEntity firstAlbum = paths[3];
  final List<AssetEntity> entities = await firstAlbum.getAssetListRange(start: 0, end: 5); // get 80 pics
  print(entities[1].id);
  final Widget image = AssetEntityImage(
    entities[1],

    isOriginal: false, // Defaults to `true`.
    thumbnailSize: const ThumbnailSize.square(200), // Preferred value.
    thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
  );
  return image;
}

Future<List<int>> getImgIdsFromAlbum(AssetPathEntity albumPath, {int max_count=100}) async{
  final List<AssetEntity> entities = await albumPath.getAssetListRange(start: 0, end: max_count);
  int entity_count = entities.length;

  List<int> id_list = [];
  for(int i=0; i< entity_count; i++){
    id_list.add(int.parse(entities[i].id));
  }

  return id_list;
}

Future<List<int>> getAllImgIds() async{
  List<int> ids = [];

  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(); // assets of folders and albums
  int path_len = paths.length;
  for (int album_idx=0; album_idx < path_len; album_idx ++){
    final List<int> id_list = await getImgIdsFromAlbum(paths[album_idx], max_count: 1000);

    ids.addAll(id_list);
  }
  return ids;
}

Future<Widget> getImgWidgetfromId(int id) async {
  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(); // assets of folders and albums

  final AssetEntity? asset = await AssetEntity.fromId(id.toString());
  if (asset == null)
    return Text("no such Image");
  final Widget image = AssetEntityImage(
    asset,

    isOriginal: false, // Defaults to `true`.
    thumbnailSize: const ThumbnailSize.square(200), // Preferred value.
    thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
  );
  return image;
}


Future<Uint8List?> getImgArrFromId(int id) async {
  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(); // assets of folders and albums

  final AssetEntity? asset = await AssetEntity.fromId(id.toString());
  if (asset == null)
    return null;
  if (asset.type != AssetType.image)
    return null;
  return await asset.originBytes;
}

Future<Uint8List?> getResizedImgArrFromId(int id, int width, int height) async {
  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(); // assets of folders and albums

  final AssetEntity? asset = await AssetEntity.fromId(id.toString());
  if (asset == null)
    return null;
  if (asset.type != AssetType.image)
    return null;
  return await asset.thumbnailDataWithSize(ThumbnailSize(width, height));
}
Future<Uint8List?> getSquareImgArrFromId(int id, int width) async {
  final AssetEntity? asset = await AssetEntity.fromId(id.toString());
  if (asset == null)
    return null;
  if (asset.type != AssetType.image)
    return null;
  final thumbnail =  await asset.thumbnailDataWithSize(ThumbnailSize.square(width));
  if (thumbnail == null)
    return null;
  final Croppedimg = copyResizeCropSquare(decodeImage(List<int>.from(thumbnail))!, width);
  return Uint8List.fromList(Croppedimg.data);
}