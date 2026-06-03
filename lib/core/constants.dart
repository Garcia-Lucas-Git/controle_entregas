abstract final class OcrKeywords {
  // iFood confirmation trigger phrases (fuzzy matched)
  static const List<String> ifoodConfirmation = [
    'CONFIRMAR ENTREGA',
    'PLEASE CONFIRM DELIVERY',
    'CONFIRMACAO NECESSARIA',
    'CONFIRA A ENTREGA',
    'CONFIRMACAO DE ENTREGA',
  ];

  // Drinks
  static const List<String> drinks = [
    'COCA',
    'PEPSI',
    'SUCO',
    'REFRIGERANTE',
    'AGUA',
    'GUARANA',
    'CERVEJA',
    'ENERGETICO',
    'LIMONADA',
    'SPRITE',
    'FANTA',
  ];

  // Card machine
  static const List<String> cardMachine = [
    'MAQUINA',
    'CARTAO',
    'DEBITO',
    'CREDITO',
    'MAQUININHA',
  ];

  // Change
  static const List<String> change = ['TROCO', 'DINHEIRO'];

  // Receipt field anchors (keyword → next-line value)
  static const List<String> customerNameAnchors = [
    'CLIENTE',
    'NOME',
    'CONSUMIDOR',
  ];

  static const List<String> addressAnchors = [
    'ENDERECO',
    'END.',
    'RUA',
    'AV.',
    'AVENIDA',
    'ALAMEDA',
    'LOGRADOURO',
  ];

  static const List<String> neighborhoodAnchors = ['BAIRRO'];

  static const List<String> orderNumberAnchors = [
    'PEDIDO',
    'N. PEDIDO',
    'NUM. PEDIDO',
    'NUMERO DO PEDIDO',
    'ORDER',
  ];

  static const List<String> deliveryIdAnchors = [
    'IDENTIFICADOR',
    'IDENTIFICADOR DE ENTREGA',
    'DELIVERY ID',
  ];

  static const List<String> collectionCodeAnchors = [
    'CODIGO DE COLETA',
    'COD. COLETA',
    'COLETA',
    'PARTNER COLLECTION',
  ];
}
