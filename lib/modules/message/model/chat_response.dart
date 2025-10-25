class ChatResponse {
  ChatResponse({required this.code, required this.message, required this.data});

  final num? code;
  final String? message;
  final ChatResponseData? data;

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      code: json["code"],
      message: json["message"],
      data:
          json["data"] == null ? null : ChatResponseData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };

  @override
  String toString() {
    return "$code, $message, $data, ";
  }
}

class ChatResponseData {
  ChatResponseData({required this.answer, required this.rawAnswer});

  final String? answer;
  final String? rawAnswer;

  factory ChatResponseData.fromJson(Map<String, dynamic> json) {
    return ChatResponseData(
      answer: json["answer"],
      rawAnswer: json["rawAnswer"],
    );
  }

  Map<String, dynamic> toJson() => {"answer": answer, "rawAnswer": rawAnswer};

  @override
  String toString() {
    return "$answer, $rawAnswer, ";
  }
}
