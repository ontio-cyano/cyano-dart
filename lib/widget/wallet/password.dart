String validatePassword(String pwd) {
  if (pwd == null || pwd.isEmpty) return 'Please enter password';
  if (pwd.length < 6) return 'Password is too short, min length is 6';
  if (pwd.length > 20) return 'Password is too long, max length is 20';
  return null;
}
