import 'package:flutter/material.dart';

class TValidator {
  static String? validateConfirmPassword(
    String? value,
    TextEditingController passwordController,
  ) {
    if (value != passwordController.text) {
      return 'Şifreler eşleşmiyor.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta alanı zorunludur.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı zorunludur.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermelidir.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Şifre en az bir özel karakter içermelidir.';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası zorunludur.';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{11}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Telefon numarası 11 rakamdan oluşmalıdır.';
    }

    return null;
  }

  // Add more custom validators as needed for your specific requirements.
}
