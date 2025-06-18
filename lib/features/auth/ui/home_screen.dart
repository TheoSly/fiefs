import 'package:feffs/features/auth/domain/auth_viewmodel.dart';
import 'package:feffs/features/auth/domain/movie_viewmodel.dart';
import 'package:feffs/features/auth/entity/movie.dart';
import 'package:feffs/features/auth/ui/movie_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadMoviesFuture;

  @override
  void initState() {
    super.initState();
    final movieViewModel = Provider.of<MovieViewModel>(context, listen: false);
    _loadMoviesFuture = movieViewModel.loadMovie(); // Initialisation du Future
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndShowPopup();
    });
  }

Future<void> _checkAndShowPopup() async {
  final prefs = await SharedPreferences.getInstance();
  final hasShownPopup = prefs.getBool('hasShownPopup') ?? false;
  print('Has shown popup: $hasShownPopup');  // Debugging

   //await prefs.remove('hasShownPopup');

  if (!hasShownPopup) {
    if (mounted) {
      _showActivityPopup();
    }
    await prefs.setBool('hasShownPopup', true);
  }
}

void _showActivityPopup() {
  showDialog(
    context: context,
    barrierDismissible: true, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Activités a venir"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Loup-Garou animé par Philibert",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Ven. 20.09 de 16h à 18h | Sam. 21.09 de 14h à 17h | Mar. 24.09 et Jeu. 26.09 de 15h à 17h"),
              SizedBox(height: 10),
              Text(
                "Entrée gratuite",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Text(
                "L’équipe de la boutique Philibert animera quatre séances au festival, avec des jeux faciles à prendre en main et une sélection fantastique. Ne manquez pas les séances de loup-garou chaque heure, avec inscriptions recommandées.",
              ),
              SizedBox(height: 20),
              Text(
                "Atelier de maquillage \"Drag creature\"",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Sam. 21.09 de 14h à 18h"),
              SizedBox(height: 10),
              Text(
                "Entrée gratuite",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Text(
                "Léah Fontaine propose un atelier de 4 heures sur le maquillage des drag creatures, abordant outils, matières, codes de genre et techniques. L’atelier inclut des échanges sur le processus créatif et les pratiques drag. Idéal pour débutants ou pour perfectionner son maquillage drag.",
              ),
              SizedBox(height: 10),
              Text(
                "Alors, tu es de la partie ? Inscris-toi dès maintenant en remplissant le formulaire !",
              ),
              SizedBox(height: 20),
              Text(
                "Atelier : confection de masques",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Mar. 24.09 de 14h à 17h"),
              SizedBox(height: 10),
              Text(
                "Gratuit | tente “Event”",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Text(
                "Transformez-vous pour cet automne ! Plongez dans un atelier créatif de confection de masques en papier découpé, guidé par Marion Even, factrice de masques de scène. En combinant des formes animalières et fantastiques, créez un masque unique. Que vous souhaitiez incarner une créature mystique ou simplement masquer votre identité, cet atelier est l’occasion idéale pour explorer votre créativité et repartir avec une pièce originale !",
              ),
              SizedBox(height: 10),
              Text(
                "Atelier sur inscription – Jauge maximale de 8 personnes.",
              ),
              SizedBox(height: 20),
              Text(
                "Concert : Astromôme",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Mer. 25.09 de 11h à 11h45"),
              SizedBox(height: 10),
              Text(
                "Gratuit | tente “Buvette”",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Text(
                "Venu tout droit d’une autre galaxie, Astromôme nous emporte avec douceur à bord de son vaisseau, et nous fait voyager dans un univers cosmique où se mélange électronique, instruments terrestres et jouets bidouillés. Petits et grands se laissent alors glisser dans un moment de tendresse sonore à travers les étoiles. Une occasion de se blottir en famille, de se laisser bercer par les mélodies astrales et d’explorer le cosmos juste en fermant les yeux.",
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Fermer'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final movieViewModel = Provider.of<MovieViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: FutureBuilder(
        future: _loadMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          } else {
            final movies = movieViewModel.movieList;

            if (movies == null || movies.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun film disponible.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/img/heaven.png',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "HEAVEN IS NOBODY'S",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Une femme traumatisée, recluse chez elle, envoie son fils chercher des médicaments en ville malgré un couvre-feu lié à une étrange épidémie.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 20,
                        child: Text(
                          authViewModel.currentUser == null
                              ? 'Bonjour, invité!'
                              : 'Bonjour, ${authViewModel.currentUser!.name}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "À l'affiche",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(movie: movie);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                movie.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    movie.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    movie.date,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 211, 84, 70),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}