import 'package:dio/dio.dart';

import 'package:higherground/utils/my_colors.dart';
import 'dart:convert';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/models/Userdata.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:file_picker/file_picker.dart';
import 'package:higherground/models/Files.dart';
import 'package:higherground/utils/img.dart';

class MakePostScreen extends StatefulWidget {
  static const routeName = "/makepostscreen";
  MakePostScreen();

  @override
  MakePostScreenState createState() => new MakePostScreenState();
}

class MakePostScreenState extends State<MakePostScreen> {
  Userdata? userdata;
  TextEditingController contentController = TextEditingController();
  List<Files> _selectedFiles = [];

  pickVideos() async {
    if (_selectedFiles.length >= 10) {
      Alerts.showToast(context, t.maximumallowedsizehint);
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // allowCompression: true,
      allowMultiple: false,
      withData: false,
      allowedExtensions: ['mp4'],
    );
    if (mounted) {
      if (result != null) {
        PlatformFile file = result.files.first;

        print(file.name);
        //print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);
        if (file.size > (100024 * 10)) {
          Alerts.showToast(context, t.maximumuploadsizehint);
          return;
        }

        final filePath = file.path!;
        // print("video absolute path " + filePath);
        _selectedFiles.add(new Files(
          link: filePath,
            type: "video",
            filetype: file.extension,
            length: file.size,
            thumbnail: "null"));
        //genThumbnailFile(_selectedFiles.length - 1);
      }
      setState(() {});
    }
  }

  pickImages() async {
    if (_selectedFiles.length >= 10) {
      Alerts.showToast(context, t.maximumallowedsizehint);
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowCompression: true,
      allowMultiple: false,
      withData: false,
      allowedExtensions: ['png', 'PNG', 'JPEG', 'JPG', 'jpg', 'jpeg', 'gif'],
    );
    if (mounted) {
      if (result != null) {
        PlatformFile file = result.files.first;

        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);
        if (file.size > (1024 * 10000)) {
          Alerts.showToast(context, t.maximumuploadsizehint);
          return;
        }

        _selectedFiles.add(new Files(
          link: file.path,
          type: "image",
          filetype: file.extension,
          length: file.size,
        ));
      }
      setState(() {});
    }
  }

  validateandsubmit() async {
    String _content = contentController.text;
    if (_content == "" && _selectedFiles.length == 0) {
      return;
    }
    submitPosttoServer(_content);
  }

  submitPosttoServer(
    String content,
  ) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    
    // Build FormData for multipart request
    FormData formData = FormData.fromMap({
      "email": userdata!.email,
      "visibility": "public",
      "content": Utility.getBase64EncodedString(content),
      // Also include plain text content; some backends expect raw text
      "content_raw": content,
    });
    
    // Add files to FormData
    _selectedFiles.forEach((element) {
      final fileIndex = _selectedFiles.indexOf(element);
      print("Adding file $fileIndex: ${element.link}");
      formData.files.add(MapEntry(
          "files_$fileIndex",
          MultipartFile.fromFileSync(element.link!)));
    });
    
    print("=== POST REQUEST DEBUG ===");
    print("Endpoint: ${ApiUrl.makePost}");
    print("Email: ${userdata!.email}");
    print("Files Count: ${_selectedFiles.length}");
    print("Content Length: ${content.length}");
    print("FormData fields: ${formData.fields}");
    print("FormData files count: ${formData.files.length}");
    print("========================");
    
    try {
      var dio = await Utility.getAuthenticatedDio();
      print("Dio headers: ${dio.options.headers}");
      var response = await dio.post(
        ApiUrl.makePost,
        data: formData,
        onSendProgress: (int send, int total) {
          print("Upload progress: ${(send / total * 100).toStringAsFixed(2)}%");
        },
      );
      
      Navigator.of(context).pop();
      print("Response Status: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Data: ${response.data}");

      Map<String, dynamic> res;
      if (response.data is String) {
        try {
          res = json.decode(response.data);
        } catch (e) {
          res = {};
        }
      } else if (response.data is Map) {
        res = Map<String, dynamic>.from(response.data);
      } else {
        res = {};
      }
      if (res["status"] == "error") {
        String errorMsg = res["message"] ?? t.makeposterror;
        print("Server returned error: $errorMsg");
        Alerts.show(context, t.error, errorMsg);
        return;
      }
      Navigator.pop(context, true);
    } on DioException catch (e) {
      Navigator.of(context).pop();
      print("=== DIO ERROR DEBUG ===");
      print("Error Type: ${e.type}");
      print("Error Message: ${e.message}");
      print("Error Status Code: ${e.response?.statusCode}");
      
      if (e.response != null) {
        print("Request headers: ${e.requestOptions.headers}");
        print("Response Status: ${e.response!.statusCode}");
        print("Response Data: ${e.response!.data}");
        print("Response Headers: ${e.response!.headers}");
        
        // Extract error message from server response
        String errorMsg = e.message ?? e.toString();
        try {
          if (e.response!.data is String) {
            Map<String, dynamic> errorData = json.decode(e.response!.data);
            errorMsg = errorData["message"] ?? errorMsg;
          } else if (e.response!.data is Map) {
            errorMsg = e.response!.data["message"] ?? errorMsg;
          }
        } catch (parseError) {
          print("Error parsing response: $parseError");
        }
        
        if (e.response!.statusCode == 500) {
          errorMsg = "Server error (500). Please try again later or contact support.";
        }
        
        Alerts.show(context, t.error, errorMsg);
      } else {
        print("No response object available");
        Alerts.show(context, t.error, e.message);
      }
      print("======================");
    }
  }

  @override
  void initState() {
    userdata = Provider.of<AppStateManager>(context, listen: false).userdata;
    super.initState();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        title: Text(
          t.makepost,
          style: const TextStyle(
            color: Color(0xFF23141D),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
            child: ElevatedButton.icon(
              onPressed: validateandsubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.mainC0lor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Post'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8DDE4)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, color: Color(0xFF563349)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.selectfile,
                          style: const TextStyle(
                            color: Color(0xFF23141D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2E6EC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_selectedFiles.length}/10',
                          style: const TextStyle(
                            color: Color(0xFF563349),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 106,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: Text(
                                        t.selectfile,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: SizedBox(
                                        height: 120,
                                        width: 400,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: 2,
                                          itemBuilder: (BuildContext context, int index) {
                                            return ListTile(
                                              title: Text(index == 0 ? t.images : t.video),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                if (index == 0) {
                                                  pickImages();
                                                } else {
                                                  pickVideos();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              width: 86,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: MyColors.mainC0lor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          );
                        }

                        Files file = _selectedFiles[index - 1];
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 86,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xFFF5EEF2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: file.type == "image"
                                    ? Image.file(
                                        File.fromUri(Uri.parse(file.link!)),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        Img.get('video_thumbnail.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              right: -4,
                              top: -8,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFiles.removeAt(index - 1);
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8DDE4)),
                ),
                child: TextField(
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF23141D),
                    height: 1.35,
                  ),
                  maxLength: 500,
                  maxLines: null,
                  expands: true,
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: t.shareYourThoughtsNow,
                    hintStyle: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF9A8A94),
                    ),
                    counterStyle: const TextStyle(
                      color: Color(0xFF8A7D86),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


