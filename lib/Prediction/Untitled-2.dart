import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medicare/Health_Newz/Health_info.dart';
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
  _DiseasePredictionScreenState createState() =>
      _DiseasePredictionScreenState();
}

class _DiseasePredictionScreenState extends State<DiseasePredictionScreen> {
  final List<String> _selectedSymptoms = [];
  List<Map<String, dynamic>> _predictedDiseases = [];
  List<Map<String, dynamic>> _detectedCriticalDiseases = [];
  final List<String> _criticalDiseases = [
    'Heart Attack', 
    'Stroke',
    'Severe Allergic Reaction',
    'Pulmonary Embolism',
    'Meningitis',
    'Sepsis',
    'Acute Pancreatitis',
    'Severe Asthma Attack',
    'Anaphylaxis',
    'Acute Respiratory Distress Syndrome (ARDS)',
    'Pneumothorax (Collapsed Lung)',
    'Appendicitis',
    'Ectopic Pregnancy',
    'Diabetic Ketoacidosis (DKA)',
    'Toxic Shock Syndrome',
    'Hemorrhagic Stroke (Brain Bleed)',
    'Dissecting Aortic Aneurysm',
  ];

  final Map<String, List<String>> symptomDiseaseMap = {
    'Common Cold': [
      'Fever',
      'Cough',
      'Sore Throat',
      'Runny Nose',
      'Congestion',
      'Headache',
      'Sneezing',
      'Malaise (general feeling of discomfort)',
    ],
    'Heart Attack': [
      'Chest Pain',
      'Shortness of breath',
      'Nausea',
      'Vomiting',
      'Cold sweat',
      'Dizziness',
      'Pain or discomfort in the jaw, neck, back, arm, or shoulder',
    ],
    'Stroke': [
      'Sudden numbness or weakness',
      'Sudden confusion, trouble speaking',
      'Sudden trouble seeing in one or both eyes',
      'Sudden trouble walking, dizziness, loss of balance',
      'Sudden severe headache',
    ],
    'Mpox' : [
      'Fever'
      'Rash'
      'wollen lymph nodes'
      'Chills'
      'Headache'
       'Muscle aches'
      'Fatigue'
    ],
    'Sepsis': [
      'Fever',
      'Rapid heart rate',
      'Rapid breathing',
      'Confusion',
      'Extreme pain or discomfort',
      'Clammy or sweaty skin',
    ],
    'Pulmonary Embolism': [
      'Sudden shortness of breath',
      'Chest pain that may become worse when breathing deeply',
      'Cough, sometimes with blood-tinged sputum',
      'Rapid heart rate',
      'Dizziness',
    ],
    'Anaphylaxis': [
      'Difficulty breathing or shortness of breath',
      'Swelling of the face, lips, throat, or tongue',
      'Hives or rash',
      'Rapid pulse',
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Dizziness',
    ],
    'Meningitis': [
      'Severe headache',
      'Stiff neck',
      'High fever',
      'Sensitivity to light',
      'Nausea',
      'Vomiting',
      'Confusion or difficulty concentrating',
    ],
    'Acute Respiratory Distress Syndrome (ARDS)': [
      'Severe shortness of breath',
      'Rapid breathing',
      'Hypoxia (low blood oxygen levels)',
      'Fatigue',
      'Confusion',
      'Low blood pressure',
    ],
    'Pneumothorax (Collapsed Lung)': [
      'Sudden severe chest or upper back pain, often described as a tearing or ripping sensation',
      'Shortness of breath',
      'Rapid heart rate',
      'Fatigue',
      'Cyanosis (bluish color of the skin due to lack of oxygen)',
    ],
    'Appendicitis': [
      'Sudden pain that begins around the navel and shifts to the lower right abdomen',
      'Pain that worsens with movement, coughing, or jarring',
      'Nausea and vomiting',
      'Loss of appetite',
      'Fever',
      'Constipation or diarrhea',
    ],
    'Ectopic Pregnancy': [
      'Sharp, stabbing pain in the abdomen or pelvis',
      'Vaginal bleeding',
      'Gastrointestinal symptoms',
      'Weakness',
      'Dizziness',
      'Shoulder pain',
    ],
    'Diabetic Ketoacidosis (DKA)': [
      'High blood sugar levels',
      'Excessive thirst',
      'Frequent urination',
      'Nausea',
      'Vomiting',
      'Abdominal pain',
      'Confusion',
      'Fruity-scented breath',
    ],
    'Toxic Shock Syndrome': [
      'High fever',
      'Low blood pressure',
      'Vomiting',
      'Diarrhea',
      'Rash resembling sunburn, particularly on palms and soles',
      'Confusion',
      'Muscle aches',
    ],
    'Severe Asthma Attack': [
      'Severe shortness of breath',
      'Chest tightness or pain',
      'Coughing or wheezing',
      'Difficulty speaking',
      'Blue lips or face (cyanosis)',
      'Confusion or exhaustion',
    ],
    'Hemorrhagic Stroke (Brain Bleed)': [
      'Sudden severe headache',
      'Sudden numbness or weakness',
      'Sudden confusion or trouble speaking',
      'Sudden trouble seeing in one or both eyes',
      'Sudden trouble walking, dizziness, or loss of balance',
      'Sudden severe headache with no known cause',
    ],
    'Dissecting Aortic Aneurysm': [
      'Sudden severe chest or upper back pain, often described as a tearing or ripping sensation',
      'Shortness of breath',
      'Loss of consciousness',
      'Weakness',
      'Sweating',
      'Rapid pulse',
    ],
    'Acute Pancreatitis': [
      'Severe abdominal pain that radiates to the back',
      'Nausea',
      'Vomiting',
      'Fever',
      'Rapid pulse',
      'Swollen and tender abdomen',
    ],
    'Severe Allergic Reaction (Anaphylaxis)': [
      'Difficulty breathing',
      'shortness of breath',
      'Swelling of the face, lips, throat, or tongue',
      'Hives or rash',
      'Rapid pulse',
      'Nausea',
      'vomiting',
      'diarrhea',
      'Dizziness',
    ],

    'Bronchitis': [
      'Cough',
      'Fever',
      'Shortness of Breath',
      'chest pain',
      'fatigue',
      'Wheezing',
    ],
    'Migraine': [
      'Headache',
      'Nausea',
      'Sensitivity to Light',
      'Fatigue',
      'Depressed mood',
      'Anxious mood',
    ],
    'Food Poisoning': [
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Upset stomach',
      'Fever',
      'Blurred or double vision',
      'Headache',
      'Loss of movement in limbs',
      'Problems with swallowing',
      'Tingling or numbness of extremities',
    ],
    'Influenza (Flu)': [
      'Fever',
      'Cough',
      'Sore Throat',
      'Runny or Stuffy Nose',
      'Body Aches',
      'Fatigue',
      'Headache'
    ],
    'COVID-19 (Coronavirus Disease)': [
      'Fever',
      'Cough',
      'Shortness of Breath',
      'Fatigue',
      'Loss of Taste or Smell',
      'Sore Throat'
    ],
    'Pneumonia': [
      'Fever',
      'Chills',
      'Cough with Phlegm',
      'Difficulty Breathing',
      'Chest Pain',
      'Fatigue',
      'Nausea',
      'Vomiting'
    ],
    'Asthma': [
      'Shortness of Breath',
      'Wheezing',
      'Cough',
      'Chest Tightness',
      'Difficulty Breathing',
      'Fatigue',
      'Trouble Sleeping',
    ],
    'Diabetes Mellitus': [
      'Excessive Thirst',
      'Frequent Urination',
      'Unexplained Weight Loss',
      'Fatigue',
      'Blurred Vision',
      'Slow Wound Healing'
    ],
    'Hypertension (High Blood Pressure)': [
      'Headaches',
      'Dizziness',
      'Blurred Vision',
      'Chest Pain',
      'Shortness of Breath',
      'Irregular Heartbeat',
      'Nosebleeds',
    ],
    'Coronary Artery Disease': [
      'Chest Pain',
      'Shortness of Breath',
      'Fatigue',
      'Nausea',
      'Sweating',
      'Dizziness'
    ],
    'Gastroesophageal Reflux Disease (GERD)': [
      'Heartburn',
      'Regurgitation of Food or Sour Liquid',
      'Difficulty Swallowing',
      'Chest Pain',
      'Cough'
    ],
    'Osteoarthritis': [
      'Joint Pain',
      'Stiffness',
      'Tenderness',
      'Loss of Flexibility',
      'Grating Sensation in the Joint'
    ],
    'Rheumatoid Arthritis': [
      'Joint Pain',
      'Swelling',
      'Stiffness',
      'Fatigue',
      'Fever',
      'Weight Loss'
    ],
    'Chronic Obstructive Pulmonary Disease (COPD)': [
      'Shortness of Breath',
      'Chronic Cough with Mucus',
      'Wheezing',
      'Chest Tightness',
      'Fatigue'
    ],
    'Cancer': [
      'Unexplained Weight Loss',
      'Fatigue',
      'Changes in Bowel or Bladder Habits',
      'Persistent Cough',
      'Lumps or Growths',
      'Changes in Skin Moles'
    ],
    'Alzheimer\'s Disease': [
      'Memory Loss',
      'Confusion',
      'Difficulty Completing Familiar Tasks',
      'Challenges with Problem-Solving',
      'Changes in Mood and Personality'
    ],
    'Parkinson\'s Disease': [
      'Tremors',
      'Bradykinesia (Slowed Movement)',
      'Rigidity',
      'Impaired Balance',
      'Speech Changes',
      'Loss of Automatic Movements'
    ],
    'Multiple Sclerosis (MS)': [
      'Fatigue',
      'Numbness or Weakness in Limbs',
      'Electric Shock Sensations with Neck Movements',
      'Tremors',
      'Lack of Coordination',
      'Vision Problems'
    ],
    'Depression': [
      'Persistent Sadness',
      'Loss of Interest or Pleasure in Activities',
      'Changes in Appetite or Weight',
      'Sleep Disturbances',
      'Fatigue',
      'Feelings of Worthlessness or Guilt'
    ],
    'Anxiety Disorders': [
      'Excessive Worry or Fear',
      'Restlessness',
      'Irritability',
      'Muscle Tension',
      'Difficulty Concentrating',
      'Sleep Disturbances'
    ],

    'Hepatitis A': [
      'Fever',
      'Fatigue',
      'Loss of Appetite',
      'Nausea',
      'Vomiting',
      'Abdominal Pain',
      'Jaundice'
    ],
    'Hepatitis B': [
      'Fatigue',
      'Fever',
      'Abdominal Pain',
      'Dark Urine',
      'Joint Pain',
      'Jaundice'
    ],
    'Hepatitis C': [
      'Fatigue',
      'Fever',
      'Abdominal Pain',
      'Dark Urine',
      'Joint Pain',
      'Jaundice'
    ],
    'Hepatitis D': [
      'Fatigue',
      'Fever',
      'Abdominal Pain',
      'Dark Urine',
      'Joint Pain',
      'Jaundice'
    ],
    'Hepatitis E': [
      'Fatigue',
      'Fever',
      'Abdominal Pain',
      'Dark Urine',
      'Joint Pain',
      'Jaundice'
    ],
    'Hepatitis G': [
      'Fatigue',
      'Fever',
      'Abdominal Pain',
      'Dark Urine',
      'Joint Pain',
      'Jaundice'
    ],

    'Tetanus': [
      'Stiffness in Jaw Muscles',
      'Stiffness in Neck Muscles',
      'Difficulty Swallowing',
      'Stiffness of Abdominal Muscles',
      'Painful Body Spasms'
    ],
    'Chickenpox': [
      'Rash (Small, Red Bumps)',
      'Fatigue',
      'Fever',
      'Headache',
      'Loss of Appetite'
    ],
    'Measles': [
      'Rash (Red Spots)',
      'Fever',
      'Cough',
      'Runny Nose',
      'Conjunctivitis (Red Eyes)'
    ],
    'Rubella': [
      'Rash (Pink or Light Red)',
      'Fever',
      'Swollen Lymph Nodes',
      'Headache',
      'Congestion'
    ],
    'Dengue Fever': [
      'High Fever',
      'Severe Headache',
      'Pain Behind the Eyes',
      'Severe Joint and Muscle Pain',
      'Nausea',
      'Vomiting',
      'Skin Rash'
    ],
    'Chikungunya': [
      'Fever',
      'Joint Pain (Mainly in Hands and Feet)',
      'Headache',
      'Muscle Pain',
      'Joint Swelling',
      'Rash'
    ],
    'Ebola Virus Disease': [
      'Fever',
      'Severe Headache',
      'Muscle Pain',
      'Fatigue',
      'Diarrhea',
      'Vomiting',
      'Abdominal Pain',
      'Unexplained Hemorrhage'
    ],
    'Yellow Fever': [
      'Fever',
      'Headache',
      'Muscle Aches',
      'Jaundice',
      'Bleeding (From Nose, Mouth, or Eyes)'
    ],
    'Lassa Fever': [
      'Fever',
      'Fatigue',
      'Sore Throat',
      'Cough',
      'Nausea',
      'Vomiting',
      'Diarrhea'
    ],
    'Marburg Virus Disease': [
      'Fever',
      'Headache',
      'Fatigue',
      'Muscle Pain',
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Hemorrhage'
    ],
    'Cholera': [
      'Profuse Watery Diarrhea',
      'Vomiting',
      'Rapid Heart Rate',
      'Low Blood Pressure',
      'Dehydration',
      'Muscle Cramps'
    ],
    'Tuberculosis (TB)': [
      'Persistent Cough (Sometimes with Blood)',
      'Chest Pain',
      'Weight Loss',
      'Fatigue',
      'Fever',
      'Night Sweats'
    ],
    'Pertussis (Whooping Cough)': [
      'Severe Coughing Fits',
      'Whooping Sound When Coughing',
      'Vomiting After Coughing Fits'
    ],
    'Leprosy': [
      'Skin Lesions',
      'Numbness in Affected Areas',
      'Muscle Weakness',
      'Loss of Fingers or Toes',
      'Eye Problems'
    ],
    'Leishmaniasis': [
      'Skin Sores',
      'Fever',
      'Enlarged Spleen and Liver',
      'Weight Loss',
      'Fatigue'
    ],
    'Schistosomiasis (Bilharzia)': [
      'Abdominal Pain',
      'Diarrhea',
      'Bloody Stool or Urine',
      'Fatigue',
      'Fever',
      'Cough'
    ],
    'Onchocerciasis (River Blindness)': [
      'Itching',
      'Skin Lesions',
      'Eye Problems',
      'Blindness'
    ],
    'Trypanosomiasis (Sleeping Sickness)': [
      'Fever',
      'Headache',
      'Joint Pain',
      'Itching',
      'Swollen Lymph Nodes'
    ],
    'Lymphatic Filariasis': [
      'Swelling of Limbs (Lymphedema)',
      'Swelling of Genitalia (Hydrocele)',
      'Skin Lesions',
      'Fever'
    ],
    'Trachoma': [
      'Eye Discharge',
      'Swelling of Eyelids',
      'Sensitivity to Light',
      'Blurred Vision',
      'Corneal Scarring'
    ],
    'Diphtheria': [
      'Sore Throat',
      'Fever',
      'Swollen Neck Glands',
      'Difficulty Breathing',
      'Weakness'
    ],
    'Gonorrhea': [
      'Painful Urination',
      'Discharge from the Penis or Vagina',
      'Painful or Swollen Testicles',
      'Vaginal Bleeding Between Periods'
    ],
    'Syphilis': [
      'Sores (Chancre)',
      'Rash (Non-Itchy)',
      'Fever',
      'Swollen Lymph Nodes',
      'Fatigue'
    ],
    'Chlamydia': [
      'Painful Urination',
      'Discharge from the Penis or Vagina',
      'Pain During Sex',
      'Lower Abdominal Pain'
    ],
    'Genital Herpes': [
      'Painful Blisters or Ulcers in the Genital Area',
      'Itching',
      'Pain During Urination'
    ],
    'Human Papillomavirus (HPV) Infection': [
      'Genital Warts',
      'Abnormal Pap Smear',
      'Cervical Dysplasia'
    ],
    'HIV/AIDS': [
      'Fever',
      'Fatigue',
      'Swollen Lymph Nodes',
      'Night Sweats',
      'Sore Throat',
      'Rash'
    ],
    'Hemorrhoids': [
      'Rectal Bleeding',
      'Itching or Irritation Around the Anus',
      'Pain or Discomfort During Bowel Movements'
    ],
    'Inflammatory Bowel Disease (IBD)': [
      'Abdominal Pain',
      'Diarrhea',
      'Bloody Stools',
      'Weight Loss',
      'Fatigue'
    ],
    'Irritable Bowel Syndrome (IBS)': [
      'Abdominal Pain or Cramping',
      'Bloating',
      'Gas',
      'Diarrhea or Constipation'
    ],
    'Diverticulitis': [
      'Abdominal Pain (Usually in the Left Lower Side)',
      'Fever',
      'Nausea',
      'Vomiting',
      'Change in Bowel Habits'
    ],
    'Gallstones': [
      'Pain in the Upper Right Abdomen',
      'Nausea',
      'Vomiting',
      'Fever',
      'Yellowing of the Skin and Eyes (Jaundice)'
    ],
    'Pancreatitis': [
      'Severe Abdominal Pain',
      'Nausea',
      'Vomiting',
      'Fever',
      'Rapid Pulse'
    ],

    'Ischemic Stroke': [
      'Sudden Weakness or Numbness of Face, Arm, or Leg',
      'Sudden Confusion',
      'Trouble Speaking or Understanding Speech',
      'Severe Headache'
    ],
    'Deep Vein Thrombosis (DVT)': [
      'Swelling in One Leg',
      'Leg Pain or Tenderness',
      'Red or Discolored Skin on the Leg',
      'Warmth in the Affected Area'
    ],

    'Obstructive Sleep Apnea': [
      'Loud Snoring',
      'Episodes of Stopped Breathing During Sleep',
      'Gasping or Choking During Sleep',
      'Morning Headaches',
      'Daytime Sleepiness'
    ],
    'Insomnia': [
      'Difficulty Falling Asleep',
      'Difficulty Staying Asleep',
      'Waking Up Too Early',
      'Not Feeling Rested After Sleep'
    ],
    'Narcolepsy': [
      'Excessive Daytime Sleepiness',
      'Sudden Loss of Muscle Tone (Cataplexy)',
      'Sleep Paralysis',
      'Hallucinations'
    ],
    'Restless Legs Syndrome (RLS)': [
      'Uncomfortable Sensations in the Legs (Usually at Night)',
      'Urge to Move Legs',
      'Relief with Movement'
    ],
    'Fibromyalgia': [
      'Widespread Muscle Pain',
      'Fatigue',
      'Sleep Disturbances',
      'Tender Points'
    ],
    'Chronic Fatigue Syndrome (CFS)': [
      'Severe Fatigue',
      'Muscle Pain',
      'Headaches',
      'Sleep Problems'
    ],
    'Hypothyroidism': [
      'Fatigue',
      'Weight Gain',
      'Cold Sensitivity',
      'Dry Skin',
      'Constipation',
      'Depression'
    ],
    'Hyperthyroidism': [
      'Weight Loss',
      'Rapid Heart Rate',
      'Irregular Heartbeat',
      'Sweating',
      'Nervousness',
      'Tremors'
    ],
    'Celiac Disease': [
      'Abdominal Pain',
      'Diarrhea',
      'Bloating',
      'Weight Loss',
      'Fatigue'
    ],
    'Crohns Disease': [
      'Abdominal Pain',
      'Diarrhea',
      'Fatigue',
      'Weight Loss',
      'Fever'
    ],
    'Ulcerative Colitis': [
      'Abdominal Pain',
      'Bloody Diarrhea',
      'Urgency to Defecate',
      'Fatigue',
      'Weight Loss'
    ],
    'Endometriosis': [
      'Pelvic Pain',
      'Painful Menstruation',
      'Painful Intercourse',
      'Infertility',
      'Heavy Menstrual Bleeding'
    ],
    'Polycystic Ovary Syndrome (PCOS)': [
      'Irregular Menstrual Periods',
      'Excess Hair Growth (Hirsutism)',
      'Acne',
      'Weight Gain',
      'Difficulty Getting Pregnant'
    ],
    'Uterine Fibroids': [
      'Heavy Menstrual Bleeding',
      'Pelvic Pain or Pressure',
      'Frequent Urination',
      'Constipation',
      'Backache'
    ],
    'Ovarian Cysts': [
      'Pelvic Pain',
      'Bloating',
      'Painful Bowel Movements',
      'Pain During Intercourse',
      'Irregular Menstrual Periods'
    ],
    'Premenstrual Syndrome (PMS)': [
      'Mood Swings',
      'Irritability',
      'Fatigue',
      'Bloating',
      'Breast Tenderness'
    ],
    'Vaginal Yeast Infection': [
      'Itching',
      'Burning Sensation',
      'White, Clumpy Discharge'
    ],
    'Urinary Tract Infection (UTI)': [
      'Painful or Burning Urination',
      'Frequent Urination',
      'Cloudy or Bloody Urine',
      'Strong Urge to Urinate',
      'Pelvic Pain'
    ],
    'Interstitial Cystitis (Painful Bladder Syndrome)': [
      'Pelvic Pain',
      'Frequent Urination',
      'Painful Urination',
      'Urgency to Urinate',
      'Pain During Sexual Intercourse'
    ],
    'Erectile Dysfunction': [
      'Difficulty Achieving or Maintaining an Erection',
      'Reduced Sexual Desire'
    ],
    'Premature Ejaculation': [
      'Ejaculation that Occurs Too Quickly',
      'Feeling of Lack of Control over Ejaculation'
    ],
    'Prostate Problems (e.g., BPH, Prostatitis)': [
      'Frequent Urination',
      'Difficulty Urinating',
      'Weak Urine Stream',
      'Pain or Burning During Urination'
    ],
    'Testicular Cancer': [
      'Lump or Swelling in Testicle',
      'Heaviness in Scrotum',
      'Dull Ache in Lower Abdomen or Groin',
      'Sudden Accumulation of Fluid in Scrotum'
    ],
    'Epididymitis': [
      'Scrotal Pain',
      'Swelling of the Scrotum',
      'Tenderness of the Epididymis',
      'Painful Urination'
    ],
    'Ovarian Cancer': [
      'Abdominal Bloating',
      'Pelvic Pain',
      'Abdominal Pain',
      'Feeling Full Quickly',
      'Frequent Urination'
    ],
    'Cervical Cancer': [
      'Abnormal Vaginal Bleeding',
      'Pelvic Pain',
      'Painful Intercourse',
      'Vaginal Discharge'
    ],
    'Endometrial Cancer': [
      'Abnormal Vaginal Bleeding',
      'Pelvic Pain',
      'Painful Intercourse',
      'Vaginal Discharge'
    ],
    'Vaginal Cancer': [
      'Abnormal Vaginal Bleeding',
      'Vaginal Discharge',
      'Pelvic Pain'
    ],
    'Penile Cancer': [
      'Lump on the Penis',
      'Changes in Skin Color or Texture',
      'Bleeding or Discharge from the Penis'
    ],
    'Anal Cancer': [
      'Anal Bleeding or Discharge',
      'Pain or Pressure in the Anal Area',
      'Changes in Bowel Habits'
    ],
    'Colon Cancer': [
      'Change in Bowel Habits',
      'Blood in Stool',
      'Abdominal Pain',
      'Unexplained Weight Loss',
      'Fatigue'
    ],
    'Rectal Cancer': [
      'Blood in Stool',
      'Change in Bowel Habits',
      'Abdominal Pain',
      'Fatigue'
    ],
    'Liver Cancer': [
      'Abdominal Pain',
      'Swelling in the Abdomen',
      'Unexplained Weight Loss',
      'Loss of Appetite'
    ],
    'Stomach Cancer': [
      'Abdominal Pain',
      'Nausea',
      'Vomiting',
      'Unexplained Weight Loss'
    ],
    'Esophageal Cancer': [
      'Difficulty Swallowing',
      'Painful Swallowing',
      'Unexplained Weight Loss',
      'Chest Pain'
    ],
    'Pancreatic Cancer': [
      'Abdominal Pain',
      'Unexplained Weight Loss',
      'Loss of Appetite',
      'Jaundice'
    ],
    'Lung Cancer': [
      'Persistent Cough',
      'Coughing up Blood',
      'Shortness of Breath',
      'Chest Pain',
      'Unexplained Weight Loss'
    ],
    'Breast Cancer': [
      'Lump in Breast or Armpit',
      'Changes in Breast Size or Shape',
      'Nipple Discharge',
      'Redness or Thickening of Breast Skin'
    ],
    'Prostate Cancer': [
      'Urinary Problems (e.g., Frequent Urination, Weak Urine Stream)',
      'Blood in Urine or Semen',
      'Erectile Dysfunction'
    ],
    'Kidney Cancer': [
      'Blood in Urine',
      'Pain in the Side or Back',
      'Lump in the Side or Abdomen',
      'Unexplained Weight Loss'
    ],
    'Bladder Cancer': [
      'Blood in Urine',
      'Frequent Urination',
      'Painful Urination',
      'Pelvic Pain'
    ],
    'Melanoma': [
      'Change in the Size, Shape, or Color of a Mole or Skin Lesion',
      'Itching or Pain in a Mole',
      'Bleeding or Oozing from a Mole'
    ],
    'Non-Melanoma Skin Cancer (e.g., Basal Cell Carcinoma, Squamous Cell Carcinoma)':
        [
      'Persistent Sore or Lump on the Skin',
      'Skin Lesion that Doesn\'t Heal',
      'Change in Skin Color or Texture'
    ],
    'Brain Tumor': [
      'Headaches',
      'Seizures',
      'Nausea',
      'Vomiting',
      'Vision Problems',
      'Memory Problems',
      'Personality Changes'
    ],
    'Bone Cancer': [
      'Pain in the Bones',
      'Swelling or Lumps Near the Bones',
      'Fractures with Minimal Trauma'
    ],
    'Soft Tissue Sarcoma': [
      'Lump or Swelling',
      'Pain',
      'Difficulty Breathing or Swallowing (Depending on Location)'
    ],
    'Leukemia': [
      'Fatigue',
      'Pale Skin',
      'Fever',
      'Easy Bruising or Bleeding',
      'Frequent Infections'
    ],
    'Lymphoma': [
      'Swollen Lymph Nodes (Usually in Neck, Armpits, or Groin)',
      'Fatigue',
      'Fever',
      'Night Sweats',
      'Unexplained Weight Loss'
    ],
    'Myeloma': [
      'Bone Pain (Usually in the Back or Ribs)',
      'Weakness or Numbness in the Legs',
      'Fatigue',
      'Frequent Infections'
    ],
    'Hodgkin Lymphoma': [
      'Swollen Lymph Nodes (Usually in Neck, Armpits, or Groin)',
      'Fatigue',
      'Fever',
      'Night Sweats',
      'Unexplained Weight Loss'
    ]

    // Add more diseases and symptoms as needed
  };

  final List<String> _symptoms = [
    'Abdominal Bloating',
    'Abdominal Pain',
    'Abdominal Pain (Usually in the Left Lower Side)',
    'Abdominal Pain or Cramping',
    'Abnormal Vaginal Bleeding',
    'Anal Bleeding or Discharge',
    'Anxious mood',
    'Backache',
    'Bleeding (From Nose, Mouth, or Eyes)',
    'Bleeding or Discharge from the Penis',
    'Blood in Stool',
    'Blood in Urine',
    'Bloody Diarrhea',
    'Bloody Stool or Urine',
    'Blurred or double vision',
    'Body Aches',
    'Chest Pain',
    'Chest Pain (Especially with Deep Breaths)',
    'Chest pain that may become worse when breathing deeply',
    'Chest Tightness',
    'Chills',
    'Clammy or sweaty skin',
    'Confusion',
    'Congestion',
    'Conjunctivitis (Red Eyes)',
    'Constipation',
    'Cough',
    'Cough with Phlegm',
    'Cough, sometimes with blood-tinged sputum',
    'Coughing',
    'Cyanosis (bluish color of the skin due to lack of oxygen)',
    'Dark Urine',
    'Depressed mood',
    'Depression',
    'Diarrhea',
    'Difficulty Breathing',
    'Difficulty Swallowing',
    'Dizziness',
    'Dry Skin',
    'Dull Ache in Lower Abdomen or Groin',
    'Ear Discharge',
    'Easy Bruising or Bleeding',
    'Electric Shock Sensations with Neck Movements',
    'Episodes of Stopped Breathing During Sleep',
    'Excessive Daytime Sleepiness',
    'Excessive Thirst',
    'Excess Hair Growth (Hirsutism)',
    'Excessive Worry or Fear',
    'Extreme pain or discomfort',
    'Eye Discharge',
    'Eye Problems',
    'Eyelid Swelling',
    'Fatigue',
    'Feeling Anxious or Faint',
    'Feeling Full Quickly',
    'Feeling of Lack of Control over Ejaculation',
    'Fever',
    'Fractures with Minimal Trauma',
    'Frequent Infections',
    'Frequent Urination',
    'Gas',
    'Gasping or Choking During Sleep',
    'Hallucinations',
    'Headache',
    'Heartburn',
    'Heaviness in Scrotum',
    'Heavy Menstrual Bleeding',
    'High Fever',
    'Hives or rash',
    'Hypoxia (low blood oxygen levels)',
    'Irregular Heartbeat',
    'Irritability',
    'Itching',
    'Itching or Irritation Around the Anus',
    'Itching or Pain in a Mole',
    'Irregular Heartbeat',
    'Irregular Menstrual Periods',
    'Irregular Heartbeat',
    'Jaundice',
    'Joint Pain',
    'Joint Pain (Mainly in Hands and Feet)',
    'Joint Swelling',
    'Lack of Coordination',
    'Loss of Appetite',
    'Loss of consciousness',
    'Loss of movement in limbs',
    'Loss of Flexibility',
    'Loss of Taste or Smell',
    'Loss of Wound Healing',
    'Low Blood Pressure',
    'Lump in Breast or Armpit',
    'Lump on the Penis',
    'Lump or Swelling',
    'Lump or Swelling in Testicle',
    'Loss of Automatic Movements',
    'Malaise (general feeling of discomfort)',
    'Memory Loss',
    'Memory Problems',
    'Muscle aches'
    'Muscle Pain',
    'Muscle Weakness',
    'Nausea',
    'Night Sweats',
    'Nosebleeds',
    'Numbness in Affected Areas',
    'Numbness or Weakness in Limbs',
    'Pain During Intercourse',
    'Pain During Sex',
    'Pain During Urination',
    'Pain that worsens with movement, coughing, or jarring',
    'Pain or Discomfort During Bowel Movements',
    'Painful Bowel Movements',
    'Painful Blisters or Ulcers in the Genital Area',
    'Painful Menstruation',
    'Painful or Swollen Testicles',
    'Painful Swallowing',
    'Painful Urination',
    'Pelvic Pain',
    'Pelvic Pain or Pressure',
    'Persistent Cough',
    'Persistent Cough (Sometimes with Blood)',
    'Persistent Sadness',
    'Personality Changes',
    'Problems with swallowing',
    'Rapid pulse',
    'Rapid heart rate',
    'Rapid breathing',
    'Runny Nose',
    'Severe headache',
    'Stiff neck',
    'Sensitivity to Light',
    'Severe abdominal pain that radiates to the back',
    'Shortness of Breath',
    'Slow Wound Healing'
    'Sneezing',
    'Sore Throat',
    'Sudden severe chest or upper back pain, often described as a tearing or ripping sensation',
    'Sudden severe headache',
    'Sudden numbness or weakness',
    'Sudden pain that begins around the navel and shifts to the lower right abdomen',
    'Sudden confusion or trouble speaking',
    'Sudden trouble seeing in one or both eyes',
    'Sudden trouble walking, dizziness, or loss of balance',
    'Swelling of the face, lips, throat, or tongue',
    'Sweating',
    'Swollen and tender abdomen',
    'Swollen lymph nodes'
    'Tingling or numbness of extremities',
    'Trouble Sleeping',
    'Unexplained Weight Loss',
    'Vomiting',
    'Wheezing',
    'Weakness or paralysis',
    'Cold sweat',
    'Pain or discomfort in the jaw, neck, back, arm, or shoulder',

    // Add more symptoms as needed
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
          // Background image
          
      
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
         )
        ),
        ],
    ));
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
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
      ),
      


      suggestionsCallback: (pattern) async {
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
    const emergencyNumber = 'tel:911'; // Replace with appropriate number
    if (await canLaunch(emergencyNumber)) {
      await launch(emergencyNumber);
    } else {
      throw 'Could not launch $emergencyNumber';
    }
  }
}

