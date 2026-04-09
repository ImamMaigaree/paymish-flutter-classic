import 'package:flutter_paystack/flutter_paystack.dart';

const _baseUrl = "baseUrl";
const _socketUrl = "socketUrl";
const _payStackPublicKey = "_payStackPublicKey";

Environment currentEnvironment = Environment.userDev;
final PaystackPlugin paystackPlugin = PaystackPlugin();

enum Environment {
  userDev,
  merchantDev,
  userStage,
  merchantStage,
  userProd,
  merchantProd
}

Map<String, dynamic> _config = userDevConstants;

void setEnvironment(Environment env) {
  switch (env) {
    case Environment.userDev:
      _config = userDevConstants;
      currentEnvironment = Environment.userDev;
      break;
    case Environment.merchantDev:
      _config = merchantDevConstants;
      currentEnvironment = Environment.merchantDev;
      break;
    case Environment.userStage:
      _config = userStageConstants;
      currentEnvironment = Environment.userStage;
      break;
    case Environment.merchantStage:
      _config = merchantStageConstants;
      currentEnvironment = Environment.merchantStage;
      break;
    case Environment.userProd:
      _config = userProdConstants;
      currentEnvironment = Environment.userProd;
      break;
    case Environment.merchantProd:
      _config = merchantProdConstants;
      currentEnvironment = Environment.merchantProd;
      break;
  }
}

Environment getEnvironment() {
  return currentEnvironment;
}

dynamic get apiBaseUrl {
  return _config[_baseUrl];
}

dynamic get payStackKey {
  return _config[_payStackPublicKey];
}

dynamic get socketUrl {
  return _config[_socketUrl];
}

Map<String, dynamic> userDevConstants = {
  _baseUrl: "http://10.0.2.2:5500/api/v1/",
  _socketUrl: "http://10.0.2.2:3003/",
  _payStackPublicKey: "pk_live_1b15f5dbb3477f2418f4fb06672d48410e5b2f79"
};

Map<String, dynamic> merchantDevConstants = {
  _baseUrl: "http://10.0.2.2:5500/api/v1/",
  _socketUrl: "http://10.0.2.2:3003/",
  _payStackPublicKey: "pk_live_1b15f5dbb3477f2418f4fb06672d48410e5b2f79"
};

Map<String, dynamic> userStageConstants = {
  _baseUrl: "https://api.stage.paymish.com/v1/",
  _socketUrl: "https://chat.stage.paymish.com/",
  _payStackPublicKey: "pk_test_102da9c4996e1cbe80a1964b92a5974760ae4cfe"
};

Map<String, dynamic> merchantStageConstants = {
  _baseUrl: "https://api.stage.paymish.com/v1/",
  _socketUrl: "https://chat.stage.paymish.com/",
  _payStackPublicKey: "pk_test_102da9c4996e1cbe80a1964b92a5974760ae4cfe"
};

Map<String, dynamic> userProdConstants = {
  _baseUrl: "https://api.paymish.com/v1/",
  _socketUrl: "https://chat.paymish.com/",
  _payStackPublicKey: "pk_test_102da9c4996e1cbe80a1964b92a5974760ae4cfe"
};

Map<String, dynamic> merchantProdConstants = {
  _baseUrl: "https://api.paymish.com/v1/",
  _socketUrl: "https://chat.paymish.com/",
  _payStackPublicKey: "pk_live_e043b6f859fd56872692386ba935f7509f1cd748"
};
