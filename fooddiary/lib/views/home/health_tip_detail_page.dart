import 'package:flutter/material.dart';

import 'health_tip_page.dart';

class HealthTipDetailPage extends StatelessWidget {
  final HealthTip _healthTip;
  final int index;

  const HealthTipDetailPage(this._healthTip, this.index, {super.key});

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Hero(
            tag: _healthTip.image!,
            child: FittedBox(child: Image.asset(_healthTip.image!)),
          ),
          const SizedBox(height: 28),
          Text(
            _healthTip.title!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getContent(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff343334),
            ),
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("Health Tips",style: TextStyle(color: Colors.white),),
      backgroundColor: const Color(0xff102B46),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  String getContent() {
    if (index == 0) {
      return fakeContent;
    } else if (index == 1) {
      return fakeContent2;
    } else {
      return fakeContent3;
    }
  }
}

const fakeContent = """
1) Interval Training is a form of exercise in which you alternate between two or more different exercise . This Consist of doing an exercise at a very high  level intensity for a short bursts.

2) Some high intensity interval training is a great way to burn calories and lose weight.

3) Another great thing is about interval training is that it is extremely time efficient. It does not make any time to get into shape when you practice high intensity interval training.

4) Exercise, especially high intensity interval training, is awesome because it keeps you younger for longer....  

5) Interval Training is a form of exercise in which you alternate between two or more different exercise . This Consist of doing an exercise at a very high  level intensity for a short bursts.

6) Some high intensity interval training is a great way to burn calories and lose weight.

7) Another great thing is about interval training is that it is extremely time efficient. It does not make any time to get into shape when you practice high intensity interval training.

8) Exercise, especially high intensity interval training, is awesome because it keeps you younger for longer….  """;

const fakeContent2 = """
(1) Boosts Immunity
Garlic is rich in antioxidants and compounds like allicin, which help strengthen the immune system and fight off infections.

(2) Supports Heart Health
Regular consumption of garlic can help reduce blood pressure, lower cholesterol levels, and improve overall heart health.

(3) Rich in Nutrients
Garlic contains essential vitamins and minerals, such as vitamin C, vitamin B6, and manganese, supporting overall wellness.

(4) Anti-inflammatory Properties
Garlic's natural anti-inflammatory compounds help reduce inflammation in the body, promoting joint and muscle health.

(5) Aids Digestion
Garlic stimulates the production of digestive enzymes, improving gut health and preventing digestive issues like bloating.

(6) Natural Detoxifier
Garlic helps detoxify the body by promoting the elimination of toxins, supporting liver health, and boosting metabolism..  """;

const fakeContent3 = """
(1) Daily Exercise
Incorporate at least 30 minutes of moderate exercise, like walking or cycling, into your routine.

(2) Balanced Diet
Eat a variety of nutrient-rich foods, focusing on fruits, vegetables, lean proteins, and whole grains.

(3) Adequate Sleep
Ensure 7-9 hours of quality sleep each night to aid muscle recovery and overall health.

(4) Hydration
Drink plenty of water throughout the day to keep your body hydrated and support muscle function.

(5) Strength Training
Include strength training exercises at least twice a week to build muscle mass and improve strength.

(6) Stretching
Incorporate regular stretching to maintain flexibility and reduce the risk of injury.

(7) Rest and Recovery
Allow your muscles time to rest and recover after intense workouts to prevent burnout and injury.

(8) Cardio Workouts
Engage in cardiovascular exercises, such as jogging or swimming, to improve heart health and stamina.

(9) Avoid Processed Foods
Limit your intake of processed foods high in sugar and unhealthy fats to support overall wellness.

(10) Regular Health Check-ups
Schedule regular health check-ups to monitor your fitness progress and detect potential issues early. """;
