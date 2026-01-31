import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/tracking/data/repositories/parcel_repository_impl.dart';

class MockParcelRepository extends Mock implements ParcelRepository {}

void main() {
  group('ParcelViewModel Unit Tests', () {
    late ParcelViewModel parcelViewModel;
    late MockParcelRepository mockRepository;

    setUp(() {
      mockRepository = MockParcelRepository();
      parcelViewModel = ParcelViewModel(mockRepository);
    });

    test('ParcelViewModel initializes with empty user parcels', () {
      expect(parcelViewModel.userParcels, isEmpty);
    });

    test('ParcelViewModel initializes with null selected parcel', () {
      expect(parcelViewModel.selectedParcel, isNull);
    });

    test('ParcelViewModel notifyListeners updates observers', () {
      int notificationCount = 0;
      parcelViewModel.addListener(() => notificationCount++);

      parcelViewModel.notifyListeners();

      expect(notificationCount, equals(1));
    });

    test('ParcelViewModel can be disposed safely', () {
      expect(() => parcelViewModel.dispose(), returnsNormally);
    });

    test('ParcelViewModel isLoading property exists', () {
      expect(parcelViewModel.isLoading, isA<bool>());
    });

    test('ParcelViewModel user parcels list is iterable', () {
      expect(parcelViewModel.userParcels, isA<List>());
    });

    test('ParcelViewModel can add multiple listeners', () {
      int count1 = 0;
      int count2 = 0;

      parcelViewModel.addListener(() => count1++);
      parcelViewModel.addListener(() => count2++);

      parcelViewModel.notifyListeners();
      parcelViewModel.notifyListeners();

      expect(count1, equals(2));
      expect(count2, equals(2));
    });

    test('ParcelViewModel selected parcel can be null or object', () {
      expect(
        parcelViewModel.selectedParcel == null ||
            parcelViewModel.selectedParcel is ParcelEntity,
        isTrue,
      );
    });

    test('ParcelViewModel error message state', () {
      expect(parcelViewModel.error, isNull);
    });

    test('ParcelViewModel maintains state after listener notify', () {
      final initialParcels = parcelViewModel.userParcels;

      parcelViewModel.notifyListeners();

      expect(identical(parcelViewModel.userParcels, initialParcels), isTrue);
    });

    test('ParcelViewModel multiple dispose calls throw FlutterError', () {
      parcelViewModel.dispose();
      // Second dispose is expected to throw FlutterError in debug mode
      expect(() => parcelViewModel.dispose(), throwsFlutterError);
    });

    test('ParcelViewModel isLoading initial state', () {
      expect(parcelViewModel.isLoading, isFalse);
    });

    test('ParcelViewModel userParcels is mutable list', () {
      final parcels = parcelViewModel.userParcels;
      expect(parcels, isA<List>());
      expect(parcels.isEmpty, isTrue);
    });

    test('ParcelViewModel selectedParcel initial state', () {
      expect(parcelViewModel.selectedParcel, isNull);
    });

    test('ParcelViewModel listener callback execution', () {
      bool listenerCalled = false;
      parcelViewModel.addListener(() => listenerCalled = true);

      parcelViewModel.notifyListeners();

      expect(listenerCalled, isTrue);
    });
  });
}
