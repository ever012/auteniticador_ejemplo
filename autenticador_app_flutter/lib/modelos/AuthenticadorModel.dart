class AuthenticadorModel {
  final String account;
  final String secretKey;

  AuthenticadorModel({required this.account, required this.secretKey});

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'secretKey': secretKey,
    };
  }
}

class ResponseModel {
  final String code;

  ResponseModel({required this.code});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(code: json['code']);
  }
}
