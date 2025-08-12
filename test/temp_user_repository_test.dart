import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soma/data/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MockUserRepository extends Mock implements UserRepository {
  @override
  Future<Map<String, dynamic>> getCurrentUserDetails() {
    return super.noSuchMethod(
      Invocation.method(#getCurrentUserDetails, []),
      returnValue: Future.value({'_id': 'default_id', 'tokens': 0}),
    );
  }
}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('UserRepository Mocking', () {
    late MockUserRepository mockUserRepository;
    late SharedPreferences mockSharedPreferences;
    late http.Client mockHttpClient;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockSharedPreferences = MockSharedPreferences();
      mockHttpClient = MockHttpClient();

      when(mockSharedPreferences.getString('jwt_token')).thenReturn('dummy_token');

      when(mockUserRepository.getCurrentUserDetails()).thenAnswer((_) async {
        await Future.delayed(Duration.zero); // Ensure it's truly async
        return {
          '_id': 'test_id',
          'tokens': 100,
        };
      });
    });

    test('getCurrentUserDetails returns mocked data', () async {
      final userDetails = await mockUserRepository.getCurrentUserDetails();
      expect(userDetails['_id'], 'test_id');
      expect(userDetails['tokens'], 100);
    });
  });
}