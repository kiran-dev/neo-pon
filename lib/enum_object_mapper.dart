
/// Utility class which defines methods for mapping all enum
/// values to another set of objects, doing some validation
/// on the input elements.
/// This class has some default validation rules which can
/// be overridden in child classes (see next file)
abstract class EnumObjectMapper<Enum, O> {
  // The enum values
  final List<Enum> values;
  // Map of Enum value -> Object representation
  final Map<Enum, O> objectMappings;

  EnumObjectMapper(this.values, {required this.objectMappings})
      : assert(values != null, 'Values must be set'),
        assert(values.isNotEmpty, 'Values cannot be empty'),
        assert(objectMappings != null, 'Mappings must be set'),
        assert(objectMappings.isNotEmpty, 'Mappings cannot be empty') {
    objectMappings.forEach((key, value) {
      assert(values.contains(key),
      'Mapping "$key" doesn\'t exist in input ${O.runtimeType} enum');
      if (invalidCondition(value)) {
        // log.w('ATTENTION - ${validationError(key, value)}');
        // Without Logger
        // debugPrint('ATTENTION - ${validationError(key, value)}');
      }
    });
  }

  // VALIDATION

  bool invalidCondition(O value) => value == null;

  String validationError(Enum key, O value) => 'Value of key: $key is not set ($value)!';

  // FUNCTIONS

  O getValue(Enum enumKey) => objectMappings[enumKey]!;

  Enum getKey(String value) => objectMappings.keys
      .firstWhere(
          (k) => objectMappings[k] == value,
          orElse: () => objectMappings.keys.first
      );
}


/// Utility class specialized into Enum  to [String] conversion, can be
/// used for converting an input enum key into a localized string for example.
/// You can see how the validation behavior is updated by overriding the
/// validation condition & the error message, in case it doesn't pass.
abstract class EnumStringMapper<Enum> extends EnumObjectMapper<Enum, String> {

  EnumStringMapper(
      List<Enum> values, { required Map<Enum, String> stringMappings }
  ) : super(values, objectMappings: stringMappings);

  // Enrich the validation rule
  @override
  bool invalidCondition(String value) => value.isEmpty;

  // Customize the validation error
  @override
  String validationError(Enum key, String value) => 'Label for key: $key is not set ($value)!';

}
