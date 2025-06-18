import 'package:feffs/features/auth/data/movie_repository.dart';
import 'package:flutter/material.dart';
import '../entity/movie.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _movieRepository = MovieRepository();
  List<Movie>? movieList;

  MovieViewModel();

  Future<void> loadMovie() async {
    try {
      print("Chargement des films...");
      final moviesData = await _movieRepository.getMovies();
      if (moviesData.isNotEmpty) {
        movieList = moviesData;
      } else {
        movieList = [];
      }
      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement des films : $e");
    }
  }
}
