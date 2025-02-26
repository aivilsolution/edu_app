import '/features/course/models/course_model.dart';

Professor physicsProf = Professor(
  id: "prof_01",
  name: "Dr. Alan Richardson",
  email: "arichardson@university.edu",
  department: "Physics",
  officeHours: "Mon, Wed: 2pm - 4pm",
  officeLocation: "Room 101, Physics Building",
);

Professor chemistryProf = Professor(
  id: "prof_02",
  name: "Dr. Emily Zhang",
  email: "ezhang@university.edu",
  department: "Chemistry",
  officeHours: "Tue, Thu: 11am - 1pm",
  officeLocation: "Room 505, Science Building",
);

Professor mathProf = Professor(
  id: "prof_03",
  name: "Dr. Robert Chen",
  email: "rchen@university.edu",
  department: "Mathematics",
  officeHours: "Tue, Thu: 2pm - 4pm",
  officeLocation: "Room 305, Math Building",
);

Professor biologyProf = Professor(
  id: "prof_04",
  name: "Dr. Sarah Martinez",
  email: "smartinez@university.edu",
  department: "Biology",
  officeHours: "Mon, Wed, Fri: 1pm - 3pm",
  officeLocation: "Room 205, Life Sciences Building",
);

Professor englishProf = Professor(
  id: "prof_05",
  name: "Dr. Michael Brown",
  email: "mbrown@university.edu",
  department: "English",
  officeHours: "Mon, Thu: 3pm - 5pm",
  officeLocation: "Room 203, Arts Building",
);

List<Course> courses = [
  Course(
    code: "course_01",
    name: "Physics",
    syllabus: "Newtonian mechanics, motion, forces, and energy principles.",
    professor: physicsProf,
    assignments: [
      Assignment(
        id: "phys_assgn_01",
        title: "Laws of Motion",
        description: "Problem set on Newton's three laws of motion.",
        dueDate: DateTime(2025, 2, 20),
        totalPoints: 100,
        isSubmitted: true,
        score: 92.0,
        attachments: ["laws_of_motion.pdf"],
      ),
    ],
    labs: [],
    quizzes: [
      Quiz(
        id: "phys_quiz_01",
        title: "Kinematics Quiz",
        description: "Quiz covering velocity, acceleration, and motion.",
        date: DateTime(2025, 2, 12),
        duration: 60,
        totalPoints: 50,
        isCompleted: true,
        score: 45,
        type: QuizType.inPerson,
      ),
    ],
  ),
  Course(
    code: "course_02",
    name: "Chemistry",
    syllabus: "Introduction to organic compounds, reactions, and mechanisms.",
    professor: chemistryProf,
    assignments: [
      Assignment(
        id: "chem_assgn_01",
        title: "Organic Reactions",
        description: "Comprehensive analysis of organic reaction mechanisms.",
        dueDate: DateTime(2025, 2, 20),
        totalPoints: 100,
        isSubmitted: true,
        score: 88.0,
        attachments: ["organic_reactions.pdf"],
      ),
    ],
    labs: [],
    quizzes: [
      Quiz(
        id: "chem_quiz_01",
        title: "Mechanisms Quiz",
        description: "Quiz covering basic reaction mechanisms.",
        date: DateTime(2025, 2, 12),
        duration: 60,
        totalPoints: 50,
        isCompleted: true,
        score: 46,
        type: QuizType.inPerson,
      ),
    ],
  ),
  Course(
    code: "course_03",
    name: "Mathematics",
    syllabus: "Advanced calculus concepts including integration techniques.",
    professor: mathProf,
    assignments: [
      Assignment(
        id: "math_assgn_01",
        title: "Integration Techniques",
        description: "Practice problems on various integration methods.",
        dueDate: DateTime(2025, 2, 20),
        totalPoints: 100,
        isSubmitted: true,
        score: 85.0,
        attachments: ["calculus_homework.pdf"],
      ),
    ],
    labs: [],
    quizzes: [
      Quiz(
        id: "math_quiz_01",
        title: "Integration Quiz",
        description: "Quiz covering basic integration techniques.",
        date: DateTime(2025, 2, 12),
        duration: 60,
        totalPoints: 50,
        isCompleted: true,
        score: 45,
        type: QuizType.inPerson,
      ),
    ],
  ),
  Course(
    code: "course_04",
    name: "Biology",
    syllabus: "Study of cell structure, function, and cellular processes.",
    professor: biologyProf,
    assignments: [
      Assignment(
        id: "bio_assgn_01",
        title: "Cell Membrane Analysis",
        description: "Analysis of membrane transport mechanisms.",
        dueDate: DateTime(2025, 2, 20),
        totalPoints: 100,
        isSubmitted: true,
        score: 90.0,
        attachments: ["membrane_analysis.pdf"],
      ),
    ],
    labs: [],
    quizzes: [
      Quiz(
        id: "bio_quiz_01",
        title: "Cell Structure Quiz",
        description: "Quiz covering basic cell structures and functions.",
        date: DateTime(2025, 2, 12),
        duration: 60,
        totalPoints: 50,
        isCompleted: true,
        score: 48,
        type: QuizType.inPerson,
      ),
    ],
  ),
  Course(
    code: "course_05",
    name: "English",
    syllabus: "Study of literary works from 1900 to the present day.",
    professor: englishProf,
    assignments: [
      Assignment(
        id: "eng_assgn_01",
        title: "Literary Analysis",
        description: "Essay on major modern literary movements.",
        dueDate: DateTime(2025, 2, 20),
        totalPoints: 100,
        isSubmitted: true,
        score: 95.0,
        attachments: ["literary_movements.pdf"],
      ),
    ],
    labs: [],
    quizzes: [
      Quiz(
        id: "eng_quiz_01",
        title: "Poetry Quiz",
        description: "Quiz covering modern English poetry.",
        date: DateTime(2025, 2, 12),
        duration: 60,
        totalPoints: 50,
        isCompleted: true,
        score: 47,
        type: QuizType.inPerson,
      ),
    ],
  ),
];

final List courseMap = List.generate(courses.length, (index) {
  courses[index].toMap();
});
