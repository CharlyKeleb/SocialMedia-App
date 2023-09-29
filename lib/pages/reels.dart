import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';

class WoobleReels extends StatefulWidget {
  const WoobleReels({super.key});

  @override
  State<WoobleReels> createState() => _WoobleReelsState();
}

class _WoobleReelsState extends State<WoobleReels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: 10,
        controller: PageController(
          viewportFraction: 1,
          initialPage: 0,
        ),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              Image.asset(
                'assets/images/cm0.jpeg',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  Container(
                    height: 100.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reels',
                          style: GoogleFonts.amaranth(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            height: 120.0,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
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
                                        padding: const EdgeInsets.all(0.5),
                                        child: CircleAvatar(
                                          radius: 19.0,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 18.0,
                                            backgroundColor: Colors.grey,
                                            backgroundImage: AssetImage(
                                                'assets/images/cm0.jpeg'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'CharlyKeleb.dev',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color:Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Hi guys, we just rolled out a new release",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color:Colors.white,

                                  ),
                                ),
                                SizedBox(
                                  width: 200.0,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.grey.withOpacity(0.2),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.grey.withOpacity(0.2),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.music,
                                          size: 15.0,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10.0),
                                        Text(
                                          "Blow off my cover",
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //reaction section
                        Container(
                          width: 100.0,
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3.5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Ionicons.heart,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.0),
                                    child: Text(
                                      '10 likes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Icon(
                                    Iconsax.message,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.0),
                                    child: Text(
                                      '10 replies',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Icon(
                                    CupertinoIcons.reply,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.0),
                                    child: Text(
                                      '10 shares',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
