// lib/api_constants.dart

class ApiConstants {
  // Use 'static const' para que possam ser acessadas diretamente pela classe
  // e sejam constantes em tempo de compilação.

  // URL base para o ambiente de desenvolvimento local (localhost)
  // static const String baseUrl = "http://localhost:8080";
  static const String baseUrl = "https://f073-2804-29b8-518f-8dbb-8cf0-a86d-8b2c-ffba.ngrok-free.app";


// Exemplo de como você poderia ter URLs para outros ambientes:
// static const String productionBaseUrl = "https://api.seuservidor.com";
// static const String stagingBaseUrl = "https://staging.seuservidor.com";

// Se você tiver URLs mais específicas que dependem da base, também pode defini-las aqui:
// static const String projetosEndpoint = "$baseUrl/projetos";
// static const String uploadImagemEndpoint = "$baseUrl/projetos/upload-imagem";
}