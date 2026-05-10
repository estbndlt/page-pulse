class AppEnvironment {
  const AppEnvironment({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.starterPdfPath,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String starterPdfPath;

  static const fromDartDefines = AppEnvironment(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    starterPdfPath: String.fromEnvironment('STARTER_PDF_PATH'),
  );

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get hasStarterPdf => starterPdfPath.isNotEmpty;
}
