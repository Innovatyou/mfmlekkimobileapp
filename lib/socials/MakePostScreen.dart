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
    } on DioError catch (e) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(t.makepost), elevation: 0.5, actions: <Widget>[
        IconButton(
          icon: Icon(Icons.done_all),
          onPressed: () {
            validateandsubmit();
          },
        ),
      ]),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20.0, left: 10.0),
                height: 120.0,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  itemCount: _selectedFiles.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return InkWell(
                        onTap: () async {
                          return showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  scrollable: true,
                                  title: Text(
                                    t.selectfile,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  content: Container(
                                    height: 120.0,
                                    width: 400.0,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: 2,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(
                                              index == 0 ? t.images : t.video),
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
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: MyColors.mainC0lor,
                            child: Center(
                              child: Icon(
                                Icons.attach_file,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    Files _files = _selectedFiles[index - 1];
                    if (_files.type == "image") {
                      return Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 100,
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.file(
                                File.fromUri(Uri.parse(_files.link!)),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -10,
                            child: IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  size: 30,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedFiles.removeAt(index - 1);
                                  });
                                }),
                          ),
                        ],
                      );
                    }

                    return Stack(
                      children: [
                        Container(
                          height: 120,
                          width: 100,
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 80,
                              width: 80,
                              child: Image.asset(
                                Img.get('video_thumbnail.jpg'),
                                height: 80,
                                width: 80,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                size: 30,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedFiles.removeAt(index - 1);
                                });
                              }),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 15, 0),
                    child: Text(_selectedFiles.length.toString() + "/10"),
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              Divider(
                height: 20,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextField(
                    style: TextStyle(fontSize: 20),
                    maxLength: 500,
                    maxLines: null,
                    controller: contentController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: t.shareYourThoughtsNow,
                      hintStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}


