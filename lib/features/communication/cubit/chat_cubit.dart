import 'package:edu_app/features/communication/cubit/chat_state.dart';
import 'package:edu_app/features/communication/services/chat_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;

  ChatCubit(this._chatService) : super(ChatInitial());

  Future<void> loadUsers() async {
    emit(ChatLoading());
    _chatService.getUsersStream().listen(
      (users) {
        emit(ChatLoaded(users));
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> loadUserById(String userId) async {
    emit(ChatLoading());
    final user = await _chatService.getUserById(userId);
    if (user != null) {
      emit(UserProfileLoaded(user));
    } else {
      emit(ChatError('User not found'));
    }
  }
}
