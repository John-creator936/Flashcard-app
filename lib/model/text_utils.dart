/// Renvoie le nombre de cartes avec le bon accord (0 et 1 au singulier).
String cardCountLabel(int count) {
  return "$count ${(count > 1) ? 'cartes' : 'carte'}";
}
