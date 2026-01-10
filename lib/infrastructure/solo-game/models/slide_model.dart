import '../../../domain/solo-game/entities/slide_entity.dart';

class SlideModel extends SlideEntity {
  SlideModel({
    required String slideId,
    required String questionType,
    required String questionText,
    required int timeLimitSeconds,
    String? mediaUrl,
    required List<OptionModel> options,
  }) : super(
         slideId: slideId,
         questionType: questionType,
         questionText: questionText,
         timeLimitSeconds: timeLimitSeconds,
         mediaUrl: mediaUrl,
         options: options,
       );

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      slideId: json['slideId'] ?? '',
      questionType: json['questionType'] ?? 'QUIZ',
      questionText: json['questionText'] ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] ?? 30,

      // La API dice "mediaID" o "mediaUrl", ajustamos el mapeo
      mediaUrl: json['mediaID'] ?? json['mediaUrl'],

      // Mapeo de lista de objetos: JSON Array -> List<OptionModel>
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => OptionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OptionModel extends OptionEntity {
  OptionModel({required String index, String? text, String? mediaUrl})
    : super(index: index, text: text, mediaUrl: mediaUrl);

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      // Forzamos a String por si el backend manda un número 1 en vez de "1"
      index: json['index'].toString(),
      // Check multiple possible field names for the text
      text: json['text'] ?? json['answer'] ?? json['content'] ?? json['label'],
      mediaUrl: json['mediaID'] ?? json['mediaUrl'],
    );
  }
}
