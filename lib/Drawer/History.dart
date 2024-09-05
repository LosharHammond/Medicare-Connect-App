import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PredictionHistoryScreen extends StatefulWidget {
  const PredictionHistoryScreen({Key? key}) : super(key: key);

  @override
  _PredictionHistoryScreenState createState() =>
      _PredictionHistoryScreenState();
}

class _PredictionHistoryScreenState extends State<PredictionHistoryScreen> {
  late Stream<QuerySnapshot> _predictionsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _predictionsStream = FirebaseFirestore.instance
          .collection('predictionHistory')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prediction History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _predictionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No prediction history found.'));
          }

          final predictions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(
                8.0), // Add padding to ensure the list is not flush with edges
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction =
                  predictions[index].data() as Map<String, dynamic>;
              final timestamp = (prediction['timestamp'] as Timestamp).toDate();
              final formattedTime =
                  '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute}';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.teal.shade50,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: Icon(Icons.healing, color: Colors.indigo[700], size: 40),
                  title: Text(
                    prediction['disease'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Probability: ${prediction['probability'].toStringAsFixed(2)}%',
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Time: $formattedTime',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deletePrediction(predictions[index].id);
                    },
                  ),
                  onTap: () {
                    // Add your navigation logic here if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deletePrediction(String predictionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('predictionHistory')
            .doc(user.uid)
            .collection('history')
            .doc(predictionId)
            .delete();
      } catch (e) {
        print('Error deleting prediction: $e');
      }
    }
  }
}
