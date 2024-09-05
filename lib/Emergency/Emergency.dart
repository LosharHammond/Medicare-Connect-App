// ignore: file_names
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: use_key_in_widget_constructors
class EmergencyScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Services',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://example.com/background.jpg'), // Replace with your image URL or asset path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
      const SingleChildScrollView(
        
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Emergency Services Card

            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Emergency services are the heartbeat of a societys resilience, tirelessly responding to crises with skill, compassion, and unwavering dedication, ensuring that help is always within reach when moments of chaos strike."',
                      style: TextStyle(
                        fontFamily: 'Wittgenstein',
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Add more emergency service info if needed
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),


            Text(
                  'Emergency Contacts:',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),

            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    SizedBox(height: 10),
                    EmergencyContactCard(
                      contactName: 'Ghana Ambulance Services',
                      contactNumber: '193',
                    ),
                    SizedBox(height: 10),
                    EmergencyContactCard(
                      contactName: 'Ghana Emergency Hotline',
                      contactNumber: '112',
                    ),
                    SizedBox(height: 20),

                    // Add more emergency service info if needed
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
                  'Emergency Hospitals:',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
            // Contacts and Locations Card
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    SizedBox(height: 10),
                    // Add contact information here
                    RegionTile(
                      regionName: 'Ashanti Region',
                      locations: [
                        EmergencyLocation(
                          locationName: 'SDA Hosepital-Wiamoase',
                          locationAddress:
                              'SDA Hospital, Wiamoase Ashanti, Ghana',
                          contactNumber: '332490851',
                        ),
                        EmergencyLocation(
                          locationName: 'KNUST Hospital',
                          locationAddress: 'KNUST Hospital',
                          contactNumber: '+233201111055',
                        ),
                        EmergencyLocation(
                          locationName: 'Komfo Anokye Teaching Hospital',
                          locationAddress:
                              'Komfo Anokye Teaching Hospital Bantama, Kumasi, Ashanti Region, Ghana',
                          contactNumber: '+233322083000',
                        ),
                        EmergencyLocation(
                          locationName: 'Agogo Presbyterian Hospital',
                          locationAddress: 'Agogo Presbyterian Hospital, Ashanti Region, Ghana',
                          contactNumber: '+233322192387',
                        ),
                        EmergencyLocation(
                          locationName: 'Manhyia District Hospital',
                          locationAddress:
                              'Manhyia District Hospital, Kumasi, Ashanti Region, Ghana',
                          contactNumber: '+233322022408',
                        ),
                        EmergencyLocation(
                          locationName: 'St. Michael’s Hospital',
                          locationAddress: 'St. Michael’s Hospital Pramso, Ashanti Region, Ghana',
                          contactNumber: '+233322196306',
                        ),
                        EmergencyLocation(
                          locationName: 'Mampong Government Hospital',
                          locationAddress: 'Mampong Government Hospital, Ashanti Region, Ghana',
                          contactNumber: '+233322090020',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Brong-Ahafo Region',
                      locations: [
                        EmergencyLocation(
                          locationName: 'Bechem Government Hospital',
                          locationAddress: 'Bechem Government Hospital Goaso, Brong Ahafo, Ghana',
                          contactNumber: '+233352102386',
                        ),
                        
                        EmergencyLocation(
                          locationName: 'Holy Family Hospital - Techiman',
                          locationAddress:
                              'Holy Family Hospital Techiman, Brong-Ahafo Region, Ghana',
                          contactNumber: '+233352522249',
                        ),
                        EmergencyLocation(
                          locationName: 'Berekum Holy Family Hospital',
                          locationAddress: 'Berekum Holy Family Hospital, Brong-Ahafo Region, Ghana',
                          contactNumber: '+23335222045',
                        ),
                        EmergencyLocation(
                          locationName: 'Sunyani Regional Hospital',
                          locationAddress: 'Regional Hospital Sunyani, Brong-Ahafo Region, Ghana',
                          contactNumber: '+233352027215',
                        ),
                        EmergencyLocation(
                          locationName: 'Sampa Government Hospital',
                          locationAddress: 'Sampa Government Hospital, Brong-Ahafo Region, Ghana',
                          contactNumber: '+233207140374',
                        ),
                        EmergencyLocation(
                          locationName: 'Kintampo Municipal Hospital',
                          locationAddress:
                              'Kintampo Municipal Hospital, Brong-Ahafo Region, Ghana',
                          contactNumber: '+233208155896',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Central Region',
                      locations: [
                        EmergencyLocation(
                          locationName: 'Abura Dunkwa Hospital',
                          locationAddress: 'Abura Dunkwa Hospital Cape Coast, Central, Ghana',
                          contactNumber: '+233332191427',
                        ),
                        EmergencyLocation(
                          locationName: 'Apam Catholic Hospital (St Lukes Catholic Hospital)',
                          locationAddress: 'Apam Catholic Hospital (St Lukes Catholic Hospital) Cape Coast, Central, Ghana',
                          contactNumber: '+233334121549',
                        ),
                        EmergencyLocation(
                          locationName: 'Cape Coast Teaching Hospital',
                          locationAddress: 'Teaching Hospital Cape Coast, Central Region, Ghana',
                          contactNumber: '0332132440',
                        ),
                        EmergencyLocation(
                          locationName: 'Twifo Praso Government Hospital',
                          locationAddress: 'Twifo Praso Government Hospital, Central Region, Ghana',
                          contactNumber: '0244640763',
                        ),
                        EmergencyLocation(
                          locationName: 'Winneba Municipal Hospital',
                          locationAddress: 'Winneba Municipal Hospital, Central Region, Ghana',
                          contactNumber: '0244270439',
                        ),
                        EmergencyLocation(
                          locationName: 'Saltpond Municipal Hospital',
                          locationAddress: 'Saltpond Municipal Hospital, Central Region, Ghana',
                          contactNumber: '0332192336',
                        ),
                        EmergencyLocation(
                          locationName: 'Ankaful Psychiatric Hospital',
                          locationAddress: 'Ankaful Psychiatric Hospital, Central Region, Ghana',
                          contactNumber: '0332192316',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Eastern Region',
                      locations: [
                        EmergencyLocation(
                          locationName: 'Akuse Government Hospital',
                          locationAddress: 'Government Hospital Akuse Road,Buokrom-Ghana',
                          contactNumber: '+233244730829',
                        ),
                        EmergencyLocation(
                          locationName: 'Kade Government Hospital',
                          locationAddress: 'Kade Government Hospital Juaso-Nsawam Roag,Koforidua',
                          contactNumber: '0208445322',
                        ),
                        EmergencyLocation(
                          locationName: 'Government Hospital - Asamankese',
                          locationAddress:
                              'Asamankese Government Hospital, West Akim Municipal, Eastern Region, Ghana',
                          contactNumber: '+233342091049',
                          
                        ),
                        EmergencyLocation(
                          locationName: 'Government Hospital - Akim Oda',
                          locationAddress:
                              'Akim Oda Government Hospital, Birim Central Municipal, Eastern Region, Ghana',
                          contactNumber: '0332096198',
                        ),
                        EmergencyLocation(
                          locationName: 'Holy Family Hospital - Nkawkaw',
                          locationAddress:
                              'Holy Family Hospital Nkawkaw, Kwahu West Municipal, Eastern Region, Ghana',
                          contactNumber: '+233342290301',
                        ),
                        EmergencyLocation(
                          locationName: 'Regional Hospital - Koforidua',
                          locationAddress:
                              'Regional Hospital Koforidua, New Juaben Municipal, Eastern Region, Ghana',
                          contactNumber: ' 0342023011',
                        ),
                        EmergencyLocation(
                          locationName: 'Saint Joseph’s Hospital - Effiduase',
                          locationAddress:
                              'Saint Joseph’s Hospital Effiduase-Koforidua, New Juaben Municipal, Eastern Region, Ghana',
                          contactNumber: '0322292058',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Greater Accra Region',
                      locations: [
                        EmergencyLocation(
                          locationName: 'Pentecost Hospital - Madina',
                          locationAddress: 'Pentecost Hospital Halogen Street,Madina, 00000',
                          contactNumber: '+233302508396',
                        ),
                        EmergencyLocation(
                          locationName: 'Ga North Municipal Hospital',
                          locationAddress: 'Ga North Municipal Hospital Amamorley Community Town,Ofankor, 00000',
                          contactNumber: '0244668548',
                        ),
                        EmergencyLocation(
                          locationName: 'Greater Accra Regional Hospital',
                          locationAddress: 'Greater Accra Regional Hospital Ridge, Accra, Ghana',
                          contactNumber: '0302665511',
                        ),
                        EmergencyLocation(
                          locationName: 'Tema General Hospital',
                          locationAddress: 'Tema General Hospital, Greater Accra Region, Ghana',
                          contactNumber: '0303202775',
                        ),
                        EmergencyLocation(
                          locationName: 'Police Hospital',
                          locationAddress:
                              'Police Hospital Cantonments Road, Accra, Greater Accra Region, Ghana',
                          contactNumber: '0302773650',
                        ),
                        EmergencyLocation(
                          locationName: 'La General Hospital',
                          locationAddress:
                              'La Road General Hospital, Accra, Greater Accra Region, Ghana',
                          contactNumber: '0302772690',
                        ),
                        EmergencyLocation(
                          locationName: 'LEKMA Hospital',
                          locationAddress:
                              'LEKMA Hospital Teshie, Accra, Greater Accra Region, Ghana',
                          contactNumber: '0302712091',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Northern Region',
                      locations: [
            
                        EmergencyLocation(
                          locationName: 'Tamale Teaching Hospital',
                          locationAddress: 'Tamale Teaching Hospital, Northern Region, Ghana',
                          contactNumber: '+233372022152',
                        ),
                        EmergencyLocation(
                          locationName: 'Walewale Government Hospital',
                          locationAddress:
                              'Walewale Government Hospital, West Mamprusi District, Northern Region, Ghana',
                          contactNumber: ' 071522022',
                        ),
                        EmergencyLocation(
                          locationName: 'Bimbilla District Hospital',
                          locationAddress:
                              'Bimbilla District Hospital, Nanumba North District, Northern Region, Ghana',
                          contactNumber: '+233244236655',
                        ),
                        EmergencyLocation(
                          locationName: 'Savelugu Hospital',
                          locationAddress: 'Savelugu Hospital, Northern Region, Ghana',
                          contactNumber: '0244154776',
                        ),
                        EmergencyLocation(
                          locationName: 'Yendi Government Hospital',
                          locationAddress: 'Yendi Government Hospital, Northern Region, Ghana',
                          contactNumber: '+233243388856',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Upper East Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Bawku Presbyterian Hospital',
                          locationAddress:
                              'Bawku Presbyterian Hospital, Upper East Region, Ghana',
                          contactNumber: '0382222700',
                        ),
                        EmergencyLocation(
                          locationName: 'Bolgatanga Regional Hospital',
                          locationAddress:
                              'Zaare, Bolgatanga Regional Hospital, Upper East Region, Ghana',
                          contactNumber: '+233302665651',
                        ),
                        EmergencyLocation(
                          locationName: 'Sandema District Hospital',
                          locationAddress: 'Sandema District Hospital, Upper East Region, Ghana',
                          contactNumber: '0382091721',
                        ),
                        EmergencyLocation(
                          locationName: 'Afri Kids Medical Centre',
                          locationAddress:
                              'Afri Kids Medical Centre Bolgatanga, Upper East Region, Ghana',
                          contactNumber: ' 0382023829',
                        ),
                        EmergencyLocation(
                          locationName: 'Zebilla District Hospital',
                          locationAddress:
                              'Natinga, Zebilla District Hospital, Upper East Region, Ghana',
                          contactNumber: '0206408382',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Upper West Region',
                      locations: [
                       
                        EmergencyLocation(
                          locationName: 'St. Josephs Hospital - Jirapa',
                          locationAddress: 'St. Josephs Hospital - Jirapa, Upper West Region, Ghana',
                          contactNumber: '+233596587333',
                        ),
                        EmergencyLocation(
                          locationName: 'Regional Hospital - Wa',
                          locationAddress: 'Regional Hospital - Wa, Upper West Region, Ghana',
                          contactNumber: '+233243586733',
                        ),
                        EmergencyLocation(
                          locationName: 'Nadowli District Hospital',
                          locationAddress: 'Nadowli District Hospital, Upper West Region, Ghana',
                          contactNumber: '0506134505',
                        ),
                        EmergencyLocation(
                          locationName: 'Lawra Hospital',
                          locationAddress: 'Lawra Hospital, Upper West Region, Ghana',
                          contactNumber: '+233392022809',
                        ),
                        EmergencyLocation(
                          locationName: 'Tumu District Hospital',
                          locationAddress: 'Tumu District Hospital, Upper West Region, Ghana',
                          contactNumber: '+233302506156',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Volta Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Ho Teaching Hospital',
                          locationAddress: 'Ho Teaching Hospital, Volta Region, Ghana',
                          contactNumber: '+233362027319',
                        ),
                        EmergencyLocation(
                          locationName: 'Margaret Marquart Catholic Hospital',
                          locationAddress: 'Margaret Marquart Catholic Hospital Kpando, Volta Region, Ghana',
                          contactNumber: '0274525440',
                        ),
                        EmergencyLocation(
                          locationName: 'St. Anthonys Hospital-Dzodze',
                          locationAddress:
                              'St. Anthonys Hospital-Dzodze, Ketu North, Volta Region, Ghana',
                          contactNumber: '322122225',
                        ),
                        EmergencyLocation(
                          locationName: 'Hohoe Municipal Hospital',
                          locationAddress: 'Hohoe Municipal Hospital, Volta Region, Ghana',
                          contactNumber: '0208160465',
                        ),
                        EmergencyLocation(
                          locationName: 'Keta District Hospital',
                          locationAddress: 'Keta District Hospital, Volta Region, Ghana',
                          contactNumber: '+233096622309',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Western Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Effia Nkwanta Regional Hospital',
                          locationAddress: 'Takoradi Regional Hospital, Western Region, Ghana',
                          contactNumber: '+233559810925',
                        ),
                        EmergencyLocation(
                          locationName: 'Axim Government Hospital',
                          locationAddress: 'Axim Government Hospital, Western Region, Ghana',
                          contactNumber: ' +233312122304',
                        ),
                        EmergencyLocation(
                          locationName: 'Essikadu Hospital',
                          locationAddress: 'Essikadu Hospital, Western Region, Ghana',
                          contactNumber: '0312046361',
                        ),
                        EmergencyLocation(
                          locationName: 'Half Assini Government Hospital',
                          locationAddress: 'Half Assini Government Hospital, Western Region, Ghana',
                          contactNumber: '0244053622',
                        ),
                        EmergencyLocation(
                          locationName: 'Bibiani District Hospital',
                          locationAddress: 'Bibiani District Hospital, Western Region, Ghana',
                          contactNumber: '0543214619',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Savannah Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Bole District Hospital',
                          locationAddress: 'Bole District Hospital, Savannah Region, Ghana',
                          contactNumber: '037 252 2016',
                        ),
                        EmergencyLocation(
                          locationName: 'Sawla-Tuna-Kalba District Hospital',
                          locationAddress: 'Sawla-Tuna-Kalba District Hospital Sawla, Savannah Region, Ghana',
                          contactNumber: '0372522016',
                        ),
                        EmergencyLocation(
                          locationName: 'West Gonja Hospital',
                          locationAddress: 'West Gonja Hospital Damongo, Savannah Region, Ghana',
                          contactNumber: '071722091',
                        ),
                        EmergencyLocation(
                          locationName: 'Buipe Health Center',
                          locationAddress: 'Buipe West Gonja Hospital, Savannah Region, Ghana',
                          contactNumber: '0243220165',
                        ),
                        EmergencyLocation(
                          locationName: 'Sankpala Health Center',
                          locationAddress: 'Sankpala West Gonja Hospital, Savannah Region, Ghana',
                          contactNumber: '0203937359',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Bono East Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Sunyani Municipal Hospital',
                          locationAddress: 'Sunyani Municipal Hospital, Bono East Region, Ghana',
                          contactNumber: '0242041338',
                        ),
                        EmergencyLocation(
                          locationName: 'Berekum Municipal Hospital',
                          locationAddress: 'Berekum Municipal Hospital, Bono East Region, Ghana',
                          contactNumber: '+233208725806',
                        ),
                        EmergencyLocation(
                          locationName: 'Wenchi Methodist Hospital',
                          locationAddress: 'Wenchi Methodist Hospital, Bono East Region, Ghana',
                          contactNumber: ' +233501333751',
                        ),
                        EmergencyLocation(
                          locationName: 'Dormaa Presbyterian Hospital',
                          locationAddress:
                              'Dormaa Ahenkro Presbyterian Hospital, Bono East Region, Ghana',
                          contactNumber: '+23364822081',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Ahafo Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Goaso Government Hospital',
                          locationAddress: 'Goaso Government Hospital, Ahafo Region, Ghana',
                          contactNumber: '0550729174',
                        ),
                        EmergencyLocation(
                          locationName: 'Asunafo South District Hospital',
                          locationAddress: 'Asunafo South District Hospital Kukuom, Ahafo Region, Ghana',
                          contactNumber: '0322493743',
                        ),
                        EmergencyLocation(
                          locationName: 'Asutifi North District Hospital',
                          locationAddress: 'Asutifi North District Hospital Kenyan, Ahafo Region, Ghana',
                          contactNumber: ' 0599917522',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'North East Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Walewale Municipal Hospital',
                          locationAddress: 'Walewale Municipal Hospital, North East Region, Ghana',
                          contactNumber: '071522022',
                        ),
                        EmergencyLocation(
                          locationName: 'Nalerigu Hospital',
                          locationAddress: 'Nalerigu Hospital, North East Region, Ghana',
                          contactNumber: '+233504994980',
                        ),
                        EmergencyLocation(
                          locationName: 'Bunkpurugu District Hospital',
                          locationAddress:
                              'Bunkpurugu District Hospital, North East Region, Ghana',
                          contactNumber: ' 0240100609',
                        ),
                        EmergencyLocation(
                          locationName: 'Yunyoo/Nasuan District Hospital',
                          locationAddress: 'Yunyoo District Hospital, North East Region, Ghana',
                          contactNumber: '0244817034',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Western North Region',
                      locations: [
                        
                        EmergencyLocation(
                          locationName: 'Sefwi Wiawso Government Hospital',
                          locationAddress:
                              'Sefwi Wiawso Government Hospital, Western North Region, Ghana',
                          contactNumber: ' 0277405571',
                        ),
                        EmergencyLocation(
                          locationName: 'Sefwi Bekwai Government Hospital',
                          locationAddress:
                              'Sefwi Bekwai Government Hospital, Western North Region, Ghana',
                          contactNumber: '03193139',
                        ),
                        EmergencyLocation(
                          locationName: 'Bibiani Government Hospital',
                          locationAddress:
                              'Bibiani Government Hospital, Western North Region, Ghana',
                          contactNumber: '0543214619',
                        ),
                        EmergencyLocation(
                          locationName: 'Bodi District Hospital',
                          locationAddress: 'Bodi District Hospital, Western North Region, Ghana',
                          contactNumber: '0302999306',
                        ),
                      ],
                    ),

                    RegionTile(
                      regionName: 'Oti Region',
                      locations: [
                        EmergencyLocation(
                          locationName: 'Worawora Government Hospital',
                          locationAddress:
                              'Worawora Government Hospital, Biakoye District, Oti Region, Ghana',
                          contactNumber: '0244174172',
                        ),
                        EmergencyLocation(
                          locationName: 'Dambai District Hospital',
                          locationAddress: 'Dambai District Hospital, Oti Region, Ghana',
                          contactNumber: '0244884356',
                        ),
                        EmergencyLocation(
                          locationName: 'Nkwanta Municipal Hospital',
                          locationAddress:
                              'Nkwanta South District Municipal Hospital, Oti Region, Ghana',
                          contactNumber: '0244087676',
                        ),
                        EmergencyLocation(
                          locationName: 'Kadjebi District Hospital',
                          locationAddress: 'Kadjebi District Hospital, Oti Region, Ghana',
                          contactNumber: ' +23393222919',
                        ),
                        EmergencyLocation(
                          locationName: 'Jasikan District Hospital',
                          locationAddress: 'Jasikan District Hospital, Oti Region, Ghana',
                          contactNumber: '0249789052',
                        ),
                        EmergencyLocation(
                          locationName: 'Krachi West District Hospital',
                          locationAddress: 'Krachi West District Hospital, Oti Region, Ghana',
                          contactNumber: '0249789052',
                        ),
                        EmergencyLocation(
                          locationName: 'Kete-Krachi Government Hospital',
                          locationAddress:
                              'Krachi Nchumuru District Government Hospital, Oti Region, Ghana',
                          contactNumber: '0242934269',
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    // Add location information here

                ],
                ),
              ),
            ),
          ],
        ),
      )
     ]
    )
    );
  }
}







class RegionTile extends StatefulWidget {
  final String regionName;
  final List<EmergencyLocation> locations;

  const RegionTile({
    required this.regionName,
    required this.locations,
  });

  @override
  _RegionTileState createState() => _RegionTileState();
}

class _RegionTileState extends State<RegionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            widget.regionName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
        ),
        if (isExpanded)
          Column(
            children: widget.locations
                .map(
                  (location) => EmergencyLocationCard(
                    locationName: location.locationName,
                    locationAddress: location.locationAddress,
                    contactNumber: location.contactNumber,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  final String contactName;
  final String contactNumber;

  const EmergencyContactCard({
    required this.contactName,
    required this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.red, // Set card color to blue
      child: ListTile(
        title: Text(
          contactName,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlayfairDisplay',
          ), // Set text color to white
        ),
        subtitle: Text(
          contactNumber,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlayfairDisplay',
          ), // Set text color to white
        ),
        leading:
            Icon(Icons.phone, color: Colors.white), // Set icon color to white
        onTap: () {
          _makePhoneCall(contactNumber);
        },
      ),
    );
  }

  _makePhoneCall(String contactNumber) async {
    String url = 'tel:$contactNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class EmergencyLocationCard extends StatelessWidget {
  final String locationName;
  final String locationAddress;
  final String contactNumber;

  const EmergencyLocationCard({
    required this.locationName,
    required this.locationAddress,
    required this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.blue, // Set card color to blue
      child: ListTile(
        title: Text(
          locationName,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlayfairDisplay',
          ), // Set text color to white
        ),
        subtitle: Row(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Location'),
              onPressed: () {
                _navigateToLocation(locationAddress);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.red,
              ),
            ),
            SizedBox(width: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.phone),
              label: Text('Call'),
              onPressed: () {
                _makePhoneCall(contactNumber);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLocation(String address) {
    // Launch Google Maps with the location coordinates
    launch('https://www.google.com/maps/search/?api=1&query=$address');
  }

  _makePhoneCall(String contactNumber) async {
    String url = 'tel:$contactNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class EmergencyLocation {
  final String locationName;
  final String locationAddress;
  final String contactNumber;

  const EmergencyLocation({
    required this.locationName,
    required this.locationAddress,
    required this.contactNumber,
  });
}
