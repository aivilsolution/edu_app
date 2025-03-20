import 'package:edu_app/features/communication/cubit/message_state.dart';
import 'package:edu_app/features/communication/services/message_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageCubit extends Cubit<MessageState> {
  final MessageService _messageService;

  MessageCubit(this._messageService) : super(MessageInitial());

  void loadMessages(String receiverId) {
    try {
      emit(MessageLoading());
      _messageService
          .getMessagesStream(receiverId)
          .listen(
            (messages) {
              emit(MessageLoaded(messages, receiverId));
            },
            onError: (error) {
              emit(MessageError(error.toString()));
            },
          );
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      await _messageService.sendMessage(
        receiverId: receiverId,
        message: message,
      );
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }
}
