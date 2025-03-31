import 'package:edu_app/features/course/cubit/professor_cubit.dart';
import 'package:edu_app/features/course/cubit/professor_state.dart';
import 'package:edu_app/features/course/models/professor.dart';
import 'package:edu_app/shared/widgets/error_view.dart';
import 'package:edu_app/shared/widgets/loading_view.dart';
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
    super.initState();
    _fetchProfessor();
  }

  @override
  void didUpdateWidget(ProfessorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.professorId != oldWidget.professorId) {
      _fetchProfessor();
    }
  }

  void _fetchProfessor() {
    final professorCubit = context.read<ProfessorCubit>();
    final state = professorCubit.state;

    final isProfessorLoaded =
        state is ProfessorDetailLoaded &&
        state.professor.id == widget.professorId;

    if (widget.professorId.isNotEmpty && !isProfessorLoaded) {
      professorCubit.fetchProfessorById(widget.professorId);
    }
  }

  void _retryFetch() =>
      context.read<ProfessorCubit>().fetchProfessorById(widget.professorId);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfessorCubit, ProfessorState>(
      builder: (context, state) {
        return switch (state) {
          ProfessorLoading() => const LoadingView(
            message: "Loading Professor...",
          ),
          ProfessorError() => ErrorView(
            message: state.message,
            onRetry: _retryFetch,
          ),
          ProfessorDetailLoaded()
              when state.professor.id == widget.professorId =>
            _ProfessorCard(professor: state.professor),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _ProfessorCard extends StatelessWidget {
  final Professor professor;

  const _ProfessorCard({required this.professor});

  void _navigateToProfessorDetail(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _navigateToProfessorDetail(context),
      borderRadius: BorderRadius.circular(16),
      splashColor: colorScheme.primary.withValues(alpha: .1),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ProfileIcon(colorScheme: colorScheme),
              const SizedBox(width: 16),
              _ProfessorInfo(
                professor: professor,
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 16),
              _MessageButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ProfileIcon({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        size: 32,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _ProfessorInfo extends StatelessWidget {
  final Professor professor;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ProfessorInfo({
    required this.professor,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            professor.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            professor.department,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: "Message Professor",
      child: IconButton(
        icon: const Icon(Icons.chat_bubble_outline),
        color: theme.colorScheme.primary,
        onPressed: () {},
      ),
    );
  }
}
