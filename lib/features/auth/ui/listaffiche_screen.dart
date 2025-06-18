import 'package:feffs/features/auth/entity/movie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/auth_viewmodel.dart';
import '../domain/movie_viewmodel.dart';
import '../../../core/services/appwrite_services.dart';

class MovieScheduleScreen extends StatefulWidget {
  @override
  _MovieScheduleScreenState createState() => _MovieScheduleScreenState();
}

class _MovieScheduleScreenState extends State<MovieScheduleScreen> {
  final List<Movie> schedule = []; // Liste des films ajoutés au programme

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _loadUserSchedule();
  }

  void _loadMovies() async {
    final movieViewModel = Provider.of<MovieViewModel>(context, listen: false);
    await movieViewModel.loadMovie(); // Charge les films via le ViewModel
  }

  void _loadUserSchedule() async {
    final userSchedule = await AppwriteService.getUserSchedule();
    setState(() {
      schedule.clear();
      schedule.addAll(userSchedule.map((doc) {
        return Movie(
          title: doc['movieTitle'],
          description: doc['movieDescription'],
          imageUrl: doc['movieImage'] ?? 'assets/img/placeholder.png',
          date: doc['movieDate'], 
          id: doc.hashCode.toString(),
        );
      }).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final movieViewModel = Provider.of<MovieViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30.0, right: 60.0),
            child: Text(
              'Les prochains événements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Liste des films
          Expanded(
            child: movieViewModel.movieList == null
                ? const Center(child: CircularProgressIndicator()) // Loader en cas de chargement
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: movieViewModel.movieList!.length,
                    itemBuilder: (context, index) {
                      final movie = movieViewModel.movieList![index];
                      return Card(
                        color: const Color.fromARGB(255, 52, 52, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    movie.imageUrl,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/img/placeholder.png',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    color: Colors.black.withOpacity(0.6),
                                    child: Text(
                                      movie.date,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListTile(
                              title: Text(
                                movie.title,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                movie.description,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  if (authViewModel.currentUser != null) {
                                    _addToSchedule(movie);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Vous devez être connecté pour ajouter à votre programme.',
                                        ),
                                        backgroundColor: Color(0xFFD35446),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.bookmark_border,
                                  color: Color(0xFFD35446),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const Divider(color: Colors.grey),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Votre programme de visionnage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          schedule.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: schedule.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            schedule[index].title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            schedule[index].description,
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromSchedule(index),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Votre programme est vide. Ajoutez des films pour commencer !',
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
        ],
      ),
    );
  }

  void _addToSchedule(Movie movie) {
    bool hasDateConflict = schedule.any((scheduledMovie) => scheduledMovie.date == movie.date);

    if (hasDateConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Avertissement : Un film est déjà prévu à cette date (${movie.date}).',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      setState(() {
        if (!schedule.contains(movie)) {
          schedule.add(movie);
          AppwriteService.addProgramToSchedule(movie.title, movie.description, movie.date);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} ajouté à votre programme !')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} est déjà dans votre programme !')),
          );
        }
      });
    }
  }

  void _removeFromSchedule(int index) {
    setState(() {
      final removedMovie = schedule.removeAt(index);
      AppwriteService.removeProgramFromSchedule(removedMovie.title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${removedMovie.title} retiré de votre programme.')),
      );
    });
  }
}
