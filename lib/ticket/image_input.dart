import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

 class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;


  @override
  State<ImageInput> createState(){
    throw _ImageInputState();
  }
 }

 class _ImageInputState extends State<ImageInput> {
  //Preview
   File? _selectedImage;

  void _takePicture() async{
    final imagePicker = ImagePicker();
    //ImageSource.galery auch möglich
    final pickedImage = 
      await imagePicker.pickImage(source: ImageSource.camera,maxWidth: 600);

    if(pickedImage==  null){
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
    
      } 
  void _selectPicture() async{
    final imagePicker = ImagePicker();
    //ImageSource.galery auch möglich
    final pickedImage = 
      await imagePicker.pickImage(source: ImageSource.gallery,maxWidth: 600);

    if(pickedImage==  null){
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  @override
  Widget build(BuildContext context){
      Widget content = TextButton.icon(
        icon: const Icon(Icons.camera),
          label: const Text('Take Picture'),
          onPressed: _takePicture,
      );
      if(_selectedImage != null){
        content = GestureDetector(
          //nochmal neues bild erstellen wenn man drauf klickt
          onTap: _takePicture,
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height:double.infinity,
          ),
        );
      }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width:1, color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      height:250,
      width:double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
 }