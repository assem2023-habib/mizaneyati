import 'package:flutter_test/flutter_test.dart';
import 'package:mizaneyati/core/utils/result.dart';
import 'package:mizaneyati/core/errors/failures.dart';
import 'package:mizaneyati/domain/value_objects/money.dart';
import 'package:mizaneyati/domain/value_objects/account_name.dart';
import 'package:mizaneyati/domain/value_objects/category_name.dart';
import 'package:mizaneyati/domain/value_objects/note_value.dart';
import 'package:mizaneyati/domain/value_objects/date_value.dart';
import 'package:mizaneyati/domain/value_objects/color_value.dart';
import 'package:mizaneyati/domain/value_objects/icon_value.dart';

void main() {
  group('Money Value Object', () {
    test('should create valid money with positive amount', () {
      final result = Money.create(1000);

      expect(result, isA<Success<Money>>());
      final money = (result as Success<Money>).value;
      expect(money.toMinor(), 1000);
    });

    test('should create valid money with zero amount', () {
      final result = Money.create(0);

      expect(result, isA<Success<Money>>());
      final money = (result as Success<Money>).value;
      expect(money.toMinor(), 0);
    });

    test('should convert to major units correctly', () {
      final result = Money.create(15000);
      final money = (result as Success<Money>).value;

      expect(money.toMajor(100), 150.0);
      expect(money.toMajor(1000), 15.0);
    });

    test('should fail for negative amount', () {
      final result = Money.create(-100);

      expect(result, isA<Fail<Money>>());
      final failure = (result as Fail<Money>).failure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'money_negative');
    });

    test('should support equality', () {
      final money1 = Money.create(1000);
      final money2 = Money.create(1000);
      final money3 = Money.create(2000);

      expect(
        (money1 as Success<Money>).value,
        (money2 as Success<Money>).value,
      );
      expect((money1).value == (money3 as Success<Money>).value, false);
    });

    test('should support copyWith', () {
      final money = (Money.create(1000) as Success<Money>).value;
      final copied = money.copyWith(minorUnits: 2000);

      expect(copied.toMinor(), 2000);
      expect(money.toMinor(), 1000); // original unchanged
    });
  });

  group('AccountName Value Object', () {
    test('should create valid account name', () {
      final result = AccountName.create('My Wallet');

      expect(result, isA<Success<AccountName>>());
      expect((result as Success<AccountName>).value.value, 'My Wallet');
    });

    test('should trim whitespace', () {
      final result = AccountName.create('  Savings  ');

      expect(result, isA<Success<AccountName>>());
      expect((result as Success<AccountName>).value.value, 'Savings');
    });

    test('should accept minimum length name', () {
      final result = AccountName.create('A');

      expect(result, isA<Success<AccountName>>());
      expect((result as Success<AccountName>).value.value, 'A');
    });

    test('should accept maximum length name', () {
      final name = 'a' * 50;
      final result = AccountName.create(name);

      expect(result, isA<Success<AccountName>>());
      expect((result as Success<AccountName>).value.value, name);
    });

    test('should fail for empty name', () {
      final result = AccountName.create('');

      expect(result, isA<Fail<AccountName>>());
      expect((result as Fail<AccountName>).failure.code, 'account_name_short');
    });

    test('should fail for whitespace-only name', () {
      final result = AccountName.create('   ');

      expect(result, isA<Fail<AccountName>>());
      expect((result as Fail<AccountName>).failure.code, 'account_name_short');
    });

    test('should fail for too long name', () {
      final longName = 'a' * 51;
      final result = AccountName.create(longName);

      expect(result, isA<Fail<AccountName>>());
      expect((result as Fail<AccountName>).failure.code, 'account_name_long');
    });

    test('should support equality', () {
      final name1 = AccountName.create('Wallet');
      final name2 = AccountName.create('Wallet');
      final name3 = AccountName.create('Bank');

      expect(
        (name1 as Success<AccountName>).value,
        (name2 as Success<AccountName>).value,
      );
      expect((name1).value == (name3 as Success<AccountName>).value, false);
    });
  });

  group('CategoryName Value Object', () {
    test('should create valid category name', () {
      final result = CategoryName.create('Food & Dining');

      expect(result, isA<Success<CategoryName>>());
      expect((result as Success<CategoryName>).value.value, 'Food & Dining');
    });

    test('should trim whitespace', () {
      final result = CategoryName.create('  Transport  ');

      expect(result, isA<Success<CategoryName>>());
      expect((result as Success<CategoryName>).value.value, 'Transport');
    });

    test('should fail for empty name', () {
      final result = CategoryName.create('');

      expect(result, isA<Fail<CategoryName>>());
      expect(
        (result as Fail<CategoryName>).failure.code,
        'category_name_short',
      );
    });

    test('should fail for too long name', () {
      final longName = 'a' * 51;
      final result = CategoryName.create(longName);

      expect(result, isA<Fail<CategoryName>>());
      expect((result as Fail<CategoryName>).failure.code, 'category_name_long');
    });
  });

  group('NoteValue Value Object', () {
    test('should create valid note', () {
      final result = NoteValue.create('Payment for groceries');

      expect(result, isA<Success<NoteValue>>());
      expect(
        (result as Success<NoteValue>).value.value,
        'Payment for groceries',
      );
    });

    test('should accept null value', () {
      final result = NoteValue.create(null);

      expect(result, isA<Success<NoteValue>>());
      expect((result as Success<NoteValue>).value.value, null);
    });

    test('should convert empty string to null', () {
      final result = NoteValue.create('   ');

      expect(result, isA<Success<NoteValue>>());
      expect((result as Success<NoteValue>).value.value, null);
    });

    test('should trim whitespace', () {
      final result = NoteValue.create('  Some note  ');

      expect(result, isA<Success<NoteValue>>());
      expect((result as Success<NoteValue>).value.value, 'Some note');
    });

    test('should accept maximum length note', () {
      final note = 'a' * 200;
      final result = NoteValue.create(note);

      expect(result, isA<Success<NoteValue>>());
      expect((result as Success<NoteValue>).value.value, note);
    });

    test('should fail for too long note', () {
      final longNote = 'a' * 201;
      final result = NoteValue.create(longNote);

      expect(result, isA<Fail<NoteValue>>());
      expect((result as Fail<NoteValue>).failure.code, 'note_too_long');
    });

    test('should support equality', () {
      final note1 = NoteValue.create('Test');
      final note2 = NoteValue.create('Test');
      final note3 = NoteValue.create('Other');
      final note4 = NoteValue.create(null);

      expect(
        (note1 as Success<NoteValue>).value,
        (note2 as Success<NoteValue>).value,
      );
      expect((note1).value == (note3 as Success<NoteValue>).value, false);
      expect((note1).value == (note4 as Success<NoteValue>).value, false);
    });
  });

  group('DateValue Value Object', () {
    test('should create valid date for current time', () {
      final now = DateTime.now();
      final result = DateValue.create(now);

      expect(result, isA<Success<DateValue>>());
      expect((result as Success<DateValue>).value.value, now);
    });

    test('should create valid date for past time', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      final result = DateValue.create(past);

      expect(result, isA<Success<DateValue>>());
      expect((result as Success<DateValue>).value.value, past);
    });

    test('should accept date within allowed skew', () {
      final nearFuture = DateTime.now().add(const Duration(minutes: 3));
      final result = DateValue.create(
        nearFuture,
        allowedSkew: const Duration(minutes: 5),
      );

      expect(result, isA<Success<DateValue>>());
    });

    test('should fail for future date beyond skew', () {
      final future = DateTime.now().add(const Duration(days: 1));
      final result = DateValue.create(future);

      expect(result, isA<Fail<DateValue>>());
      expect((result as Fail<DateValue>).failure.code, 'date_future');
    });

    test('should fail for date exceeding allowed skew', () {
      final future = DateTime.now().add(const Duration(minutes: 10));
      final result = DateValue.create(
        future,
        allowedSkew: const Duration(minutes: 5),
      );

      expect(result, isA<Fail<DateValue>>());
      expect((result as Fail<DateValue>).failure.code, 'date_future');
    });

    test('should support equality', () {
      final date = DateTime(2024, 1, 1, 12, 0, 0);
      final date1 = DateValue.create(date);
      final date2 = DateValue.create(date);
      final date3 = DateValue.create(DateTime(2024, 1, 2));

      expect(
        (date1 as Success<DateValue>).value,
        (date2 as Success<DateValue>).value,
      );
      expect((date1).value == (date3 as Success<DateValue>).value, false);
    });
  });

  group('ColorValue Value Object', () {
    test('should create valid 6-digit hex color', () {
      final result = ColorValue.create('#ff5722');

      expect(result, isA<Success<ColorValue>>());
      expect((result as Success<ColorValue>).value.hex, '#FF5722');
    });

    test('should create valid 8-digit hex color with alpha', () {
      final result = ColorValue.create('#ff5722aa');

      expect(result, isA<Success<ColorValue>>());
      expect((result as Success<ColorValue>).value.hex, '#FF5722AA');
    });

    test('should normalize to uppercase', () {
      final result = ColorValue.create('#abc123');

      expect(result, isA<Success<ColorValue>>());
      expect((result as Success<ColorValue>).value.hex, '#ABC123');
    });

    test('should accept uppercase input', () {
      final result = ColorValue.create('#FF5722');

      expect(result, isA<Success<ColorValue>>());
      expect((result as Success<ColorValue>).value.hex, '#FF5722');
    });

    test('should fail for color name', () {
      final result = ColorValue.create('red');

      expect(result, isA<Fail<ColorValue>>());
      expect((result as Fail<ColorValue>).failure.code, 'invalid_color');
    });

    test('should fail for invalid hex format', () {
      final result = ColorValue.create('#gg0000');

      expect(result, isA<Fail<ColorValue>>());
      expect((result as Fail<ColorValue>).failure.code, 'invalid_color');
    });

    test('should fail for hex without hash', () {
      final result = ColorValue.create('ff5722');

      expect(result, isA<Fail<ColorValue>>());
      expect((result as Fail<ColorValue>).failure.code, 'invalid_color');
    });

    test('should fail for wrong length hex', () {
      final result = ColorValue.create('#fff');

      expect(result, isA<Fail<ColorValue>>());
      expect((result as Fail<ColorValue>).failure.code, 'invalid_color');
    });

    test('should support equality', () {
      final color1 = ColorValue.create('#ff5722');
      final color2 = ColorValue.create('#FF5722');
      final color3 = ColorValue.create('#00ff00');

      expect(
        (color1 as Success<ColorValue>).value,
        (color2 as Success<ColorValue>).value,
      );
      expect((color1).value == (color3 as Success<ColorValue>).value, false);
    });
  });

  group('IconValue Value Object', () {
    test('should create valid icon', () {
      final result = IconValue.create('wallet');

      expect(result, isA<Success<IconValue>>());
      expect((result as Success<IconValue>).value.name, 'wallet');
    });

    test('should trim whitespace', () {
      final result = IconValue.create('  bank  ');

      expect(result, isA<Success<IconValue>>());
      expect((result as Success<IconValue>).value.name, 'bank');
    });

    test('should accept icon with special characters', () {
      final result = IconValue.create('wallet_outline');

      expect(result, isA<Success<IconValue>>());
      expect((result as Success<IconValue>).value.name, 'wallet_outline');
    });

    test('should fail for empty icon', () {
      final result = IconValue.create('');

      expect(result, isA<Fail<IconValue>>());
      expect((result as Fail<IconValue>).failure.code, 'icon_empty');
    });

    test('should fail for whitespace-only icon', () {
      final result = IconValue.create('   ');

      expect(result, isA<Fail<IconValue>>());
      expect((result as Fail<IconValue>).failure.code, 'icon_empty');
    });

    test('should support equality', () {
      final icon1 = IconValue.create('wallet');
      final icon2 = IconValue.create('wallet');
      final icon3 = IconValue.create('bank');

      expect(
        (icon1 as Success<IconValue>).value,
        (icon2 as Success<IconValue>).value,
      );
      expect((icon1).value == (icon3 as Success<IconValue>).value, false);
    });
  });
}
