class ProductionItem {
  final int id;
  final String date;
  final String reProduction;
  final String bodyType1;
  final String bodyType2;
  final String khayam;
  final String negahi;
  final String tedad; // اضافه شده
  final String mojodiAnbar; // اضافه شده
  final String tedadDarArz; // اضافه شده
  final String tedadDarTul; // اضافه شده
  final String arz; // اضافه شده
  final String tul; // اضافه شده
  final String tedadPishin; // اضافه شده
  final String vaziat; // اضافه شده

  ProductionItem({
    required this.id,
    required this.date,
    required this.reProduction,
    required this.bodyType1,
    required this.bodyType2,
    required this.khayam,
    required this.negahi,
    required this.tedad,
    required this.mojodiAnbar,
    required this.tedadDarArz,
    required this.tedadDarTul,
    required this.arz,
    required this.tul,
    required this.tedadPishin,
    required this.vaziat,
  });
}

class SubItem {
  final String code;
  final String description;
  final int shomareHavMeghdar;
  final int tedad;
  final int meghdar;
  final String noeiat;
  final String kazineArzah;

  SubItem({
    required this.code,
    required this.description,
    required this.shomareHavMeghdar,
    required this.tedad,
    required this.meghdar,
    required this.noeiat,
    required this.kazineArzah,
  });
}