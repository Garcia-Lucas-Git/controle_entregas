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

  // Card machine — only explicit physical machine references.
  // CARTAO / DEBITO / CREDITO removed: on iFood receipts these appear as
  // pre-paid payment method labels and must NOT trigger needsCard.
  static const List<String> cardMachine = [
    'MAQUINA',
    'MAQUININHA',
  ];

  // iFood internal payment phrases that must NEVER trigger needsCard/needsChange.
  // These indicate the customer already paid on the platform.
  static const List<String> prepaidPaymentPhrases = [
    'PAGAMENTO JA REALIZADO',
    'PAGAMENTO REALIZADO',
    'PAGO ONLINE',
    'PAGO NO APP',
  ];

  // Change
  static const List<String> change = ['TROCO', 'DINHEIRO'];

  // Receipt field anchors (keyword → next-line value)
  static const List<String> customerNameAnchors = [
    'CLIENTE',
    'NOME',
    'CONSUMIDOR',
  ];

  // Names that look valid (letters + spaces, ≥2 words) but are NOT customer
  // names — reject these during positional extraction.
  static const List<String> customerNameBlocklist = [
    '0800',
    'PEDIDO',
    'PRIMEIRO PEDIDO',
    'ITENS DO PEDIDO',
    'SUBTOTAL',
    'TOTAL',
    'TAXA DE ENTREGA',
    'TAXA',
    'LOCALIZADOR',
    'TELEFONE',
    'BAIRRO',
    'COMP',
    'COMPLEMENTO',
    'PAGAMENTO',
    'FORMA DE PAGAMENTO',
    'VALOR',
    'CUPOM',
    'DESCONTO',
    'ENTREGA',
    'RETIRADA',
    'RESUMO DO PEDIDO',
    'ITENS',
    'OBSERVACAO',
  ];

  static const List<String> addressAnchors = [
    'ENDERECO',
    'ENDEREC0', // OCR confusion: digit 0 instead of letter O
    'ERNDERECO', // OCR noise: extra N inserted
    'ENDEREÇO', // accented Ç variant (ENDEREÇO)
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
    'LOCALIZADOR',
    'IDENTIFICADOR',
    'IDENTIFICADOR DE ENTREGA',
    'DELIVERY ID',
  ];

  static const List<String> collectionCodeAnchors = [
    'CODIGO DE COLETA PARCEIRA',
    'CODIGO DE COLETA',
    'COD. COLETA',
    'COLETA',
    'PARTNER COLLECTION',
  ];

  // Used only to stop multi-line collection; not extracted as field values.
  static const List<String> sectionBoundaryAnchors = ['COMP', 'CIDADE'];
}
