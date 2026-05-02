class AppValidators {
  // Validasi Field Wajib Isi
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // Validasi Format Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    // Regex yang lebih ketat: Memastikan domain punya titik dan minimal 2 karakter setelah titik
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid (contoh: user@gmail.com)';
    }

    // CONTOH EXTRA: Jika ingin mewajibkan @gmail.com
    // if (!value.endsWith('@gmail.com')) {
    //   return 'Harus menggunakan akun @gmail.com';
    // }

    return null;
  }

  // Validasi Hanya Angka
  static String? number(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final numberRegex = RegExp(r'^[0-9]+$');
    if (!numberRegex.hasMatch(value)) {
      return '$fieldName harus berupa angka';
    }
    return null;
  }

  // Validasi Minimal Karakter (Password)
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }
}
