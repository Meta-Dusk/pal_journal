import 'package:isar/isar.dart';

part 'pnl_entry.g.dart';

// run the build with:
// `dart run build_runner build -d`

@collection
class PnLEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late double amount;

  @Index()
  String? accountName;

  String? note;

  List<ExpenseItem>? breakdown;

  // --- FIREBASE SERIALIZATION ---

  /// Converts this Isar object into a JSON format Firestore can read. \
  /// Note: We don't include 'id' because Firestore will use the Date
  /// as the Document ID!
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'accountName': accountName,
      'note': note,
      'breakdown': breakdown?.map((item) => item.toMap()).toList(),
    };
  }

  /// Converts a Firestore JSON document back into an Isar object.
  static PnLEntry fromMap(Map<String, dynamic> map) {
    return PnLEntry()
      ..date = DateTime.parse(map['date'] as String)
      // We use 'num' here because Firestore sometimes returns whole doubles
      // (10.0) as ints (10).
      ..amount = (map['amount'] as num).toDouble()
      ..accountName = map['accountName'] as String?
      ..note = map['note'] as String?
      ..breakdown = (map['breakdown'] as List<dynamic>?)?.map((item) {
        return ExpenseItem.fromMap(Map<String, dynamic>.from(item as Map));
      }).toList();
  }
}

@embedded
class ExpenseItem {
  String? category;
  double? amount;

  // --- FIREBASE SERIALIZATION ---

  Map<String, dynamic> toMap() {
    return {'category': category, 'amount': amount};
  }

  static ExpenseItem fromMap(Map<String, dynamic> map) {
    return ExpenseItem()
      ..category = map['category'] as String?
      ..amount = (map['amount'] as num?)?.toDouble();
  }
}
