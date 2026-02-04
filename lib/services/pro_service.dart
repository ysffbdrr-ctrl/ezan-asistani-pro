class ProService {
  static final ProService _instance = ProService._internal();

  factory ProService() {
    return _instance;
  }

  ProService._internal();

  static ProService get instance => _instance;

  bool isPro = false;

  Future<void> initialize() async {
    // Initialization placeholder
  }

  Future<void> activatePro() async {
    isPro = true;
  }

  bool getProStatus() {
    return isPro;
  }
}
