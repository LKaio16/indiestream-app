// lib/edicao-perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Import for image_picker
import 'dart:io'; // Import for File
import 'package:cached_network_image/cached_network_image.dart'; // For displaying network images

import 'api_constants.dart';
import 'projeto_detalhes_screen.dart'; // Para a classe Usuario

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario; // O objeto Usuario do usuário logado
  final Map<String, dynamic> userData; // Dados brutos do perfil

  const EditarPerfilScreen({
    super.key,
    required this.usuario,
    required this.userData,
  });

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  // Controladores para os campos de texto
  late TextEditingController _nomeController;
  late TextEditingController _profissaoController;
  late TextEditingController _sobreMimController;

  // New: State variable for the selected image file
  XFile? _selectedImage;
  // New: ImagePicker instance
  final ImagePicker _picker = ImagePicker();
  // New: Current image URL from user data
  late String _currentImageUrl;

  bool _isLoading = false;
  String _errorMessage = '';

  // Define a constant for the ngrok header
  static const Map<String, String> _ngrokHeaders = {
    'ngrok-skip-browser-warning': 'skip-browser-warning',
  };

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _profissaoController = TextEditingController(
        text: widget.usuario.funcao); // Assuming 'funcao' is the profession
    _sobreMimController = TextEditingController(
        text: widget.userData['sobreMim']); // Data from the map

    // Initialize current image URL
    _currentImageUrl = widget.usuario.imagemUrl ?? "https://i.ibb.co/PG4G5q3/Ellipse-1.png"; // Fallback image
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _profissaoController.dispose();
    _sobreMimController.dispose();
    super.dispose();
  }

  // New: Method to pick an image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _errorMessage = ''; // Clear any previous image selection error
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String? newImageUrl = _currentImageUrl; // Start with the existing URL

    // --- Start Image Upload Logic (similar to CriarProjetoScreen) ---
    if (_selectedImage != null) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${ApiConstants.baseUrl}/user/upload-imagem/${widget.usuario.id}"), // User image upload endpoint
        );
        request.headers.addAll(_ngrokHeaders); // Add ngrok header for upload

        request.files.add(await http.MultipartFile.fromPath(
          'file', // Field name expected by backend (e.g., @RequestParam("file") MultipartFile file)
          _selectedImage!.path,
          filename: _selectedImage!.name,
        ));

        final responseUpload = await request.send();
        if (responseUpload.statusCode == 200) {
          final responseData = await responseUpload.stream.bytesToString();
          final Map<String, dynamic> uploadResult = json.decode(responseData);
          newImageUrl = uploadResult['url']; // Get the URL from the backend's JSON response
        } else {
          String uploadErrorMessage = "Erro ao fazer upload da imagem de perfil";
          try {
            final errorData = json.decode(await responseUpload.stream.bytesToString());
            uploadErrorMessage = errorData['message'] ?? uploadErrorMessage;
          } catch (e) {
            print("Erro ao parsear resposta de erro do upload: $e");
          }
          setState(() {
            _errorMessage = uploadErrorMessage;
          });
          _isLoading = false;
          return; // Stop saving if image upload fails
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erro ao fazer upload da imagem: ${e.toString()}';
        });
        _isLoading = false;
        return; // Stop saving if image upload fails
      }
    }
    // --- End Image Upload Logic ---

    try {
      final updatedData = {
        "nome": _nomeController.text,
        // Ensure this matches your DTO field for profession name
        "profissaoNome": _profissaoController.text,
        "sobreMim": _sobreMimController.text,
        "imagemUrl": newImageUrl, // Include the new or existing image URL
        // ... other fields you allow editing
      };

      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/user/${widget.usuario.id}"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'skip-browser-warning',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Success: Return 'true' to the previous screen to indicate update
        Navigator.pop(context, true);
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _errorMessage = errorBody['message'] ?? 'Erro ao salvar alterações.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
        const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            // New: Image selection field
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[700],
                    // Display selected image if available, else current network image, else placeholder
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path)) as ImageProvider
                        : (_currentImageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(_currentImageUrl)
                        : null),
                    child: (_selectedImage == null && _currentImageUrl.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.white54)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 20,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // End: New Image selection field

            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _profissaoController,
              decoration: InputDecoration(
                labelText: 'Profissão',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sobreMimController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Sobre Mim',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding:
                EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}