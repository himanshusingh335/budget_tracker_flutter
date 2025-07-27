class GenAIQuestion {
  final String question;

  GenAIQuestion({required this.question});

  factory GenAIQuestion.fromJson(Map<String, dynamic> json) {
    return GenAIQuestion(
      question: json['question'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
    };
  }
}

class GenAIResponse {
  final String answer;
  final String status;

  GenAIResponse({
    required this.answer,
    required this.status,
  });

  factory GenAIResponse.fromJson(Map<String, dynamic> json) {
    return GenAIResponse(
      answer: json['answer'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'status': status,
    };
  }
}