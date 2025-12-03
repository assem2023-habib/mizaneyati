import 'package:flutter_test/flutter_test.dart';
import 'package:mizaneyati/core/utils/result.dart';
import 'package:mizaneyati/domain/entities/account_entity.dart';
import 'package:mizaneyati/domain/value_objects/money.dart';
import 'package:mizaneyati/domain/value_objects/account_name.dart';
import 'package:mizaneyati/domain/value_objects/icon_value.dart';
import 'package:mizaneyati/domain/value_objects/color_value.dart';

void main() {
  group('AccountEntity', () {
    final tAccount = AccountEntity(
      id: '1',
      name: (AccountName.create('Test Account') as Success<AccountName>).value,
      type: 'Bank',
      balance: (Money.create(1000) as Success<Money>).value, // 10.00
      currency: 'TRY',
      icon: (IconValue.create('icon') as Success<IconValue>).value,
      color: (ColorValue.create('color') as Success<ColorValue>).value,
      isActive: true,
    );

    test('credit should increase balance', () {
      final amount = (Money.create(500) as Success<Money>).value; // 5.00
      final result = tAccount.credit(amount);

      expect(result, isA<Success<AccountEntity>>());
      final updatedAccount = (result as Success<AccountEntity>).value;
      expect(updatedAccount.balance.minorUnits, 1500);
    });

    test('debit should decrease balance', () {
      final amount = (Money.create(500) as Success<Money>).value; // 5.00
      final result = tAccount.debit(amount);

      expect(result, isA<Success<AccountEntity>>());
      final updatedAccount = (result as Success<AccountEntity>).value;
      expect(updatedAccount.balance.minorUnits, 500);
    });

    test('debit should allow negative balance (if allowed by Money)', () {
      final amount = (Money.create(1500) as Success<Money>).value; // 15.00
      final result = tAccount.debit(amount);

      expect(result, isA<Success<AccountEntity>>());
      final updatedAccount = (result as Success<AccountEntity>).value;
      expect(updatedAccount.balance.minorUnits, -500);
    });
  });
}
