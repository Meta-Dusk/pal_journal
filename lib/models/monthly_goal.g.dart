// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthlyGoalCollection on Isar {
  IsarCollection<MonthlyGoal> get monthlyGoals => this.collection();
}

const MonthlyGoalSchema = CollectionSchema(
  name: r'MonthlyGoal',
  id: 8271761936404564288,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'month': PropertySchema(
      id: 1,
      name: r'month',
      type: IsarType.dateTime,
    ),
    r'syncedOffset': PropertySchema(
      id: 2,
      name: r'syncedOffset',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.byte,
      enumMap: _MonthlyGoaltypeEnumValueMap,
    )
  },
  estimateSize: _monthlyGoalEstimateSize,
  serialize: _monthlyGoalSerialize,
  deserialize: _monthlyGoalDeserialize,
  deserializeProp: _monthlyGoalDeserializeProp,
  idName: r'id',
  indexes: {
    r'month': IndexSchema(
      id: -3594385961712742690,
      name: r'month',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'month',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _monthlyGoalGetId,
  getLinks: _monthlyGoalGetLinks,
  attach: _monthlyGoalAttach,
  version: '3.1.0+1',
);

int _monthlyGoalEstimateSize(
  MonthlyGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _monthlyGoalSerialize(
  MonthlyGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.month);
  writer.writeDouble(offsets[2], object.syncedOffset);
  writer.writeByte(offsets[3], object.type.index);
}

MonthlyGoal _monthlyGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthlyGoal();
  object.amount = reader.readDouble(offsets[0]);
  object.id = id;
  object.month = reader.readDateTime(offsets[1]);
  object.syncedOffset = reader.readDouble(offsets[2]);
  object.type =
      _MonthlyGoaltypeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          GoalType.budget;
  return object;
}

P _monthlyGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (_MonthlyGoaltypeValueEnumMap[reader.readByteOrNull(offset)] ??
          GoalType.budget) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MonthlyGoaltypeEnumValueMap = {
  'budget': 0,
  'profit': 1,
};
const _MonthlyGoaltypeValueEnumMap = {
  0: GoalType.budget,
  1: GoalType.profit,
};

Id _monthlyGoalGetId(MonthlyGoal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthlyGoalGetLinks(MonthlyGoal object) {
  return [];
}

void _monthlyGoalAttach(
    IsarCollection<dynamic> col, Id id, MonthlyGoal object) {
  object.id = id;
}

extension MonthlyGoalByIndex on IsarCollection<MonthlyGoal> {
  Future<MonthlyGoal?> getByMonth(DateTime month) {
    return getByIndex(r'month', [month]);
  }

  MonthlyGoal? getByMonthSync(DateTime month) {
    return getByIndexSync(r'month', [month]);
  }

  Future<bool> deleteByMonth(DateTime month) {
    return deleteByIndex(r'month', [month]);
  }

  bool deleteByMonthSync(DateTime month) {
    return deleteByIndexSync(r'month', [month]);
  }

  Future<List<MonthlyGoal?>> getAllByMonth(List<DateTime> monthValues) {
    final values = monthValues.map((e) => [e]).toList();
    return getAllByIndex(r'month', values);
  }

  List<MonthlyGoal?> getAllByMonthSync(List<DateTime> monthValues) {
    final values = monthValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'month', values);
  }

  Future<int> deleteAllByMonth(List<DateTime> monthValues) {
    final values = monthValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'month', values);
  }

  int deleteAllByMonthSync(List<DateTime> monthValues) {
    final values = monthValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'month', values);
  }

  Future<Id> putByMonth(MonthlyGoal object) {
    return putByIndex(r'month', object);
  }

  Id putByMonthSync(MonthlyGoal object, {bool saveLinks = true}) {
    return putByIndexSync(r'month', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMonth(List<MonthlyGoal> objects) {
    return putAllByIndex(r'month', objects);
  }

  List<Id> putAllByMonthSync(List<MonthlyGoal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'month', objects, saveLinks: saveLinks);
  }
}

extension MonthlyGoalQueryWhereSort
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QWhere> {
  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhere> anyMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'month'),
      );
    });
  }
}

extension MonthlyGoalQueryWhere
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QWhereClause> {
  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> monthEqualTo(
      DateTime month) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'month',
        value: [month],
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> monthNotEqualTo(
      DateTime month) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [],
              upper: [month],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [month],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [month],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [],
              upper: [month],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> monthGreaterThan(
    DateTime month, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month',
        lower: [month],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> monthLessThan(
    DateTime month, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month',
        lower: [],
        upper: [month],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterWhereClause> monthBetween(
    DateTime lowerMonth,
    DateTime upperMonth, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month',
        lower: [lowerMonth],
        includeLower: includeLower,
        upper: [upperMonth],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MonthlyGoalQueryFilter
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QFilterCondition> {
  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> monthEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition>
      monthGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> monthLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> monthBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'month',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition>
      syncedOffsetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition>
      syncedOffsetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition>
      syncedOffsetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition>
      syncedOffsetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> typeEqualTo(
      GoalType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> typeGreaterThan(
    GoalType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> typeLessThan(
    GoalType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterFilterCondition> typeBetween(
    GoalType lower,
    GoalType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MonthlyGoalQueryObject
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QFilterCondition> {}

extension MonthlyGoalQueryLinks
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QFilterCondition> {}

extension MonthlyGoalQuerySortBy
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QSortBy> {
  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortBySyncedOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedOffset', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy>
      sortBySyncedOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedOffset', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MonthlyGoalQuerySortThenBy
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QSortThenBy> {
  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenBySyncedOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedOffset', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy>
      thenBySyncedOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedOffset', Sort.desc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MonthlyGoalQueryWhereDistinct
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QDistinct> {
  QueryBuilder<MonthlyGoal, MonthlyGoal, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QDistinct> distinctBySyncedOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedOffset');
    });
  }

  QueryBuilder<MonthlyGoal, MonthlyGoal, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension MonthlyGoalQueryProperty
    on QueryBuilder<MonthlyGoal, MonthlyGoal, QQueryProperty> {
  QueryBuilder<MonthlyGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthlyGoal, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<MonthlyGoal, DateTime, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<MonthlyGoal, double, QQueryOperations> syncedOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedOffset');
    });
  }

  QueryBuilder<MonthlyGoal, GoalType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
