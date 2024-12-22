
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';


import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

void main()
{
  runApp(const MyApp());
}




class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ImageUpload'),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}






class _MyHomePageState extends State<MyHomePage>
{

  final ImagePicker picker = ImagePicker();
  int _counter = 0;
  String filename = "";
  String httpresponse  = "";
  File? AttachmentFile;
  bool IsLoading = false ;


  final List<String>  imagepath = [];

  void _incrementCounter()
  {


    showModalBottomSheet(
      context: context,
      builder: (BuildContext context)
      {
        return SizedBox(
          height: 200, // Set your desired height
          child: Center(
            child: Column(
              children: [

                const SizedBox(height: 20,),

                Padding(
                padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children:
                      [
                        const Icon(Icons.camera_alt_outlined),
                        MaterialButton(onPressed: () { Navigator.pop(context); TakePhtoto();  }, child: const Text("Camera"),),
                      ],
                    ),
                ),

                Padding(
                padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.image_outlined),
                      MaterialButton(onPressed: () {Navigator.pop(context); SelectAttachmentFile (); }, child: const Text("Gallery"),),
                    ],
                  ),
                ),


              ],
            ),
          ),
        );
      },
    );

  }



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal ,
        title: Text(widget.title , style: TextStyle(color:  Colors.white ),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            filename.isEmpty ?
            const Text(
              'You have Select Image',
            )
            :

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [
                Text(
                  filename,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),


                Text(' ${imagepath.toString()}'),
                
                const SizedBox(height: 20,),
               !IsLoading ?
                 InkWell(
                   onTap: (){

                     setState(() {
                       IsLoading = true ;
                     });
                     // uploadtoServer();
                     uploadtoServer(  );
                   },
                   child: const Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children:
                     [


                       Icon(Icons.drive_folder_upload_outlined , color: Colors.teal,),
                       SizedBox (width: 10,),
                       Text('Upload' ,style: TextStyle(fontSize: 18 , color: Colors.teal),),

                     ],
                   ),
                 )
               :
               const Column(
                 children:
                 [
                   SizedBox (height: 20,),
                   CircularProgressIndicator( color: Colors.teal ,),
                   SizedBox (height: 20,),
                   Text('   Uploading Please wait ,,,,,,   '),
                 ],
               )


              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }


  //  Select File From file Manager only
  Future<void> SelectAttachmentFile() async
  {
    final XFile?  picture = await picker.pickImage( source: ImageSource.gallery );
    var  dirPath = picture?.path;
    if (dirPath != null)
    {

      setState(() {
        File file =  File(picture!.path);
        AttachmentFile = file ;
        filename = picture.name.split('-').last;
      });

    }
    else
    {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.fail,
        label: 'الرجاء اختيار ملف',
      );

    }
  }



  // Take photo from Camera
  void TakePhtoto () async
  {
    final XFile? result = await picker.pickImage(source: ImageSource.camera);
    if (result != null)
    {

      setState(() {

        File file = File(result.path);
        AttachmentFile =  file ;
        filename = result.name.toString();

      });

    }
    else
    {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.fail,
        // snackBarStyle: const SnackBarStyle(  maxLines: 1,  ),
        label: 'الرجاء اختيار ملف',
      );
    }
  }




  Future<void> uploadtoServerr({required File singlefile}) async
  {

    const JsonDecoder _decoder = JsonDecoder();
    try {
      var formData = FormData.fromMap({ 'file': await MultipartFile.fromFile(singlefile.path),
      });
      var response = await Dio().postUri(
        Uri.parse("https://hissro.net/Api/upload.php"),
        data: formData,
      );

      if (response.statusCode == 200)
      {
       var dataout =  _decoder.convert(response.data);
       var imagepathapi = dataout ["file_path"] ;

       // imagepath.add(  "https://hissro.net/Api/$imagepathapi"   );

        print( imagepath );
      } else {
        print( " Error ");
      }
    } on DioException {
      print(    "TimeOut" );
    }
  }



  



  void uploadtoServer  () async
  {

    final JsonDecoder _decoder = JsonDecoder();


    String url = "https://investor.jeddah.gov.sa/prod/api/fieldFollowUp/UploadAttachment" ;
    // String url = "https://hissro.net/ApiTest/api.php" ;
    http.MultipartRequest request = http.MultipartRequest("POST",   Uri.parse( url  ))..headers.addAll(  GetHeader( ) );
    var userfile = AttachmentFile?.path;

    request.files.add(   http.MultipartFile(  'file',  File(userfile!).readAsBytes().asStream(), File(userfile).lengthSync(),  filename: userfile.toString() .split("/").last  ) );
    request.fields['Id'] =  "569";
    request.fields['Name'] = "Test image";

    if (kDebugMode)
    {
      developer.log ('\n\n---------------------------------- Upload Follow Up Attachment   ------------------------------------------------');
      developer.log ('Upload  Result  URL: ${ url }   ');
      // developer.log ('---------------------------------------------------------------------------------------');
    }


    var response = await request.send();



    var responseData = await response.stream.toBytes();
    var result = String.fromCharCodes(responseData);

    if (kDebugMode)
    {
      // developer.log ('---------------------------------- Upload Follow Up Attachment   ------------------------------------------------');
      // developer.log ('Upload  Result  : ${ session.GetToken() }   ');
      developer.log ('Upload  Result  Id : 569  ');
      developer.log ('Upload  Result  Name: Test image   ');
      developer.log ('Upload  Result  : $result   ');
      developer.log ('Upload Network : ${ _decoder.convert(result)  }  ');
      developer.log ('---------------------------------------------------------------------------------------');
    }



    setState(()
    {
      IsLoading = false;
      // httpresponse = _decoder.convert(result) ;
    });

    // developer.log  (  _decoder.convert(result) ) ;



  }



  Map<String, String> GetHeader ( )
  {

    return
      {
        // 'Content-Type': 'application/json',
        // 'Accept': 'application/json',
        // 'charset' : 'utf-8',
        // 'accept': '*/*',
        'Content-Type': 'multipart/form-data',
        // 'Accept-Language': "ar",
        'Authorization': "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJJZCI6IkVNUDgxNSIsIlBlcm0iOlsiY2FuX3ZpZXdfQXNzZXRzIiwiY2FuX2VkaXRfQXNzZXRzIiwiY2FuX2RlbGV0ZV9Bc3NldHMiLCJjYW5fYWRkX0Fzc2V0cyIsImNhbl92aWV3X3JvbGVzIiwiY2FuX2VkaXRfcm9sZXMiLCJjYW5fZGVsZXRlX3JvbGVzIiwiY2FuX2FkZF9yb2xlcyIsImNhbl9hc3NpZ25fcm9sZXMiLCJjYW5fdmlld19wZXJtaXNzaW9ucyIsImNhbl9lZGl0X3Blcm1pc3Npb25zIiwiY2FuX2RlbGV0ZV9wZXJtaXNzaW9ucyIsImNhbl9hZGRfcGVybWlzc2lvbnMiLCJjYW5fYXNzaWduX3Blcm1pc3Npb25zIiwiY2FuX3ZpZXdfdGVuZGVycyIsImNhbl9lZGl0X3RlbmRlcnMiLCJjYW5fZGVsZXRlX3RlbmRlcnMiLCJjYW5fYWRkX3RlbmRlcnMiLCJjYW5fdmlld19hcHBsaWNhdGlvbnMiLCJjYW5fZWRpdF9hcHBsaWNhdGlvbnMiLCJjYW5fZGVsZXRlX2FwcGxpY2F0aW9ucyIsImNhbl9hZGRfYXBwbGljYXRpb25zIiwiY2FuX3ZpZXdfYXBwbGljYXRpb25fZGV0YWlscyIsIkdyYW50aW5nX1Blcm1pc3Npb25zIl0sInJvbGUiOlsiRmllbGQgT2JzZXJ2ZXIiLCJBc3NldCBNb25pdG9yaW5nIiwiTWFuYWdlck9mQXBwIiwiSW52ZXN0bWVudCBhc3NldHMiLCJUZW5kZXIgQXBwbGljYXRpb24gUmV2aWV3ZXIiLCJGaWVsZCBTdXBlcnZpc29yIiwiU3VydmV5b3IgVmlzaXQiXSwibmJmIjoxNzM0MzM3ODI1LCJleHAiOjE3MzQ3Njk4MjUsImlhdCI6MTczNDMzNzgyNX0.N94FbXWZfGNsfICtz73keZY0YQRxBvkhce72AFW3u23vedbtZX4-WZJbS6yYeeRqp-BNAIuymqxJKeqi8Hp5fg",
      };

  }


}



