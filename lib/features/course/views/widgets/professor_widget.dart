import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfessorWidget extends StatefulWidget {
  final String professorId;

  const ProfessorWidget({super.key, required this.professorId});

  @override
  State<ProfessorWidget> createState() => _ProfessorWidgetState();
}

class _ProfessorWidgetState extends State<ProfessorWidget> {
  @override
  void initState() {
    final professorCubit = context.read<ProfessorCubit>();
    final professorId = widget.professorId;
    super.initState();
    
    if (professorId.isNotEmpty &&
        (professorCubit.state is! ProfessorDetailLoaded ||
            (professorCubit.state as ProfessorDetailLoaded).professor.id !=
                professorId)) {
      professorCubit.fetchProfessorById(widget.professorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfessorCubit, ProfessorState>(
      builder: (context, state) {
        if (state is ProfessorLoading) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Loading Professor Information...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfessorError) {
          return Card(
            elevation: 2,
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade800),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading professor information: ${state.message}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfessorDetailLoaded) {
          final professor = state.professor;
          return Card(
            elevation: 3, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ), 
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28, 
                        child: Icon(
                          Icons.person_outline,
                          size: 36,
                        ), 
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              professor.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ), 
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'Department: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), 
                                  TextSpan(text: professor.department),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ), 
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          professor.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis, 
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink(); 
        }
      },
    );
  }
}
