import 'package:isar/isar.dart';

//* This line is crucial! It tells build_runner where to generate the code.
//* You will see a red error here until you run the generator command below.
part 'pnl_entry.g.dart';

@collection
class PnLEntry {
  Id id = Isar.autoIncrement;

  //? We index the date because the calendar will constantly query:
  //? "Give me all entries between day X and day Y"
  @Index()
  late DateTime date;

  late double amount;

  //? Using an index here makes filtering by account extremely fast later.
  @Index()
  String? accountName;

  String? note;

  List<ExpenseItem>? breakdown;
}

@embedded
class ExpenseItem {
  String? category;
  double? amount;
}
