import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';

class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final Dio _dio = DioClient.instance.dio;

  /// Compress + Upload ke S3 via presigned URL
  /// Returns URL CDN file hasil upload
  Future<String> uploadImage(File file, String folder) async {
    // 1. Compress file
    final compressedFile = await _compressImage(file);

    // 2. Get pre-signed URL dari backend
    final fileName = '${folder}/${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final presignedResponse = await _dio.get(
      '/upload/presigned-url',
      queryParameters: {'key': fileName, 'content_type': 'image/jpeg'},
    );

    final presignedUrl = presignedResponse.data['data']['presigned_url'] as String;
    final fileUrl = presignedResponse.data['data']['file_url'] as String;

    // 3. Upload ke S3 langsung (PUT request, bypass auth interceptor)
    final rawDio = Dio(); // Naked Dio tanpa auth header
    await rawDio.put(
      presignedUrl,
      data: compressedFile.readAsBytesSync(),
      options: Options(
        headers: {
          'Content-Type': 'image/jpeg',
          'Content-Length': compressedFile.lengthSync(),
        },
      ),
    );

    return fileUrl;
  }

  /// Upload multiple paralel
  Future<List<String>> uploadMultiple(List<File> files, String folder) async {
    return Future.wait(files.map((f) => uploadImage(f, folder)));
  }

  /// Compress image: quality 80, maxWidth 1024
  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1024,
      minHeight: 1024,
    );

    return result != null ? File(result.path) : file;
  }

  /// Widget progress bar yang bisa dipanggil saat upload berlangsung
  static Widget buildUploadProgress(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mengupload foto...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200]!,
            progressColor: const Color(0xFF2D7A4F),
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  static void showUploadProgress(BuildContext context, double progress) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: buildUploadProgress(progress),
        actions: const [SizedBox.shrink()],
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  static void hideUploadProgress(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }
}
