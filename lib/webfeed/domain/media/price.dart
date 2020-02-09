import 'package:xml/xml.dart';

class Price {
  final double price;
  final String type;
  final String info;
  final String currency;

  Price({
    this.price,
    this.type,
    this.info,
    this.currency,
  });

  factory Price.parse(XmlElement element) {
    return new Price(
      price: double.tryParse(element.getAttribute("price") ?? "0"),
      type: element.getAttribute("type"),
      info: element.getAttribute("info"),
      currency: element.getAttribute("currency"),
    );
  }
}
