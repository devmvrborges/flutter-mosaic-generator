import 'dart:io';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

enum StepperStep {
  chooseSize,
  selectImage,
  configureColors,
}

int _value = 0;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        highlightColor: const Color(0xFFD0996F),
        canvasColor: const Color(0xFFFDF5EC),
        textTheme: TextTheme(
          headlineSmall: ThemeData.light()
              .textTheme
              .headlineSmall!
              .copyWith(color: const Color(0xFFBC764A)),
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[600],
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFBC764A),
          centerTitle: false,
          foregroundColor: Colors.white,
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateColor.resolveWith(
                (states) => const Color(0xFFBC764A)),
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => Colors.white,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => const Color(0xFFBC764A),
            ),
            side: WidgetStateBorderSide.resolveWith(
                (states) => const BorderSide(color: Color(0xFFBC764A))),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => const Color(0xFFBC764A),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => const Color(0xFFBC764A),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          surface: const Color(0xFFFDF5EC),
          primary: const Color(0xFFD0996F),
        ),
      ),
      home: const HomePage(title: 'O mosaico'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !kIsWeb ? AppBar(title: Text(widget.title)) : null,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.all(kIsWeb ? 6.0 : 4.0),
              child: Center(
                child: Text(
                  widget.title,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: Theme.of(context).highlightColor),
                ),
              ),
            ),
          ExcludeFocus(child: StepperPage()),
          // Expanded(child: _radioButtons()),
          // Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                child: _image(),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            _clear();
          },
          backgroundColor: Colors.redAccent,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        // if (_croppedFile == null)
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            onPressed: () {
              _cropImage();
            },
            backgroundColor: const Color(0xFFBC764A),
            tooltip: 'Crop',
            child: const Icon(Icons.crop),
          ),
        )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: kIsWeb ? 380.0 : 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: Theme.of(context).highlightColor.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).highlightColor,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Upload an image to start',
                            style: kIsWeb
                                ? Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: Theme.of(context).highlightColor)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color:
                                            Theme.of(context).highlightColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }
}

class StepperPage extends StatefulWidget {
  @override
  _StepperPageState createState() => _StepperPageState();
}

class _StepperPageState extends State<StepperPage> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // navigationBar: CupertinoNavigationBar(
      //   middle: Text('CupertinoStepper for Flutter'),
      // ),
      child: SafeArea(
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            switch (orientation) {
              case Orientation.portrait:
                return _buildStepper(StepperType.vertical);
              case Orientation.landscape:
                return _buildStepper(StepperType.horizontal);
              default:
                throw UnimplementedError(orientation.toString());
            }
          },
        ),
      ),
    );
  }

  CupertinoStepper _buildStepper(StepperType type) {
    final canCancel = currentStep > 0;
    final canContinue = currentStep < 3;
    return CupertinoStepper(
      type: type,
      currentStep: currentStep,
      onStepTapped: (step) => setState(() => currentStep = step),
      onStepCancel: canCancel ? () => setState(() => --currentStep) : null,
      onStepContinue: canContinue ? () => setState(() => ++currentStep) : null,
      steps: [
        for (var step in StepperStep.values)
          _buildStep(
            title: _getStepTitle(step),
            subtitle: _getStepSubtitle(step),
            current_step: step,
            state: step == StepperStep.values[currentStep]
                ? StepState.editing
                : step.index < currentStep
                    ? StepState.complete
                    : StepState.indexed,
          ),
      ],
    );
  }

  Widget _getStepTitle(StepperStep step) {
    switch (step) {
      case StepperStep.chooseSize:
        return Text('Escolha o tamanho');
      case StepperStep.selectImage:
        return Text('Selecione a imagem');
      case StepperStep.configureColors:
        return Text('Configure as cores');
    }
  }

  Text _getStepSubtitle(StepperStep step) {
    switch (step) {
      case StepperStep.chooseSize:
        return const Text('Selecione o tamanho do mosaico');
      case StepperStep.selectImage:
        return const Text('Selecione a imagem para o mosaico');
      case StepperStep.configureColors:
        return const Text('Selecione as cores disponíveis para o mosaico');
    }
  }

  Widget _getStepContent(StepperStep step) {
    switch (step) {
      case StepperStep.chooseSize:
        return _radioButtons();
      case StepperStep.selectImage:
        return Container();
      case StepperStep.configureColors:
        return Container();
    }
  }

  Step _buildStep({
    required Widget title,
    required Text subtitle,
    StepState state = StepState.indexed,
    bool isActive = false,
    required StepperStep current_step,
  }) {
    return Step(
      title: title,
      subtitle: subtitle,
      state: state,
      isActive: isActive,
      content: _getStepContent(current_step),
    );
  }

  Widget _radioButtons() {
    Widget _radioButtons() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() => _value = 0);
            },
            child: Container(
              height: 100,
              width: 100,
              color: _value == 0 ? Colors.grey : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.square),
                  Text('32x32'),
                  Text('1025 peças'),
                ],
              ),
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() => _value = 1);
            },
            child: Container(
              height: 100,
              width: 100,
              color: _value == 1 ? Colors.grey : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.square),
                      Icon(CupertinoIcons.square),
                    ],
                  ),
                  Text('32x64'),
                  Text('2050 peças'),
                ],
              ),
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _value = 2),
            child: Container(
              height: 100,
              width: 100,
              color: _value == 2 ? Colors.grey : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(CupertinoIcons.square),
                      Icon(CupertinoIcons.square),
                    ],
                  ),
                  Text('64x32'),
                  Text('2050 peças'),
                ],
              ),
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _value = 3),
            child: Container(
              height: 100,
              width: 100,
              color: _value == 3 ? Colors.grey : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.square),
                      Icon(CupertinoIcons.square),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.square),
                      Icon(CupertinoIcons.square),
                    ],
                  ),
                  Text('64x64'),
                  Text('4100 peças'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _radioButtons();
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
