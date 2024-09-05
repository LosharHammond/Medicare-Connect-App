import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DiseasePredictionApp());
}

class DiseasePredictionApp extends StatelessWidget {
  const DiseasePredictionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'PlayfairDisplay',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.red,
        ),
      ),
      home: const DiseasePredictionScreen(),
    );
  }
}

class DiseasePredictionScreen extends StatefulWidget {
  const DiseasePredictionScreen({Key? key}) : super(key: key);

  @override
  _DiseasePredictionScreenState createState() =>
      _DiseasePredictionScreenState();
}

class _DiseasePredictionScreenState extends State<DiseasePredictionScreen> {
  final List<String> _selectedSymptoms = [];
  List<Map<String, dynamic>> _predictedDiseases = [];
  List<Map<String, dynamic>> _detectedCriticalDiseases = [];
  List<String> _criticalDiseases = [];
  Map<String, List<String>> symptomDiseaseMap = {};
  List<String> _symptoms = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirebase();
  }

  Future<void> _fetchDataFromFirebase() async {
    try {
      // Fetch critical diseases
      final criticalDiseasesSnapshot =
          await FirebaseFirestore.instance.collection('criticalDiseases').get();
      _criticalDiseases = criticalDiseasesSnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();

      // Fetch symptoms and diseases mapping
      final symptomDiseaseMapSnapshot = await FirebaseFirestore.instance
          .collection('symptomDiseaseMap')
          .get();
      symptomDiseaseMap = {};
      for (var doc in symptomDiseaseMapSnapshot.docs) {
        String disease = doc['disease'];
        List<String> symptoms = List<String>.from(doc['symptoms']);
        symptomDiseaseMap[disease] = symptoms;
      }

      // Fetch symptoms
      final symptomsSnapshot =
          await FirebaseFirestore.instance.collection('symptoms').get();
      _symptoms =
          symptomsSnapshot.docs.map((doc) => doc['name'] as String).toList();

      print('Symptoms fetched: $_symptoms'); // Debugging line

      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _addSymptomDiseaseMapping() async {
    try {
      await FirebaseFirestore.instance.collection('symptomDiseaseMap').add({
        'disease': 'Common Cold',
        'symptoms': [
          'Fever',
          'Cough',
          'Sore Throat',
          'Runny Nose',
          'Congestion',
          'Headache',
          'Sneezing',
          'Malaise'
        ],
      });
    } catch (e) {
      print('Error adding mapping: $e');
    }
  }

  List<Map<String, dynamic>> predictDisease(List<String> selectedSymptoms) {
    final selectedSet = Set<String>.from(selectedSymptoms);
    List<Map<String, dynamic>> predictions = [];

    symptomDiseaseMap.forEach((disease, symptoms) {
      int matchCount = selectedSet.intersection(symptoms.toSet()).length;
      if (matchCount > 0) {
        double probability = (matchCount / symptoms.length) * 100;
        predictions.add({'disease': disease, 'probability': probability});
      }
    });

    predictions.sort((a, b) => b['probability'].compareTo(a['probability']));
    return predictions;
  }

  void _onPredictButtonPressed() {
    setState(() {
      _predictedDiseases = predictDisease(_selectedSymptoms);
      _checkForCriticalDiseases();
    });
  }

  void _checkForCriticalDiseases() {
    _detectedCriticalDiseases = _predictedDiseases
        .where((disease) =>
            _criticalDiseases.contains(disease['disease'].toString()))
        .toList();

    if (_detectedCriticalDiseases.isNotEmpty) {
      print('Critical diseases detected: $_detectedCriticalDiseases');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Predict Disease',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        backgroundColor: Colors.white70,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildDropdownSearchBar(),
                const SizedBox(height: 20),
                _buildSelectedSymptomsCard(),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _onPredictButtonPressed,
                  child: const Text(
                    'Predict Disease',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                SizedBox(height: 40),
                _buildPredictedDiseasesCard(),
                if (_detectedCriticalDiseases.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Card(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Critical Diseases Detected:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          ..._detectedCriticalDiseases.map((disease) => Text(
                                '${disease['disease'].toString()} - Probability: ${disease['probability'].toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                          const SizedBox(height: 20),
                          const Text(
                            'You should call emergency services immediately.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _callEmergencyServices,
                            child: Text('Call Emergency Services'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSearchBar() {
    return TypeAheadField<String>(
      textFieldConfiguration: const TextFieldConfiguration(
        decoration: InputDecoration(
          labelText: 'Enter symptom',
          labelStyle: TextStyle(
            fontFamily: 'PlayfairDisplay',
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
          hintText: 'Type here...',
          hintStyle: TextStyle(
            fontFamily: 'PlayfairDisplay',
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          suffixIcon: Icon(Icons.search, color: Colors.blueAccent),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
      ),
      suggestionsCallback: (pattern) async {
        // Filter symptoms based on input pattern
        return _symptoms
            .where((symptom) =>
                symptom.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        setState(() {
          if (!_selectedSymptoms.contains(suggestion)) {
            _selectedSymptoms.add(suggestion);
          }
        });
      },
    );
  }

  Widget _buildSelectedSymptomsCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Symptoms',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedSymptoms.map((symptom) {
                return Chip(
                  label: Text(symptom),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedSymptoms.remove(symptom);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictedDiseasesCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predicted Diseases',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _predictedDiseases.map((disease) {
                return Chip(
                  label: Text(
                    '${disease['disease']} (${disease['probability'].toStringAsFixed(2)}%)',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _callEmergencyServices() async {
    const emergencyNumber =
        'tel:911'; // Example emergency number, replace with local
    if (await canLaunch(emergencyNumber)) {
      await launch(emergencyNumber);
    } else {
      throw 'Could not launch $emergencyNumber';
    }
  }
}
