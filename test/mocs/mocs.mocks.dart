// Mocks generated by Mockito 5.4.3 from annotations
// in my_light_app/test/mocs/mocs.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:my_light_app/infra/storage/storage.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [Storage].
///
/// See the documentation for Mockito's code generation for more information.
class MockStorage extends _i1.Mock implements _i2.Storage {
  @override
  _i3.Future<void> save<T>({
    required _i2.StorageEnum? key,
    required T? value,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #save,
          [],
          {
            #key: key,
            #value: value,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<T?> get<T extends Object>(_i2.StorageEnum? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [key],
        ),
        returnValue: _i3.Future<T?>.value(),
        returnValueForMissingStub: _i3.Future<T?>.value(),
      ) as _i3.Future<T?>);

  @override
  _i3.Future<void> delete(_i2.StorageEnum? key) => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [key],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}