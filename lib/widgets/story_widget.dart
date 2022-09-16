import 'package:flutter/material.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: ListView.builder(
          itemCount: 5,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: new Offset(0.0, 0.0),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        radius: 35.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: AssetImage('assets/images/cm0.jpeg'),
                      ),
                    ),
                  ),
                  Text(
                    'CharlyKeleb',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
