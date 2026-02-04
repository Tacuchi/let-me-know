import 'package:equatable/equatable.dart';

import '../../../../services/assistant/models/assistant_response.dart';

/// Tipo de mensaje en el historial del chat.
enum ChatMessageType {
  /// Mensaje del usuario (voz o texto).
  userMessage,

  /// Respuesta del asistente (texto hablado).
  systemResponse,

  /// Error durante el procesamiento.
  systemError,

  /// Accion ejecutada inline (completar, eliminar, etc.).
  systemAction,

  /// @deprecated Use userMessage instead
  userVoice,
}

/// Una entrada en el historial de conversacion del chat de voz.
class ChatMessage extends Equatable {
  final String id;
  final ChatMessageType type;
  final DateTime timestamp;

  /// Texto del mensaje (transcripcion del usuario o respuesta del sistema).
  final String? text;

  /// Respuesta completa del LLM (solo para systemResponse).
  final AssistantResponse? response;

  /// Texto de error (solo para systemError).
  final String? errorText;

  /// Si el mensaje del usuario fue por voz (true) o texto (false).
  final bool isVoice;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.timestamp,
    this.text,
    this.response,
    this.errorText,
    this.isVoice = false,
  });

  /// Crea un mensaje de voz del usuario.
  factory ChatMessage.userVoice({
    required String id,
    required String text,
  }) {
    return ChatMessage(
      id: id,
      type: ChatMessageType.userMessage,
      timestamp: DateTime.now(),
      text: text,
      isVoice: true,
    );
  }

  /// Crea un mensaje de texto del usuario.
  factory ChatMessage.userText({
    required String id,
    required String text,
  }) {
    return ChatMessage(
      id: id,
      type: ChatMessageType.userMessage,
      timestamp: DateTime.now(),
      text: text,
      isVoice: false,
    );
  }

  /// Crea un mensaje de respuesta del sistema.
  factory ChatMessage.systemResponse({
    required String id,
    required AssistantResponse response,
  }) {
    return ChatMessage(
      id: id,
      type: ChatMessageType.systemResponse,
      timestamp: DateTime.now(),
      text: response.spokenResponse,
      response: response,
    );
  }

  /// Crea un mensaje de error del sistema.
  factory ChatMessage.systemError({
    required String id,
    required String errorText,
  }) {
    return ChatMessage(
      id: id,
      type: ChatMessageType.systemError,
      timestamp: DateTime.now(),
      errorText: errorText,
    );
  }

  /// Crea un mensaje de accion ejecutada.
  factory ChatMessage.systemAction({
    required String id,
    required String text,
  }) {
    return ChatMessage(
      id: id,
      type: ChatMessageType.systemAction,
      timestamp: DateTime.now(),
      text: text,
    );
  }

  @override
  List<Object?> get props => [id, type, timestamp, text, errorText, isVoice];
}
