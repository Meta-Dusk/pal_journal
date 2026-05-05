// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantified_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuantifiedGoalCollection on Isar {
  IsarCollection<QuantifiedGoal> get quantifiedGoals => this.collection();
}

const QuantifiedGoalSchema = CollectionSchema(
  name: r'QuantifiedGoal',
  id: -5496306468838842361,
  properties: {
    r'currentValue': PropertySchema(
      id: 0,
      name: r'currentValue',
      type: IsarType.double,
    ),
    r'deadline': PropertySchema(
      id: 1,
      name: r'deadline',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(
      id: 3,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'progress': PropertySchema(
      id: 4,
      name: r'progress',
      type: IsarType.double,
    ),
    r'targetValue': PropertySchema(
      id: 5,
      name: r'targetValue',
      type: IsarType.double,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    ),
    r'unit': PropertySchema(
      id: 7,
      name: r'unit',
      type: IsarType.string,
    ),
    r'valueType': PropertySchema(
      id: 8,
      name: r'valueType',
      type: IsarType.byte,
      enumMap: _QuantifiedGoalvalueTypeEnumValueMap,
    )
  },
  estimateSize: _quantifiedGoalEstimateSize,
  serialize: _quantifiedGoalSerialize,
  deserialize: _quantifiedGoalDeserialize,
  deserializeProp: _quantifiedGoalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _quantifiedGoalGetId,
  getLinks: _quantifiedGoalGetLinks,
  attach: _quantifiedGoalAttach,
  version: '3.1.0+1',
);

int _quantifiedGoalEstimateSize(
  QuantifiedGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _quantifiedGoalSerialize(
  QuantifiedGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.currentValue);
  writer.writeDateTime(offsets[1], object.deadline);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeBool(offsets[3], object.isPinned);
  writer.writeDouble(offsets[4], object.progress);
  writer.writeDouble(offsets[5], object.targetValue);
  writer.writeString(offsets[6], object.title);
  writer.writeString(offsets[7], object.unit);
  writer.writeByte(offsets[8], object.valueType.index);
}

QuantifiedGoal _quantifiedGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuantifiedGoal();
  object.currentValue = reader.readDouble(offsets[0]);
  object.deadline = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[2]);
  object.isPinned = reader.readBool(offsets[3]);
  object.targetValue = reader.readDouble(offsets[5]);
  object.title = reader.readString(offsets[6]);
  object.unit = reader.readString(offsets[7]);
  object.valueType =
      _QuantifiedGoalvalueTypeValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          GoalValueType.integer;
  return object;
}

P _quantifiedGoalDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_QuantifiedGoalvalueTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          GoalValueType.integer) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _QuantifiedGoalvalueTypeEnumValueMap = {
  'integer': 0,
  'decimal': 1,
};
const _QuantifiedGoalvalueTypeValueEnumMap = {
  0: GoalValueType.integer,
  1: GoalValueType.decimal,
};

Id _quantifiedGoalGetId(QuantifiedGoal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _quantifiedGoalGetLinks(QuantifiedGoal object) {
  return [];
}

void _quantifiedGoalAttach(
    IsarCollection<dynamic> col, Id id, QuantifiedGoal object) {
  object.id = id;
}

extension QuantifiedGoalQueryWhereSort
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QWhere> {
  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuantifiedGoalQueryWhere
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QWhereClause> {
  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterWhereClause> idBetween(
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
}

extension QuantifiedGoalQueryFilter
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QFilterCondition> {
  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      currentValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      currentValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      currentValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      currentValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      deadlineEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      deadlineGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      deadlineLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      deadlineBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deadline',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      isPinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPinned',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      progressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      targetValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      targetValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      targetValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      targetValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      valueTypeEqualTo(GoalValueType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valueType',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      valueTypeGreaterThan(
    GoalValueType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valueType',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      valueTypeLessThan(
    GoalValueType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valueType',
        value: value,
      ));
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterFilterCondition>
      valueTypeBetween(
    GoalValueType lower,
    GoalValueType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valueType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QuantifiedGoalQueryObject
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QFilterCondition> {}

extension QuantifiedGoalQueryLinks
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QFilterCondition> {}

extension QuantifiedGoalQuerySortBy
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QSortBy> {
  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByTargetValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByTargetValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> sortByValueType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueType', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      sortByValueTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueType', Sort.desc);
    });
  }
}

extension QuantifiedGoalQuerySortThenBy
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QSortThenBy> {
  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByTargetValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByTargetValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy> thenByValueType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueType', Sort.asc);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QAfterSortBy>
      thenByValueTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueType', Sort.desc);
    });
  }
}

extension QuantifiedGoalQueryWhereDistinct
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct> {
  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct>
      distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct> distinctByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deadline');
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct> distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct>
      distinctByTargetValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetValue');
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct> distinctByUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuantifiedGoal, QuantifiedGoal, QDistinct>
      distinctByValueType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valueType');
    });
  }
}

extension QuantifiedGoalQueryProperty
    on QueryBuilder<QuantifiedGoal, QuantifiedGoal, QQueryProperty> {
  QueryBuilder<QuantifiedGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuantifiedGoal, double, QQueryOperations>
      currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<QuantifiedGoal, DateTime, QQueryOperations> deadlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deadline');
    });
  }

  QueryBuilder<QuantifiedGoal, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<QuantifiedGoal, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<QuantifiedGoal, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<QuantifiedGoal, double, QQueryOperations> targetValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetValue');
    });
  }

  QueryBuilder<QuantifiedGoal, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<QuantifiedGoal, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<QuantifiedGoal, GoalValueType, QQueryOperations>
      valueTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valueType');
    });
  }
}
