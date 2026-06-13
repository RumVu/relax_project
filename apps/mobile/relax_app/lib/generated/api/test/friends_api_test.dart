import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for FriendsApi
void main() {
  final instance = RelaxApiClient().getFriendsApi();

  group(FriendsApi, () {
    //Future friendsControllerAcceptRequest(String requesterId) async
    test('test friendsControllerAcceptRequest', () async {
      // TODO
    });

    //Future friendsControllerGetMyFriends() async
    test('test friendsControllerGetMyFriends', () async {
      // TODO
    });

    //Future friendsControllerGetPendingRequests() async
    test('test friendsControllerGetPendingRequests', () async {
      // TODO
    });

    //Future friendsControllerSendRequest(String friendId) async
    test('test friendsControllerSendRequest', () async {
      // TODO
    });

  });
}
