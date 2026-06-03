import 'package:controle_entregas/services/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OCR parser extracts existing anchored fields', () {
    final result = OcrService.parseRawText('''
CLIENTE: Cliente Teste
ENDERECO: Rua Exemplo, 123
BAIRRO: Centro
PEDIDO: 12345
COD: DEV1234
TROCO R\$ 20,00
''');

    expect(result.customerName, 'Cliente Teste');
    expect(result.addressText, 'Rua Exemplo, 123');
    expect(result.neighborhood, 'Centro');
    expect(result.orderNumber, '12345');
    expect(result.partnerCollectionCode, 'DEV1234');
    expect(result.changeAmountCents, 2000);
    expect(result.hasRequiredFields, isTrue);
  });
}
