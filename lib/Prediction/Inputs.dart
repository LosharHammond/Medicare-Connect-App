import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medicare/Drawer/History.dart';
import 'package:medicare/Health_Newz/Health_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> _criticalDiseases = [
    'COVID-19 (Coronavirus Disease)',
    'Pneumonia',
    'Tuberculosis',
    'Heart Failure',
    'Diabetes Mellitus',
    'Hypertension (High Blood Pressure)',
    'Coronary Artery Disease',
    'Hepatitis B',
    'Cholera',
    'Dengue Fever',
    'Lassa Fever',
    'Leptospirosis',
    'Onchocerciasis (River Blindness)',
    'African Trypanosomiasis (Sleeping Sickness)'
    // Add your critical diseases here
  ];

  Map<String, List<String>> symptomDiseaseMap = {};

  @override
  void initState() {
    super.initState();
    _loadDiseaseSymptomData();
  }

  Future<void> _loadDiseaseSymptomData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/disease_symptom_mapping.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        symptomDiseaseMap = jsonData
            .map((key, value) => MapEntry(key, List<String>.from(value)));
      });
    } catch (e) {
      print('Error loading disease-symptom data: $e');
    }
  }

  final List<String> _symptoms = [
    'Abdominal Pain',
    'Bad Breath',
    'Blood in Urine',
    'Changes in Sleep Patterns'
    'Chest Pain',
    'Chills',
    'Chronic Cough',
    'Confusion (especially in older adults)',
    'Congestion or Runny Nose',
    'Cough',
    'Coughing Up Blood',
    'Dark Urine',
    'Diarrhea',
    'Diarrhea or Constipation',
    'Difficulty Breathing',
    'Difficulty Swallowing',
    'Eye Problems',
    'Facial Pain or Pressure',
    'Fatigue',
    'Fever',
    'Frequent Respiratory Infections',
    'Heartburn',
    'Headache',
    'Itchy or Watery Eyes',
    'Itchy Throat or Nose',
    'Jaundice (Yellowing of Skin and Eyes)',
    'Joint Pain',
    'Loss of Appetite',
    'Loss of Smell',
    'Mild Fatigue',
    'Mild Headache',
    'Muscle Aches',
    'Muscle Pain',
    'Nasal Congestion',
    'Nausea or Vomiting',
    'Night Sweats',
    'Postnasal Drip',
    'Rapid or Irregular Heartbeat',
    'Rash',
    'Red Eyes',
    'Regurgitation of Food or Sour Liquid',
    'Severe Itching',
    'Sneezing',
    'Sweating and Shaking Chills',
    'Sweats',
    'Swelling in the Legs, Ankles, or Feet',
    'Swollen Lymph Nodes',
    'Vision Loss',
    'Wheezing',
    'Weight Loss',
    // List of symptoms
  ];

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

    for (var prediction in _predictedDiseases) {
      _savePredictionToFirestore(
          prediction['disease'], prediction['probability']);
    }
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

  Future<void> _savePredictionToFirestore(
      String disease, double probability) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('predictionHistory')
            .doc(user.uid)
            .collection('history')
            .add({
          'disease': disease,
          'probability': probability,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error saving prediction: $e');
      }
    } else {
      print('No user is logged in');
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
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.history, color: Colors.blue),
            label: const Text(
              'History',
              style: TextStyle(color: Colors.blue),
            ),
          
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PredictionHistoryScreen(),
                ),
              );
            },
          ),
        ],
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
                const SizedBox(height: 40),
                _buildPredictedDiseasesCard(),
                if (_detectedCriticalDiseases.isNotEmpty) ...[
                  const SizedBox(height: 20),
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
                          const SizedBox(height: 10),
                          ..._detectedCriticalDiseases.map((disease) => Text(
                                '${disease['disease'].toString()} - Probability: ${disease['probability'].toStringAsFixed(2)}%',
                                style: const TextStyle(
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
                            child: const Text('Call Emergency Services'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
      ),
      suggestionsCallback: (pattern) {
        return _symptoms.where(
            (symptom) => symptom.toLowerCase().contains(pattern.toLowerCase()));
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
              runSpacing: 8.0,
              children: _selectedSymptoms.map((symptom) {
                return Chip(
                  label: Text(
                    symptom,
                    style: TextStyle(color: Colors.white),
                  ),
                  onDeleted: () {
                    setState(() {
                      _selectedSymptoms.remove(symptom);
                    });
                  },
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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
      elevation: 10.0,
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
            _buildPredictedDiseasesList(),
          ],
        ),
      ),
    );
  }

// Import your NewsItem class and any other necessary files

  Widget _buildPredictedDiseasesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _predictedDiseases.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(
                  newsItem: NewsFeedScreen().newsItems.firstWhere(
                        (item) =>
                            item.title == _predictedDiseases[index]['disease'],
                      ), disease: '',
                ),
              ),
            );
            // Handle tapping on predicted disease
          },
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _predictedDiseases[index]['disease'],
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_predictedDiseases[index]['probability'].toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _callEmergencyServices() async {
    const emergencyNumber = '911'; // Change this as needed
    final uri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      print('Could not launch $uri');
    }
  }
}
