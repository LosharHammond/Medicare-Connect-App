import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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
  _DiseasePredictionScreenState createState() => _DiseasePredictionScreenState();
}

class _DiseasePredictionScreenState extends State<DiseasePredictionScreen> {
  final List<String> _selectedSymptoms = [];
  List<Map<String, dynamic>> _predictedDiseases = [];
  List<Map<String, dynamic>> _detectedCriticalDiseases = [];
  List<String> _criticalDiseases = [];
  List<String> _symptoms = [];
  final Map<String, List<String>> _symptomDiseaseMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Load critical diseases
      final criticalDiseasesSnapshot = await firestore.collection('critical_diseases').get();
      setState(() {
        _criticalDiseases = criticalDiseasesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      });

      // Load symptoms
      final symptomsSnapshot = await firestore.collection('symptoms').get();
      setState(() {
        _symptoms = symptomsSnapshot.docs.map((doc) => doc['name'] as String).toList();
      });

      // Load disease-symptom mappings
      final diseaseSymptomMappingsSnapshot = await firestore.collection('disease_symptom_map').get();
      final map = <String, List<String>>{};
      diseaseSymptomMappingsSnapshot.docs.forEach((doc) {
        final data = doc.data();
        final disease = data['disease'] as String;
        final symptoms = List<String>.from(data['symptoms'] as List<dynamic>);
        map[disease] = symptoms;
      });
      setState(() {
        _symptomDiseaseMap.addAll(map);
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  List<Map<String, dynamic>> predictDisease(List<String> selectedSymptoms) {
    final selectedSet = Set<String>.from(selectedSymptoms);
    List<Map<String, dynamic>> predictions = [];

    _symptomDiseaseMap.forEach((disease, symptoms) {
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
        .where((disease) => _criticalDiseases.contains(disease['disease'].toString()))
        .toList();

    if (_detectedCriticalDiseases.isNotEmpty) {
      print('Critical diseases detected: $_detectedCriticalDiseases');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNewsItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('news_items').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _callEmergencyServices() async {
    const emergencyNumber = 'tel:911'; // Replace with appropriate number
    if (await canLaunch(emergencyNumber)) {
      await launch(emergencyNumber);
    } else {
      throw 'Could not launch $emergencyNumber';
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
        leading: null,
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
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
          suffixIcon: Icon(Icons.search, color: Colors.blueAccent),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
      ),
      suggestionsCallback: (pattern) async {
        return _symptoms
            .where((symptom) => symptom.toLowerCase().contains(pattern.toLowerCase()))
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
              runSpacing: 8.0,
              children: _selectedSymptoms.map((symptom) {
                return Chip(
                  label: Text(
                    symptom,
                    style: const TextStyle(color: Colors.white),
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

  Widget _buildPredictedDiseasesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchNewsItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No news items available.'));
        }

        final newsItems = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _predictedDiseases.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                final diseaseTitle = _predictedDiseases[index]['disease'];
                final newsItem = newsItems.firstWhere(
                  (item) => item['title'] == diseaseTitle,
                  orElse: () => {'title': 'No news', 'content': ''},
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(newsItem: newsItem),
                  ),
                );
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
      },
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailScreen({Key? key, required this.newsItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newsItem['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(newsItem['content']),
      ),
    );
  }
}
