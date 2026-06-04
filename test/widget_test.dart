import 'package:controle_entregas/services/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OCR parser extracts existing anchored fields', () {
    final result = OcrService.parseRawText('''
CLIENTE: Cliente Teste
ENDERECO: Rua Exemplo, 123
BAIRRO: Centro
PEDIDO: 12345
IDENTIFICADOR: 1032 2187
CODIGO DE COLETA: 0905
TROCO R\$ 20,00
''');

    expect(result.customerName, 'Cliente Teste');
    expect(result.addressText, 'Rua Exemplo, 123');
    expect(result.neighborhood, 'Centro');
    expect(result.orderNumber, '12345');
    expect(result.deliveryIdentifier, '10322187');
    expect(result.partnerCollectionCode, isNull);
    expect(result.changeAmountCents, 2000);
    expect(result.hasRequiredFields, isTrue);
    expect(result.parserStatus, 'sucesso_completo');
  });

  test('OCR parser never stores four digit collection code as locator', () {
    final result = OcrService.parseRawText('''
CLIENTE: Cliente Teste
ENDERECO: Rua Exemplo, 123
BAIRRO: Centro
PEDIDO: 12345
CODIGO DE COLETA: 0905
''');

    expect(result.deliveryIdentifier, isNull);
    expect(result.partnerCollectionCode, isNull);
    expect(result.parserStatus, 'sucesso_parcial');
  });
}
