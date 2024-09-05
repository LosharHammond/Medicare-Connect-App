import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
// ignore: unused_import
import 'package:firebase_database/firebase_database.dart';

// Define the NewsItem class with Firestore integration for likes
class NewsItem {
  final String id; // ID field
  final String title;
  final String subtitle;
  final List<StyledContent> content;
  final String imageUrl;

  int likes;
  int dislikes;
  Color likeColor;
  Color dislikeColor;

  NewsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    this.likes = 0,
    this.dislikes = 0,
    this.likeColor = Colors.black,
    this.dislikeColor = Colors.black,
  });

  Future<void> fetchLikes() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('news').doc(id).get();
      if (doc.exists) {
        likes = doc.data()?['likes'] ?? 0;
        print('Fetched likes: $likes');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching likes: $e');
      // Handle the error, e.g., show an error message to the user
    }
  }

  Future<void> updateLikes() async {
    await FirebaseFirestore.instance.collection('news').doc(id).update({
      'likes': likes,
    });
  }

  Future<void> updateDislikes() async {
    await FirebaseFirestore.instance.collection('news').doc(id).update({
      'dislikes': dislikes,
    });
  }
}

// Define the StyledContent class
class StyledContent {
  final String text;
  final TextStyle style;

  StyledContent(this.text, this.style);
}

// Define the VideoPlayerWidget class
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              SizedBox(height: 10),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.seekTo(Duration.zero);
                      });
                    },
                    icon: Icon(Icons.stop),
                  ),
                ],
              ),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Define the NewsDetailScreen class
class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem, required String disease});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await widget.newsItem.fetchLikes();
    setState(() {}); // Update the state after fetching likes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.newsItem.title,
          style: TextStyle(fontFamily: 'PlayfairDisplay'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.newsItem.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                fontFamily: 'Wittgenstein',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.newsItem.subtitle,
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Wittgenstein',
              ),
            ),
            SizedBox(height: 16.0),
            if (widget.newsItem.imageUrl.isNotEmpty)
              Image.network(
                widget.newsItem.imageUrl,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16.0),
            ...widget.newsItem.content.map((content) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  content.text,
                  style: content.style,
                ),
              );
            }).toList(),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) {
                  setState(() {
                    _hovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hovered = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    // Use the newsItem.title or subtitle to create the search query
                    final diseaseQuery = widget.newsItem.title;
                    _launchURL(diseaseQuery);
                  },
                  child: Text(
                    'Learn more about the disease......?',
                    style: TextStyle(
                      color: _hovered ? Colors.blueAccent : Colors.blue,
                      fontSize: 20,
                      fontFamily: 'Wittgenstein',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up,
                          color: widget.newsItem.likeColor),
                      onPressed: () {
                        setState(() {
                          widget.newsItem.likes++;
                          widget.newsItem.likeColor = Colors.green;
                          widget.newsItem.dislikeColor = Colors.black;
                          widget.newsItem.updateLikes();
                        });
                      },
                    ),
                    Text('${widget.newsItem.likes} Likes'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_down,
                          color: widget.newsItem.dislikeColor),
                      onPressed: () {
                        setState(() {
                          widget.newsItem.dislikes++;
                          widget.newsItem.dislikeColor = Colors.red;
                          widget.newsItem.likeColor = Colors.black;
                        });
                      },
                    ),
                    Text('${widget.newsItem.dislikes} Dislikes'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String query) async {
    final url = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// Define the NewsFeedScreen class
class NewsFeedScreen extends StatelessWidget {
  final List<NewsItem> newsItems = [
    NewsItem(
      id: 'mpox_id',
      title: 'Mpox',
      subtitle:
          'Mpox, formerly called monkeypox, is a rare disease similar to smallpox caused by a virus. It’s found mostly in areas of Africa, but has been seen in other regions of the world.',
      content: [
        StyledContent(
          'What is mpox?',
          TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Mpox (previously known as monkeypox) is a rare disease caused by a virus. It leads to rashes and flu-like symptoms. Like the better-known virus that causes smallpox, it’s a member of the genus Orthopoxvirus.Mpox spreads through close contact with someone who’s infected. You can also get it from an infected animal.There are two known types (clades) of mpox virus — one that originated in Central Africa (Clade I) and one that originated in West Africa (Clade II). The current world outbreak (2022 to 2023) is caused by Clade IIb, a subtype of the less severe West African clade. It’s rare, but mpox is sometimes fatal. Mpox can also lead to problems (complications) like pneumonia and infections in your brain (encephalitis) or eyes, which can be life-threatening.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'How do you catch mpox?',
          TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Mpox spreads when you come into contact with an animal or a person infected with the virus. Person-to-person spread (transmission) occurs when you come in contact with the sores, scabs, respiratory droplets or oral fluids of a person who’s infected, usually through close, intimate situations like cuddling, kissing or sex. Research is ongoing, but experts aren’t sure if the virus is transmitted through semen or vaginal fluids. Animal-to-person transmission occurs through broken skin, like from bites or scratches, or through direct contact with an infected animal’s blood, bodily fluids or pox lesions (sores). You can also get mpox by coming into contact with recently contaminated materials like clothing, bedding and other linens used by a person or animal who’s infected.',
          TextStyle(
            fontSize: 16.0,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Prevention, How do you prevent mpox?',
          TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'If you’re at risk for mpox, getting vaccinated helps stop the spread. Other forms of prevention include decreasing human contact with infected animals and limiting person-to-person spread. Vaccines developed for smallpox also provide protection against mpox. Mpox vaccines are currently only recommended for people who’ve been exposed to, or are likely to be exposed to, mpox. You might be at higher risk of exposure if:  You’ve been in close contact with someone with mpox. Someone you’ve had sex with in the past two weeks has been diagnosed with mpox. You’ve had sex at a sex club, bathhouse or other commercial sex venue in the past six months. You’ve had sex at an event or location where mpox was spreading. You have a sex partner who’s been in any of the above situations. You expect to be in one of the above situations. If you’re a man who has sex with men, a transgender person or a nonbinary person, you may also be at risk if you’ve: Been diagnosed with one or more sexually transmitted infections (STIs) in the past six months. This includes acute HIV, gonorrhea, syphilis, chancroid or chlamydia. Had sex with more than one person in the past six months. It’s important to get vaccinated before or as soon as possible after exposure. Talk to a healthcare provider if you’re unsure if you should get vaccinated. If you’d like to get your shot in a more concealed location on your body, your provider can give it to you in your shoulder blade instead of your forearm.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th?id=OIF.Z5hnn%2bApPmDuRDVT9Z3E4w&rs=1&pid=ImgDetMain',
    ),

    NewsItem(
      id: 'common_cold_id',
      title: 'Common Cold',
      subtitle:
          'The common cold is an acute, usually afebrile, self-limited viral infection that primarily affects the upper respiratory tract.',
      content: [
        StyledContent(
          'The common cold is an upper respiratory tract infection caused by many different viruses. The common cold is transmitted by virus-infected airborne droplets or by direct contact with infected secretions.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Typical common cold symptoms include cough, sore throat, coughing, sneezing, and a runny nose. Being in cold weather does not cause the common cold, but cold weather promotes close contact.',
          TextStyle(
            fontSize: 16.0,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'There are four stages of a common cold. Over-the-counter medications may be used for the treatment of the common cold. Antibiotics are not necessary for the common cold. The common cold is a self-limited disease that can generally be managed at home. Most people with a common cold recover in about 7 to 10 days. The common cold has no cure, and there is no available vaccine.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Watch this video to learn more about the common cold.',
          TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.fea71b45aa2114f220a73c45d41a5464?rik=DxtMA3yuITmekA&riu=http%3a%2f%2fpluspng.com%2fimg-png%2fpng-flu--461.png&ehk=5Lhin92cIkjVwQ6EDLGX7xDh73fmf7pL6VyI3Ao0BD8%3d&risl=&pid=ImgRaw&r=0',
    ),

    NewsItem(
      title: 'Bronchitis',
      subtitle:
          'Bronchitis is an inflammation of the bronchial tubes, which are the air passages that carry air to your lungs. It can be acute or chronic',
      content: [
        StyledContent(
          'Bronchitis can be caused by viruses, bacteria, or inhalation of irritants. Symptoms include cough, mucus production, chest discomfort, and sometimes fever.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.99f45f5c14c4b4ca9e19f80b8afd912b?rik=BKgLxkkR3aN5lQ&pid=ImgRaw&r=0',
      id: 'Bronchitis_id',
    ),
    NewsItem(
      title: 'Food Poisoning',
      subtitle:
          'occurs when you consume contaminated, spoiled, or toxic food. It can be caused by various factors, including bacteria, parasites, or viruses.',
      content: [
        StyledContent(
          'Symptoms of food poisoning can include nausea, vomiting, diarrhea, and abdominal cramps.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.1aa950c03319407398ad8591d58ed5bc?rik=5jl6oVk4o36pUg&riu=http%3a%2f%2fwww.healthygutbugs.com%2fwp-content%2fuploads%2f2014%2f09%2ffood_poisoning_probiotics.jpg&ehk=eJlM38IVzRv81uS%2bCqzEys8cscH4xtIw4URtA8sVzpY%3d&risl=&pid=ImgRaw&r=0',
      id: 'Food_Poisoning_id',
    ),
    NewsItem(
      title: 'Influenza (Flu)',
      subtitle:
          'The flu is an infection of the nose, throat, and lungs caused by influenza viruses. It’s different from the stomach “flu” viruses that cause diarrhea and vomiting. Influenza spreads easily between people when they cough or sneeze',
      content: [
        StyledContent(
          'Flu symptoms can include fever, cough, sore throat, runny or stuffy nose, muscle or body aches, headaches, and fatigue.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.QVCAmrZN5ZMhxP1AYZkgTQHaHa?w=692&h=692&rs=1&pid=ImgDetMain',
      id: 'Influenza_(Flu)_id',
    ),
    NewsItem(
      title: 'COVID-19 (Coronavirus Disease)',
      subtitle:
          'COVID-19 is the disease caused by the SARS-CoV-2 coronavirus. It usually spreads between people in close contact.',
      content: [
        StyledContent(
          'COVID-19 symptoms can include fever, cough, and shortness of breath. In severe cases, it can cause pneumonia and breathing difficulties.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQe63Ba16izo7vjApWCkRnXJ03M9nQUwy6K9Q&s',
      id: 'COVID-19_(Coronavirus Disease)_id',
    ),
    NewsItem(
      title: 'Pneumonia',
      subtitle:
          'Pneumonia is an inflammatory condition of the lung primarily affecting the small air sacs known as alveoli. It can be caused by various microorganisms, including bacteria, viruses, and less commonly, other pathogens',
      content: [
        StyledContent(
          'Pneumonia symptoms can include chest pain, cough, fatigue, fever, sweating and shaking chills, nausea, vomiting, and diarrhea.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.Ywd5WcrM3Dv13aKTrqsd8AHaHa?rs=1&pid=ImgDetMain',
      id: 'Pneumonia_id',
    ),
    NewsItem(
      title: 'Asthma',
      subtitle:
          'Asthma is a chronic lung disease that affects people of all ages. It is characterized by inflammation and muscle tightening around the airways, making it harder to breathe.',
      content: [
        StyledContent(
          'Asthma symptoms can include shortness of breath, chest tightness, wheezing, and coughing, particularly at night or early in the morning.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.87b6d923fcd742a2e30662b718351da0?rik=EuMBgI9HS3Avhg&pid=ImgRaw&r=0',
      id: 'Asthma_id',
    ),
    NewsItem(
      title: 'Diabetes Mellitus',
      subtitle:
          'Diabetes mellitus refers to a group of diseases that affect how the body uses blood sugar (glucose). Glucose is an important source of energy for the cells that make up the muscles and tissues',
      content: [
        StyledContent(
          'Diabetes symptoms can include increased thirst, frequent urination, extreme hunger, unexplained weight loss, presence of ketones in the urine, fatigue, irritability, blurred vision, slow-healing sores, and frequent infections.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.ed420dd48476c5fa44b29aff5cc400e1?rik=r%2fZ9KKe0t9G3bg&pid=ImgRaw&r=0',
      id: 'Diabetes_Mellitus_id',
    ),
    NewsItem(
      title: 'Hypertension (High Blood Pressure)',
      subtitle:
          'Hypertension, commonly known as high blood pressure, is a chronic medical condition where the force of blood against the walls of arteries remains persistently elevated.',
      content: [
        StyledContent(
          'High blood pressure often has no symptoms, but it can lead to serious health problems such as heart disease and stroke if left untreated.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.36b90fadd0b3e4e2e0a13e919a2870bc?rik=P82Ox3dXWYbLDw&pid=ImgRaw&r=0',
      id: 'Hypertension_(High Blood Pressure)_id',
    ),
    NewsItem(
      title: 'Coronary Artery Disease',
      subtitle:
          'Coronary artery disease is a common heart condition. The major blood vessels that supply the heart (coronary arteries) struggle to send enough blood, oxygen and nutrients to the heart muscle.',
      content: [
        StyledContent(
          'Symptoms of coronary artery disease can include chest pain (angina), shortness of breath, and heart attack.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        )
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.9dxX-bX5Lg0jwYTLxwTulwHaE2?rs=1&pid=ImgDetMain',
      id: 'Coronary_Artery_Disease_id',
    ),
    NewsItem(
        title: 'Gastroesophageal Reflux Disease (GERD)',
        subtitle:
            '(GERD) is a chronic digestive condition where stomach acid repeatedly flows back into the esophagus, causing irritation and discomfort.',
        content: [
          StyledContent(
            'Symptoms of GERD can include heartburn, regurgitation of food or sour liquid, and difficulty swallowing.',
            TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontFamily: 'Wittgenstein',
            ),
          )
        ],
        imageUrl:
            'https://th.bing.com/th/id/R.85201a5faf2f8d4839e0f9dcb85afc1c?rik=KFwwTzrRaZNEdg&pid=ImgRaw&r=0',
        id: 'Gastroesophageal_Reflux_Disease_(GERD)_id'),

    NewsItem(
      title: 'Malaria',
      subtitle:
          'Malaria is a life-threatening disease caused by parasites that are transmitted to people through the bites of infected female Anopheles mosquitoes.',
      content: [
        StyledContent(
          'Malaria is prevalent in tropical and subtropical regions. It is caused by Plasmodium parasites, which are spread to humans by the bite of infected mosquitoes.',
          const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms usually appear 10–15 days after the infective mosquito bite. If not treated within 24 hours, malaria can progress to severe illness and often death. Prompt treatment is crucial.',
          const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Malaria prevention includes the use of insecticide-treated mosquito nets, indoor spraying with insecticides, and antimalarial medications. There is currently no widely available vaccine for malaria.',
          const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'How is Malaria Diagnosed?',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Malaria is diagnosed through blood tests that detect the presence of the parasite. Rapid diagnostic tests (RDTs) can provide results in a few minutes, while microscopic examination of blood smears is more accurate but takes longer.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://static.horiba.com/fileadmin/Horiba/_processed_/f/7/csm_The_life_cycle_of_malaria_parasite_52b81b9640.jpg',
      id: 'malaria',
    ),

    NewsItem(
      title: 'Typhoid Fever',
      subtitle:
          'Typhoid fever is a bacterial infection caused by Salmonella typhi. It spreads through contaminated food and water.',
      content: [
        StyledContent(
          'Typhoid fever is common in areas with poor sanitation and limited access to clean drinking water. It is contracted through the ingestion of food or water contaminated with the feces of an infected person.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms typically include high fever, weakness, stomach pain, headache, and sometimes a rash. If not treated, typhoid can lead to serious complications such as intestinal bleeding or perforation.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Vaccines are available for typhoid, and maintaining good hygiene practices, such as drinking safe water and eating well-cooked food, can help prevent the disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment and Prevention',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Typhoid fever is treated with antibiotics, but resistance to common antibiotics is increasing. It’s essential to complete the full course of antibiotics even if you feel better. To prevent typhoid fever, consider getting vaccinated, especially if you are traveling to areas where typhoid is common.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://www.metropolisindia.com/upgrade/blog/upload/2023/06/Bright-Creative-Illustrative-Chart-Mind-Map-Mental-Health-Graph-1.png',
      id: 'typhoid',
    ),

    NewsItem(
      title: 'Hepatitis B',
      subtitle:
          'Hepatitis B is a viral infection that attacks the liver and can cause both acute and chronic disease.',
      content: [
        StyledContent(
          'Hepatitis B is transmitted through contact with infectious body fluids, such as blood, semen, and vaginal fluids. It can be spread through sexual contact, sharing needles, or from mother to child during childbirth.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms include jaundice (yellowing of the skin and eyes), dark urine, extreme fatigue, nausea, vomiting, and abdominal pain. Chronic hepatitis B can lead to liver cirrhosis, liver failure, or liver cancer.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Vaccination is the most effective way to prevent hepatitis B. Safe practices, such as using condoms and avoiding sharing needles, can also reduce the risk of infection.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Importance of Screening',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'It is crucial to screen for hepatitis B, especially in pregnant women and individuals at high risk. Early diagnosis and treatment can prevent liver damage and reduce the spread of the virus.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.7771098d8530efe6768a39e3eb4f9bf2?rik=w%2bu%2fcwtzUPGK8w&pid=ImgRaw&r=0',
      id: 'hepatitisb',
    ),

    NewsItem(
      title: 'Yellow Fever',
      subtitle:
          'Yellow fever is a viral disease transmitted by mosquitoes. It is common in tropical and subtropical areas of Africa and South America.',
      content: [
        StyledContent(
          'Yellow fever is caused by the yellow fever virus, which is spread by the Aedes aegypti mosquito. The virus can cause mild symptoms or progress to severe illness, including high fever, jaundice, bleeding, and organ failure.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'There is no specific treatment for yellow fever, but it can be prevented through vaccination. The yellow fever vaccine provides lifelong immunity after a single dose.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Outbreaks of yellow fever can occur when people infected with the virus enter densely populated areas where the Aedes mosquito is present. Vaccination is key to preventing these outbreaks.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Travel Advisory',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Travelers to areas where yellow fever is endemic should get vaccinated at least 10 days before travel. Some countries require proof of yellow fever vaccination for entry.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.A99wA7Dng8SJJIkOtju34wAAAA?rs=1&pid=ImgDetMain',
      id: 'yellowf',
    ),

    NewsItem(
      title: 'Cholera',
      subtitle:
          'Cholera is an acute diarrheal illness caused by infection of the intestine with Vibrio cholerae bacteria.',
      content: [
        StyledContent(
          'Cholera is spread by consuming water or food contaminated with the bacterium Vibrio cholerae. The disease can cause severe diarrhea and dehydration, which can be fatal if not treated promptly.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Cholera is most common in places with inadequate water treatment, poor sanitation, and insufficient hygiene practices. Outbreaks often occur after natural disasters or in conflict zones where clean water is scarce.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment of cholera involves prompt rehydration, usually with oral rehydration salts (ORS). In severe cases, intravenous fluids and antibiotics may be needed.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Preventive Measures',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'To prevent cholera, drink and use safe water, wash your hands with soap and clean water, and eat food that is thoroughly cooked. In areas where cholera is common, vaccination may be recommended.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://www.metropolisindia.com/upgrade/blog/upload/24/02/Everything_you_need_to_know_about_Cholera1707909522.webp',
      id: 'cholera',
    ),

    NewsItem(
      title: 'Lassa Fever',
      subtitle:
          'Lassa fever is an acute viral hemorrhagic illness caused by the Lassa virus, transmitted to humans through contact with food or household items contaminated with rodent urine or feces.',
      content: [
        StyledContent(
          'Lassa fever is endemic in parts of West Africa. The primary hosts of the Lassa virus are rodents, particularly the multimammate rat. Human transmission can occur through contact with contaminated food or materials.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of Lassa fever range from mild to severe, including fever, general weakness, and malaise. Severe cases can lead to bleeding, shock, and multiple organ failure.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Early supportive care with rehydration and symptomatic treatment improves survival. Ribavirin, an antiviral drug, may be effective if given early in the course of the illness.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Prevention and Control',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Preventing Lassa fever involves improving sanitation and storing food properly to keep it safe from rodents. Health workers should use protective equipment to avoid infection when caring for patients.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.212ed56a77b3704e6dd1d9133c22566c?rik=edURLy9c245DDg&pid=ImgRaw&r=0',
      id: 'lassa',
    ),

    NewsItem(
      title: 'Tuberculosis (TB)',
      subtitle:
          'Tuberculosis is a potentially serious infectious disease that mainly affects the lungs, caused by the bacterium Mycobacterium tuberculosis.',
      content: [
        StyledContent(
          'TB spreads from person to person through the air when someone with active TB disease of the lungs coughs, speaks, or sings. Close contacts with the infected person are at higher risk of contracting the disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Not everyone infected with TB bacteria becomes sick. As a result, two TB-related conditions exist: latent TB infection (LTBI) and TB disease. People with latent TB do not show symptoms and are not contagious, while those with TB disease show symptoms and can spread the bacteria.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'The most common symptoms of active TB include a prolonged cough, pain in the chest, and coughing up blood or sputum. Other symptoms include weakness, weight loss, and fever.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment and Prevention',
          TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontFamily: 'Wittgenstein',
              fontWeight: FontWeight.bold),
        ),
        StyledContent(
          'TB is treatable with a regimen of drugs taken for six to nine months. It is essential to complete the entire course of treatment to prevent the development of drug-resistant TB. Vaccination with the Bacillus Calmette-Guerin (BCG) vaccine can provide protection against severe forms of TB in children.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://pub.mdpi-res.com/pathogens/pathogens-11-01101/article_deploy/html/images/pathogens-11-01101-g001.png?1664184177',
      id: 'tuber',
    ),

    NewsItem(
      title: 'Sinusitis',
      subtitle:
          'Sinusitis is an inflammation or swelling of the tissue lining the sinuses. It can be caused by infections, allergies, or autoimmune issues.',
      content: [
        StyledContent(
          'Sinusitis is classified as acute or chronic, depending on the duration and frequency of symptoms. Acute sinusitis lasts for a short period, often following a cold, and is usually viral. Chronic sinusitis can last for 12 weeks or more and may result from prolonged infection, allergies, or structural nasal problems.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of sinusitis include facial pain or pressure, nasal congestion or blockage, reduced sense of smell, and postnasal drip. These symptoms can significantly affect quality of life.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment depends on the cause of sinusitis. For acute sinusitis, over-the-counter medications, such as decongestants and pain relievers, may be effective. Chronic sinusitis may require prescription medications, nasal sprays, or in some cases, surgery.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'When to See a Doctor',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'If you have recurrent or persistent symptoms of sinusitis, or if symptoms are severe, it is important to see a healthcare provider. You may need further evaluation and treatment to prevent complications, such as sinus infections or chronic sinusitis.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://www.mayoclinic.org/-/media/kcms/gbs/patient-consumer/images/2016/04/07/14/56/mcdc7_acute_sinusitis-8col.jpg',
      id: 'Sinusitis',
    ),

    NewsItem(
      title: 'Allergic Rhinitis',
      subtitle:
          'Allergic rhinitis is a common condition that occurs when your immune system overreacts to allergens in the air, such as pollen, dust, or pet dander.',
      content: [
        StyledContent(
          'Allergic rhinitis can be seasonal, known as hay fever, or perennial, occurring year-round. It is triggered by allergens that your body mistakes as harmful, causing your immune system to release chemicals like histamine.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of allergic rhinitis include sneezing, itching, runny or blocked nose, and itchy, watery eyes. These symptoms can significantly impact daily life, leading to sleep problems and decreased productivity.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Managing allergic rhinitis involves avoiding known allergens, using antihistamines, decongestants, or nasal corticosteroids. In some cases, immunotherapy (allergy shots) may be recommended for long-term treatment.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Living with Allergic Rhinitis',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Managing your environment to reduce allergen exposure is key. Consider using air filters, keeping windows closed during high pollen seasons, and regularly washing bedding and vacuuming to reduce dust mites.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.upnHDpkQGSq7TmmhgPVC8AAAAA?rs=1&pid=ImgDetMain',
      id: 'Allergic Rhinitis',
    ),

    NewsItem(
      title: 'Chronic Obstructive Pulmonary Disease (COPD)',
      subtitle:
          'COPD is a chronic inflammatory lung disease that causes obstructed airflow from the lungs, often due to smoking or long-term exposure to irritating gases.',
      content: [
        StyledContent(
          'COPD includes two main conditions: emphysema, which involves damage to the air sacs in the lungs, and chronic bronchitis, which is inflammation of the lining of the bronchial tubes. Many people with COPD have both conditions.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of COPD include shortness of breath, especially during physical activities, wheezing, chest tightness, chronic cough, and frequent respiratory infections. As the disease progresses, symptoms become more severe.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Quitting smoking is the most important step in treating COPD. Other treatments include medications, such as bronchodilators and inhaled steroids, pulmonary rehabilitation, and oxygen therapy.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Preventing and Managing COPD',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Preventing COPD involves reducing your exposure to risk factors, particularly smoking. If you have COPD, it’s important to follow your treatment plan and make lifestyle changes, such as staying active and avoiding respiratory irritants, to manage symptoms and improve your quality of life.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.atPFBqw2nyFoZ-jLSBtupgHaGR?rs=1&pid=ImgDetMain',
      id: 'Chronic',
    ),

    NewsItem(
      title: 'Heart Failure',
      subtitle:
          'Heart failure occurs when the heart muscle doesn’t pump blood as well as it should. Certain conditions, such as narrowed arteries or high blood pressure, gradually leave the heart too weak to pump blood efficiently.',
      content: [
        StyledContent(
          'Heart failure can affect the left side, right side, or both sides of the heart. The most common causes of heart failure include coronary artery disease, high blood pressure, and previous heart attack.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of heart failure include shortness of breath, fatigue, swollen legs, rapid or irregular heartbeat, and persistent coughing or wheezing. These symptoms can worsen over time if left untreated.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment for heart failure involves medications, lifestyle changes, and in some cases, surgery or medical devices. The goal is to reduce symptoms, improve quality of life, and slow the progression of the disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Living with Heart Failure',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Managing heart failure involves regular monitoring of symptoms, taking prescribed medications, following a heart-healthy diet, staying active within your limits, and avoiding tobacco. Regular follow-ups with your healthcare provider are essential to manage the condition effectively.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://www.mayoclinic.org/-/media/kcms/gbs/patient-consumer/images/2015/01/16/09/27/mcdc7_heart-failure.jpg',
      id: 'Heartf',
    ),

    NewsItem(
      title: 'Dengue Fever',
      subtitle:
          'Dengue fever is a mosquito-borne viral disease occurring in tropical and subtropical areas. It can cause severe flu-like symptoms and sometimes leads to severe dengue, which can be fatal.',
      content: [
        StyledContent(
          'Dengue fever is transmitted by the bite of Aedes mosquitoes, primarily Aedes aegypti. The virus has four different serotypes, meaning a person can be infected up to four times in their lifetime.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of dengue fever include high fever, severe headache, pain behind the eyes, joint and muscle pain, rash, and mild bleeding, such as nose or gum bleeding. Severe dengue can cause severe bleeding, organ failure, and death.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'There is no specific treatment for dengue fever, but early detection and proper medical care can lower fatality rates. Preventing mosquito bites by using repellents, wearing long sleeves, and using mosquito nets is key to preventing the disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Preventing Dengue Fever',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Reducing mosquito habitats by removing standing water around your home can help reduce the risk of dengue. Community-wide efforts to control mosquitoes are also essential in preventing outbreaks.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://i0.wp.com/uniph.go.ug/wp-content/uploads/2018/12/Investigation-of-an-imported-case-of-Dengue-fever-Uganda-November-2018-.jpg?fit=780%2C400&ssl=1',
      id: 'DengueFever',
    ),

    NewsItem(
      title: 'Leptospirosis',
      subtitle:
          'Leptospirosis is a bacterial infection spread through the urine of infected animals, often in water. It can cause mild flu-like symptoms or more severe conditions like Weil’s disease.',
      content: [
        StyledContent(
          'Leptospirosis is caused by bacteria of the genus Leptospira. It is commonly transmitted to humans through contact with water, soil, or food contaminated with the urine of infected animals, particularly rodents.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms range from mild, such as fever, chills, and muscle aches, to severe, including liver damage, kidney failure, meningitis, and respiratory distress. The severe form of leptospirosis is known as Weil’s disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Early treatment with antibiotics can reduce the severity and duration of the illness. Preventive measures include avoiding contact with contaminated water and soil, wearing protective clothing, and controlling rodent populations.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Leptospirosis Prevention',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Preventing leptospirosis involves reducing exposure to contaminated water, wearing protective gear in high-risk environments, and practicing good sanitation. Vaccination of animals can also help control the spread of the disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.fc8eed46332a2bb39aab939fbeb14f0c?rik=Ad7FvQaoiNw4Rg&pid=ImgRaw&r=0',
      id: 'Leptospirosis',
    ),

    NewsItem(
      title: 'Schistosomiasis',
      subtitle:
          'Schistosomiasis, also known as bilharzia, is a parasitic disease caused by blood flukes (trematodes) of the genus Schistosoma. It is common in tropical and subtropical regions, particularly in Africa.',
      content: [
        StyledContent(
          'Schistosomiasis is caused by the parasitic worms released by freshwater snails in contaminated water. The parasites penetrate the skin of people who come into contact with the contaminated water.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of schistosomiasis vary depending on the stage of infection. They may include a rash, itchy skin, fever, chills, cough, and muscle aches. Chronic infection can lead to severe damage to the liver, intestines, lungs, and bladder.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment for schistosomiasis includes the use of the drug praziquantel, which is effective against all forms of schistosomiasis. Prevention strategies include improving access to clean water, proper sanitation, and health education to avoid contaminated water sources.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Preventing Schistosomiasis',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Avoiding swimming or wading in freshwater bodies known to be contaminated with schistosomes, especially in endemic areas, is crucial for prevention. Boiling or filtering water before drinking can also reduce the risk of infection.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/R.afa08d6e10a9b8fd7444a3cdea0a3335?rik=Qawj3iX%2bBQkHYA&pid=ImgRaw&r=0',
      id: 'Schistosomiasis',
    ),

    NewsItem(
      title: 'Onchocerciasis (River Blindness)',
      subtitle:
          'Onchocerciasis, or river blindness, is a parasitic disease caused by the worm Onchocerca volvulus. It is transmitted to humans through the bites of infected blackflies.',
      content: [
        StyledContent(
          'Onchocerciasis is the second leading infectious cause of blindness globally. The blackflies that transmit the disease breed in fast-flowing rivers, hence the name "river blindness."',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms include severe itching, skin rashes, and eye lesions that can lead to permanent blindness. The disease also causes nodules under the skin where adult worms live.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment includes the use of ivermectin, which kills the microfilariae (immature worms) but not the adult worms. Repeated treatments are necessary to control the disease. Community-based treatment programs have been effective in reducing transmission.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Preventing River Blindness',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Prevention focuses on reducing exposure to blackfly bites by using insect repellent, wearing long sleeves and pants, and using insecticide-treated nets. Large-scale ivermectin distribution in endemic communities also helps to prevent the spread of the disease.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://th.bing.com/th/id/OIP.BaFY136pc3ISFPdhcolPBwAAAA?rs=1&pid=ImgDetMain',
      id: 'Onchocerciasis',
    ),

    NewsItem(
      title: 'African Trypanosomiasis (Sleeping Sickness)',
      subtitle:
          'African Trypanosomiasis, commonly known as sleeping sickness, is a parasitic disease caused by Trypanosoma brucei. It is transmitted to humans through the bite of the tsetse fly.',
      content: [
        StyledContent(
          'There are two forms of African trypanosomiasis: Trypanosoma brucei gambiense (chronic) and Trypanosoma brucei rhodesiense (acute). The disease occurs in sub-Saharan Africa.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Symptoms of the early stage include fever, headaches, joint pains, and itching. As the disease progresses, it crosses the blood-brain barrier and affects the central nervous system, causing confusion, sensory disturbances, and disrupted sleep cycles—hence the name "sleeping sickness."',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Treatment varies depending on the stage of the disease. Early-stage treatment involves the use of pentamidine or suramin. The second stage requires more toxic drugs like melarsoprol or eflornithine. The development of new drugs like fexinidazole offers hope for simpler treatment regimens.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
        StyledContent(
          'Prevention and Control',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
            fontWeight: FontWeight.bold,
          ),
        ),
        StyledContent(
          'Prevention of sleeping sickness focuses on reducing tsetse fly exposure. This can be achieved by wearing protective clothing, using insect repellents, and avoiding areas known to be infested with tsetse flies. Vector control programs, including trapping flies, are also effective.',
          TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontFamily: 'Wittgenstein',
          ),
        ),
      ],
      imageUrl:
          'https://www.cdc.gov/dpdx/trypanosomiasisafrican/modules/SleepingSick_LifeCycle_lg.jpg',
      id: 'AfricanTryp',
    ),
    // Add other NewsItem instances here with their IDs...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health News Feed',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        backgroundColor: Colors.white70,
        foregroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(newsItems),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(
                    newsItem: newsItems[index],
                    disease: '',
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    width: 100,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    )),
                    child: Image.network(
                      newsItems[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsItems[index].title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Wittgenstein',
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          newsItems[index].subtitle,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Wittgenstein',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Define the NewsSearchDelegate class
class NewsSearchDelegate extends SearchDelegate<String> {
  final List<NewsItem> newsItems;

  NewsSearchDelegate(this.newsItems);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = newsItems.where((newsItem) =>
        newsItem.title.toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: results.map((newsItem) {
        return ListTile(
          title: Text(newsItem.title),
          subtitle: Text(newsItem.subtitle),
          onTap: () {
            close(context, newsItem.title);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(
                  newsItem: newsItem,
                  disease: '',
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = newsItems.where((newsItem) =>
        newsItem.title.toLowerCase().startsWith(query.toLowerCase()));

    return ListView(
      children: suggestions.map((newsItem) {
        return ListTile(
          title: Text(newsItem.title),
          subtitle: Text(newsItem.subtitle),
          onTap: () {
            query = newsItem.title;
            showResults(context);
          },
        );
      }).toList(),
    );
  }
}
