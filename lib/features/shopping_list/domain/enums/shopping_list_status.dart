enum ShoppingListStatus {
  RASCUNHO,
  ATIVA,
  COMPARADA,
  FINALIZADA;

  static ShoppingListStatus fromString(String value) {
    return ShoppingListStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ShoppingListStatus.RASCUNHO,
    );
  }
}
