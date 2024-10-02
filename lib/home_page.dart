import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // Import Syncfusion PDF package

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _pickedPdf;
  int _pageNumber = 1;
  double _speechRate = 1.0;
  String _pdfText = '';
                              
  bool _isSpeaking = false;

  // Function to pick a PDF file
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedPdf = File(result.files.single.path!);
        _pdfText = ''; // Clear previous text
      });
    }
  }

  // Function to extract text from a specific page
  Future<void> _extractText(int pageNumber) async {
    if (_pickedPdf != null) {
      // Read the PDF document
      final PdfDocument document =
          PdfDocument(inputBytes: _pickedPdf!.readAsBytesSync());
      if (pageNumber <= document.pages.count && pageNumber > 0) {
        // Extract text from the specified page
        String text =
            PdfTextExtractor(document).extractText(startPageIndex: pageNumber);
        setState(() {
          _pdfText = text; // Update the text
        });
      } else {
        setState(() {
          _pdfText = 'Invalid page number.';
        });
      }
      document.dispose(); // Dispose of the document after use
    }
  }

  FlutterTts flutterTts = FlutterTts();
  // Function to convert extracted text to speech
  void _speakText() {
    if (_pdfText.isNotEmpty) {
      flutterTts.setSpeechRate(_speechRate);
      flutterTts.speak(_pdfText);
      setState(() {
        _isSpeaking = true;
      });
    }
  }

  // Function to stop speaking
  void _stopSpeaking() {
    flutterTts.stop();

    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Speech'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickPdf,
              child: const Text('Pick PDF'),
            ),
            const SizedBox(height: 16),
            if (_pickedPdf != null) ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter page number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _pageNumber = int.parse(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _extractText(_pageNumber);
                },
                child: const Text('Extract Text'),
              ),
              const SizedBox(height: 16),
              if (_pdfText.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(_pdfText),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Speech Rate:'),
                  Slider(
                    value: _speechRate,
                    min: 0.5,
                    max: 2.0,
                    divisions: 10,
                    label: _speechRate.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _speechRate = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isSpeaking)
                ElevatedButton(
                  onPressed: _stopSpeaking,
                  child: const Text('Stop Speaking'),
                )
              else
                ElevatedButton(
                  onPressed: _speakText,
                  child: const Text('Speak Text'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
