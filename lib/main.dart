
import 'package:flutter/material.dart';// Ensure the correct import
import 'package:livebuzz/Games/BasketballPage.dart';
import 'package:livebuzz/Games/CricketScorePage.dart';
import 'package:livebuzz/Games/Kabbadi.dart';
import 'package:livebuzz/Games/khokho.dart';
import 'package:livebuzz/LoginPage.dart';
import 'package:livebuzz/Games/VolleyballScorePage.dart';
import 'package:livebuzz/sports.dart';

import 'Games/noticeboard.dart';
import 'global.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase

  runApp(LiveBuzzApp());
}
class LiveBuzzApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SPORION',
      home: SplashScreen(), // Set SplashScreen as the initial screen.
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Navigate to LiveBuzzHomePage after 3 seconds.
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LiveBuzzHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurple, // Background color for splash screen.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or placeholder icon
            Image.asset("assets/images/logoSporian.png"),
            SizedBox(height: 20),
            // App name
            SizedBox(height: 20),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveBuzzHomePage extends StatefulWidget {
  @override
  _LiveBuzzHomePageState createState() => _LiveBuzzHomePageState();
}

class _LiveBuzzHomePageState extends State<LiveBuzzHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Sports  Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Table Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Statistics Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.sports_kabaddi, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [//SizedBox(width: 50,),
            // LiveBuzz Logo (Placeholder Text)
            Text(
              'SPORION',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          if (!isLoggedIn) // Only show if user is NOT logged in
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 10,),
                  Text(
                    'Log In',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            Container(
              width: double.infinity,
              height: 300, // Reduced height for better proportion
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/logoSporian.png"),
                  scale: 1,
                  fit: BoxFit.contain, // Image will scale to fit inside without cropping
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Sports Matches",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Sports Cards Container
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSportCard(
                    context: context,
                    title: "CRICKET",
                    icon: Icons.sports_cricket,
                    image: "assets/images/cricket-bat-ball-foreground-pitch.jpg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cricketscorepage(
                          isLoggedIn: true,
                          isAdmin: isAdmin,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSportCard(
                    context: context,
                    title: "BASKETBALL",
                    icon: Icons.sports_basketball_sharp,
                    image: "assets/images/basketball-hoop-with-blue-sky.jpg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BasketballPage(
                          isLoggedIn: true,
                          isAdmin: isAdmin,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSportCard(
                    context: context,
                    title: "KHO-KHO",
                    icon: Icons.sports_martial_arts,
                    image: "assets/images/kho-kho.jpeg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KhokhoPage(
                          isLoggedIn: true,
                          isAdmin: isAdmin,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSportCard(
                    context: context,
                    title: "VOLLEYBALL",
                    icon: Icons.sports_volleyball_sharp,
                    image: "assets/images/vollyball.jpg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VolleyballScorePage(
                          isLoggedIn: true,
                          isAdmin: isAdmin,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSportCard(
                    context: context,
                    title: "KABADDI",
                    icon: Icons.sports_kabaddi,
                    image: "assets/images/kabbadi.jpeg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Kabbadi(
                          isLoggedIn: true,
                          isAdmin: isAdmin,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ) ,

      //_pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeBoardScreen(isLoggedIn: true,isAdmin:isAdmin)));

              },
            ),

            label: 'Notice',
          ),
          /* BottomNavigationBarItem(
            icon: InkWell(child: Icon(Icons.view_comfortable),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(isLoggedIn: true,isAdmin: isAdmin)),);

              },

            ),
            label: 'Result',
          ),*/
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),


    );
  }
  Widget _buildSportCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

