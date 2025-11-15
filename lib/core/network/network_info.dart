abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// TODO: Implement with connectivity_plus package
// class NetworkInfoImpl implements NetworkInfo {
//   final Connectivity connectivity;
//   
//   NetworkInfoImpl(this.connectivity);
//   
//   @override
//   Future<bool> get isConnected async {
//     final result = await connectivity.checkConnectivity();
//     return result != ConnectivityResult.none;
//   }
// }