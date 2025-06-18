import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../domain/auth_viewmodel.dart';
import 'package:feffs/features/auth/ui/settings_screen.dart';

class AuthScreen extends StatefulWidget {
  final Function resetNavigationIndex;

  const AuthScreen({super.key, required this.resetNavigationIndex});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (authViewModel.currentUser == null) _buildTabSelector(),
            const SizedBox(height: 20),
            if (authViewModel.currentUser == null)
              isLoginMode
                  ? _buildLoginForm(authViewModel)
                  : _buildRegisterForm(authViewModel)
            else
              _buildUserInfo(authViewModel),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Profil"),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Column(
      children: [
        Image.asset(
          'assets/img/logo/FEFFS_logo.png', 
          height: 100, 
          fit: BoxFit
              .cover,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTab(
              "Connexion",
              isSelected: isLoginMode,
              onTap: () => setState(() => isLoginMode = true),
            ),
            const SizedBox(width: 20),
            _buildTab(
              "Inscription",
              isSelected: !isLoginMode,
              onTap: () => setState(() => isLoginMode = false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel authViewModel) {
    return Column(
      children: [
        _buildInputField(emailController, 'Email'),
        const SizedBox(height: 15),
        _buildInputField(passwordController, 'Mot de passe', obscureText: true),
        const SizedBox(height: 20),
        _buildSubmitButton(
          () async {
            await authViewModel.login(
              emailController.text,
              passwordController.text,
            );
          },
          'Se connecter',
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthViewModel authViewModel) {
    return Column(
      children: [
        _buildInputField(firstNameController, 'Prénom'),
        const SizedBox(height: 15),
        _buildInputField(lastNameController, 'Nom'),
        const SizedBox(height: 15),
        _buildInputField(emailController, 'Email'),
        const SizedBox(height: 15),
        _buildInputField(passwordController, 'Mot de passe', obscureText: true),
        const SizedBox(height: 20),
        _buildSubmitButton(
          () async {
            await authViewModel.register(
              emailController.text,
              passwordController.text,
              firstNameController.text,
              lastNameController.text,
            );
            setState(() => isLoginMode = true);
          },
          'S\'inscrire',
        ),
      ],
    );
  }

  Widget _buildUserInfo(AuthViewModel authViewModel) {
    return Column(
      children: [
        const Text(
          "Informations du compte",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildProfileCard(authViewModel),
        _buildSubmitButton(
          () {
            authViewModel.logout();
            widget.resetNavigationIndex();
          },
          'Déconnexion',
        ),
      ],
    );
  }

  Widget _buildProfileCard(AuthViewModel authViewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              authViewModel.currentUser?.name.isNotEmpty ?? false
                  ? authViewModel.currentUser!.name[0].toUpperCase()
                  : 'N/A', // Affiche "N/A" si aucune lettre n'est disponible
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
                "Nom d'utilisateur : ${authViewModel.currentUser?.name ?? ''}"),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text("Email : ${authViewModel.currentUser?.email ?? ''}"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed, String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(text),
      ),
    );
  }
}
