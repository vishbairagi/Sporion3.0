import 'package:flutter/material.dart';
import 'package:livebuzz/Games/BasketballPage.dart';
import 'package:livebuzz/Games/CricketScorePage.dart';
import 'package:livebuzz/Games/Kabbadi.dart';
import 'package:livebuzz/Games/noticeboard.dart';
import 'package:livebuzz/Games/VolleyballScorePage.dart';
import 'package:livebuzz/global.dart';
import 'package:livebuzz/main.dart';

import 'Games/khokho.dart';

class SportsPage extends StatelessWidget {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Sports Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Table Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Statistics Page', style: TextStyle(fontSize: 24))),
  ];

  final List<Map<String, String>> sports = [
    {
      'name': 'Basketball',
      'image': 'assets/images/basketball-hoop-with-blue-sky.jpg',
    },
    {
      'name': 'Cricket',
      'image': 'assets/images/cricket-bat-ball-foreground-pitch.jpg',
    },
    {
      'name': 'Volleyball',
      'image': 'assets/images/vollyball.jpg',
    },


    {
      'name':'Kho-Kho',
      'image':'assets/images/kho-kho.jpeg'
    },
    {
      'name':'Kabbadi',
      'image':'assets/images/kabbadi.jpeg'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sports'),
        leading: IconButton(
          icon: Icon(Icons.sports_kabaddi, color: Colors.black),
          onPressed: () {},
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sports.length,
          itemBuilder: (context, index) {
            String imagePath = sports[index]['image'] ?? 'assets/default_logo.png';
            String sportName = sports[index]['name'] ?? 'No Name';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    switch (sportName) {
                      case 'Basketball':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BasketballPage(
                              isLoggedIn: true,
                              isAdmin: isAdmin,
                            ),
                          ),
                        );
                        break;
                      case 'Cricket':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cricketscorepage(
                              isLoggedIn: true,
                              isAdmin: isAdmin,
                            ),
                          ),
                        );
                        break;
                      case 'Volleyball':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VolleyballScorePage(
                              isLoggedIn: true,
                              isAdmin: isAdmin,
                            ),
                          ),
                        );
                        break;
                      case 'Kho-Kho':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KhokhoPage(
                              isLoggedIn: true,
                              isAdmin: isAdmin,
                            ),
                          ),
                        );
                        break;
                      case 'Kabbadi':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Kabbadi(
                              isLoggedIn: true,
                              isAdmin: isAdmin,
                            ),
                          ),
                        );
                        break;
                      default:
                        print('$sportName is not available');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getSportColor(sportName).withOpacity(0.2),
                                _getSportColor(sportName).withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sportName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSportColor(sportName).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getSportStatus(sportName),
                                      style: TextStyle(
                                        color: _getSportColor(sportName),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        items: [
          BottomNavigationBarItem(
            icon:  InkWell(child: Icon(Icons.home),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LiveBuzzHomePage()),);},),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: InkWell(child: Icon(Icons.sports_baseball_rounded),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SportsPage()),);},),

            label: 'Sports',),
           BottomNavigationBarItem(
            icon: InkWell(child: Icon(Icons.notifications),
              onTap: (){
    Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeBoardScreen(isLoggedIn: true,isAdmin: isAdmin)),);},),


            label: 'Notice',
          ),

        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),

    );
  }
  Color _getSportColor(String sportName) {
    switch (sportName) {
      case 'Basketball':
        return const Color(0xFFFF6B6B);
      case 'Cricket':
        return const Color(0xFF4ECDC4);
      case 'Volleyball':
        return const Color(0xFFFFBE0B);
      case 'Kho-Kho':
        return const Color(0xFF845EC2);
      case 'Kabbadi':
        return const Color(0xFF00B8A9);
      default:
        return Colors.blue;
    }
  }

  String _getSportStatus(String sportName) {
    // You can customize this based on your needs
    return "Live Scores";
  }
}