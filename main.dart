import 'dart:io';
import 'dart:js';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app1',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 20, 164, 189),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.fav.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return ListView.builder(
      itemCount: appState.fav.length,
      itemBuilder: (context, index) {
        var pair = appState.fav[index];
        return ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asCamelCase),
          trailing: InkWell(
            onTap: () {
              appState.fav.remove(pair);
              appState.notifyListeners();
            },
            child: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}

class UserProfile {
  String username;
  String email;
  String city;
  String roll;
  File? profilePicture;

  UserProfile(
      {required this.username,
      required this.email,
      required this.city,
      required this.roll,
      this.profilePicture});
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${appState.userProfile.username}!',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 10,
          ),
          CircleAvatar(
            radius: 60,
            backgroundImage: appState.userProfile.profilePicture != null
                ? FileImage(appState.userProfile.profilePicture!)
                    as ImageProvider<Object>?
                : AssetImage('assets/panda.jpeg'),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Row(
              children: [
                Icon(Icons.email),
                SizedBox(
                  width: 4,
                ),
                Text('Email-ID: ${appState.userProfile.email}'),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 20,
            ),
          ),
          Center(
            child: Row(
              children: [
                Icon(Icons.location_on_sharp),
                SizedBox(
                  width: 4,
                ),
                Text('City: ${appState.userProfile.city}'),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 20,
            ),
          ),
          Center(
            child: Row(
              children: [
                Icon(Icons.bookmark),
                Text('Roll Number: ${appState.userProfile.roll}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePicture(
      BuildContext context, MyAppState appState) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        appState.userProfile.profilePicture = File(pickedFile.path);
      });
      appState.notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  var isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = HomePage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration:
                Duration(milliseconds: 300), // Adjust the duration as needed
            width: isExpanded ? 200 : 56,
            child: SafeArea(
              child: NavigationRail(
                extended: isExpanded,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Icon(isExpanded ? Icons.menu_open : Icons.menu),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var _userProfile = UserProfile(
      username: 'Sneha Barman',
      email: 'snehab22@iitk.ac.in',
      city: 'Kanpur',
      roll: '221068');
  UserProfile get userProfile => _userProfile;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var fav = <WordPair>[];

  void toggleFavorite() {
    if (fav.contains(current)) {
      fav.remove(current);
    } else {
      fav.add(current);
    }
    notifyListeners();
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.fav.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final bodyText = theme.textTheme.bodyMedium!.copyWith(
      fontSize: 2,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(pair.asCamelCase, style: style),
      ),
    );
  }
}
