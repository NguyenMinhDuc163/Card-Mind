class ChatResponse {
  ChatResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final num? status;
  final String? message;
  final ChatResponseData? data;

  factory ChatResponse.fromJson(Map<String, dynamic> json){
    return ChatResponse(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? null : ChatResponseData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

  @override
  String toString(){
    return "$status, $message, $data, ";
  }
}

class ChatResponseData {
  ChatResponseData({
    required this.code,
    required this.message,
    required this.data,
    required this.error,
  });

  final num? code;
  final String? message;
  final DataData? data;
  final dynamic error;

  factory ChatResponseData.fromJson(Map<String, dynamic> json){
    return ChatResponseData(
      code: json["code"],
      message: json["message"],
      data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
    "error": error,
  };

  @override
  String toString(){
    return "$code, $message, $data, $error, ";
  }
}

class DataData {
  DataData({
    required this.answer,
    required this.rawAnswer,
  });

  final String? answer;
  final String? rawAnswer;

  factory DataData.fromJson(Map<String, dynamic> json){
    return DataData(
      answer: json["answer"],
      rawAnswer: json["rawAnswer"],
    );
  }

  Map<String, dynamic> toJson() => {
    "answer": answer,
    "rawAnswer": rawAnswer,
  };

  @override
  String toString(){
    return "$answer, $rawAnswer, ";
  }
}
