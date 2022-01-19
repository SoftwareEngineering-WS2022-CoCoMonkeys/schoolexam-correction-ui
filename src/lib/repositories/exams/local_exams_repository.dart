import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/repositories/exams/persistence/persistence.dart';
import 'package:sqflite/sqflite.dart';

class LocalExamsRepository extends ExamsRepository {
  Database? database;

  Future<void> init() async {
    final path = p.join(await getDatabasesPath(), 'exams_repository100.db');

    database = await openDatabase(path, onCreate: (db, version) {
      /// PARTICIPANT
      db.execute(
          'CREATE TABLE IF NOT EXISTS participants(id TEXT PRIMARY KEY, displayName TEXT NOT NULL)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS students(id TEXT PRIMARY KEY, FOREIGN KEY(id) REFERENCES participants(id) ON DELETE CASCADE)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS courses(id TEXT PRIMARY KEY, FOREIGN KEY(id) REFERENCES participants(id) ON DELETE CASCADE)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS courses_children(courseId TEXT NOT NULL, participantId TEXT NOT NULL, PRIMARY KEY(courseId, participantId), FOREIGN KEY(courseId) REFERENCES courses(id), FOREIGN KEY(participantId) REFERENCES participants(id) ON DELETE CASCADE)');

      /// EXAM
      db.execute(
          'CREATE TABLE IF NOT EXISTS exams(id TEXT PRIMARY KEY, status TEXT NOT NULL, title TEXT NOT NULL, dateOfExam TEXT, dueDate TEXT, topic TEXT NOT NULL)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS exams_participants(examId TEXT NOT NULL, participantId TEXT NOT NULL, PRIMARY KEY(examId, participantId), FOREIGN KEY(examId) REFERENCES exams(id) ON DELETE CASCADE, FOREIGN KEY(participantId) REFERENCES participants(id) ON DELETE CASCADE)');

      /// TASK
      db.execute(
          'CREATE TABLE IF NOT EXISTS tasks(id TEXT PRIMARY KEY, title TEXT NOT NULL, maxPoints REAL NOT NULL, examId TEXT NOT NULL, FOREIGN KEY(examId) REFERENCES exams(id) ON DELETE CASCADE)');

      /// GRADING TABLE
      db.execute(
          'CREATE TABLE IF NOT EXISTS gt_lower_bounds(grade TEXT NOT NULL, points DECIMAL NOT NULL, examId TEXT NOT NULL, FOREIGN KEY(examId) REFERENCES exams(id) ON DELETE CASCADE)');

      /// CORRECTABLE
      db.execute(
          'CREATE TABLE IF NOT EXISTS submissions(id TEXT PRIMARY KEY, isMatchedToStudent INTEGER NOT NULL, isComplete INTEGER NOT NULL, examId TEXT NOT NULL, data TEXT NOT NULL, studentId TEXT NOT NULL, achievedPoints REAL DEFAULT 0 NOT NULL, status TEXT NOT NULL, updatedAt INT NOT NULL, FOREIGN KEY(examId) REFERENCES exams(id) ON DELETE CASCADE, FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS answer_segments(segmentId INTEGER PRIMARY KEY NOT NULL, submissionId TEXT NOT NULL, taskId TEXT NOT NULL, startPage INT NOT NULL, endPage INT NOT NULL, startY DOUBLE NOT NULL, endY DOUBLE NOT NULL, UNIQUE(segmentId, submissionId, taskId), FOREIGN KEY(submissionId) REFERENCES submissions(id) ON DELETE CASCADE, FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS answers(submissionId TEXT NOT NULL, taskId TEXT NOT NULL, achievedPoints REAL DEFAULT 0 NOT NULL, status TEXT NOT NULL, updatedAt INT NOT NULL, PRIMARY KEY(submissionId, taskId), FOREIGN KEY(submissionId) REFERENCES submissions(id) ON DELETE CASCADE, FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE)');
    }, version: 1);
  }

  /// [courses] has to be already sanitized input
  Future<List<CourseChildren>> getChildren(List<String> courses) async =>
      List<Map<String, dynamic>>.from(await database!.rawQuery(
        'WITH RECURSIVE member_of(courseId, id, displayName, isCourse) AS ('
        '	SELECT cc.courseId, p.id, p.displayName, (CASE WHEN NOT (c.id IS NULL) THEN 1 ELSE 0 END) AS isCourse'
        '	FROM courses_children AS cc'
        '	INNER JOIN participants AS p'
        '	ON '
        '		p.id = cc.participantId '
        '	LEFT OUTER JOIN courses AS c'
        '	ON'
        '		c.id = p.id'
        '	WHERE cc.courseId IN (${courses.map((e) => "'$e'").join(",")})'
        '	UNION ALL'
        '	SELECT m.id, p.id, p.displayName, (CASE WHEN NOT (c.id IS NULL) THEN 1 ELSE 0 END) AS isCourse'
        ' FROM courses_children AS cc'
        '	INNER JOIN member_of AS m'
        '	ON'
        '		m.id = cc.courseId'
        '	INNER JOIN participants AS p'
        '	ON '
        '		p.id = cc.participantId'
        '	LEFT OUTER JOIN courses AS c'
        '	ON'
        '		c.id = p.id'
        ')'
        ' SELECT * FROM member_of;',
      ))
          .map((e) {
        if (e["isCourse"] == 1) {
          return CourseChildren(
              courseId: e["courseId"], participant: CourseData.fromMap(e));
        } else {
          return CourseChildren(
              courseId: e["courseId"], participant: CourseData.fromMap(e));
        }
      }).toList();

  /// Retrieves the student with the identification [id].
  Future<Student> getStudent(String id) async =>
      List<Map<String, dynamic>>.from(await database!.rawQuery(
              'SELECT p.id, p.displayName FROM participants p INNER JOIN students s ON s.id = p.id WHERE s.id = ?',
              [
            id
          ]))
          .map((e) => StudentData.fromMap(e).toModel([]))
          .firstWhere((element) => element.id == id,
              orElse: () => Student.empty) as Student;

  /// Retrieves all tasks corresponding to the exam [examId]
  Future<List<Task>> getTasks({required String examId}) async =>
      List<Map<String, dynamic>>.from(await database!
              .query('tasks', where: 'examId = ?', whereArgs: [examId]))
          .map((e) => TaskData.fromMap(e).toModel())
          .toList();

  Future<List<Answer>> getAnswers(
      {required String submissionId, required String examId}) async {
    // 0. Determine Answers
    final answers = List<Map<String, dynamic>>.from(await database!.query(
            'answers',
            where: 'submissionId = ?',
            whereArgs: [submissionId]))
        .map((e) => AnswerData.fromMap(e))
        .toList();

    // 1. Determine Segments
    final segments = List<Map<String, dynamic>>.from(await database!.query(
            'answer_segments',
            where: 'submissionId = ?',
            whereArgs: [submissionId]))
        .map((e) {
      final data = AnswerSegmentData.fromMap(e);
      final segment = data.toModel();

      return MapEntry(data.taskId, segment);
    });

    // 2. Determine Tasks
    final mTasks = List<Map<String, dynamic>>.from(await database!.query(
            'tasks',
            where:
                'id IN (${answers.map((e) => "'${e.taskId}'").join(",")})'))
        .map((e) => TaskData.fromMap(e).toModel())
        .toList();

    // 3. Create Model
    final answerSegments = <String, List<AnswerSegment>>{};
    for (final segment in segments) {
      answerSegments.putIfAbsent(segment.key, () => <AnswerSegment>[]);
      answerSegments[segment.key]!.add(segment.value);
    }

    // TODO : Handle missing correlation
    return [
      for (final answer in answers)
        answer.toModel(
            task: mTasks.firstWhere((element) => element.id == answer.taskId),
            segments: answerSegments[answer.taskId]!)
    ];
  }

  @override

  /// Returns the details of the desired exam with the identification [examId] from the local persistence layer.
  Future<Exam> getExam(String examId) async {
    if (database == null) {
      await init();
    }

    // 0. Get exam
    // TODO : Handle not existing
    final ExamData exam = List<Map<String, dynamic>>.from(await database!
            .query('exams', where: 'id = ?', whereArgs: [examId]))
        .map((e) => ExamData.fromMap(e))
        .first;

    // 1. Get associated tasks
    final List<Task> mTasks = await getTasks(examId: examId);

    // 2. Get associated participants
    final List<ParticipantData> participants =
        List<Map<String, dynamic>>.from(await database!.rawQuery(
                'SELECT p.id AS id, p.displayName AS displayName, (CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END) AS isCourse FROM participants AS p'
                ' INNER JOIN exams_participants AS ep'
                ' ON ep.participantId = p.id'
                ' LEFT OUTER JOIN courses AS c'
                ' ON c.id = p.id'
                ' WHERE ep.examId = ?',
                [examId]))
            .map((e) {
      if (e["isCourse"] == 1) {
        return CourseData.fromMap(e);
      } else {
        return StudentData.fromMap(e);
      }
    }).toList();

    // 3. Get participants hierarchy
    final List<CourseChildren> children =
        await getChildren(participants.map((e) => e.id).toList());

    // 4. Get Grading table
    final List<GradingTableLowerBoundData> lowerBounds =
        List<Map<String, dynamic>>.from(await database!.query('gt_lower_bounds',
                where: 'examId = ?', whereArgs: [examId]))
            .map((lb) => GradingTableLowerBoundData.fromMap(lb))
            .toList();

    // 5. Create models
    final List<Participant> mParticipants =
        participants.map((e) => e.toModel(children)).toList();
    final List<GradingTableLowerBound> mLowerBounds =
        lowerBounds.map((lb) => lb.toModel()).toList();
    final Exam mExam = exam.toModel(
        participants: mParticipants,
        tasks: mTasks,
        gradingTable: GradingTable(lowerBounds: mLowerBounds));

    return mExam;
  }

  /// Returns all the exams a teacher is allowed to retrieve from the local persistence layer.
  @override
  Future<List<Exam>> getExams() async {
    if (database == null) {
      await init();
    }

    // TODO: Obviously ineffcient
    final List<String> examIds = List<Map<String, dynamic>>.from(
            await database!.query('exams', columns: ['id']))
        .map((e) => e['id'].toString())
        .toList();

    return [for (final examId in examIds) await getExam(examId)];
  }

  @override

  /// Returns all the submissions overviews currently uploaded for the [examId] from the local persistence layer.
  Future<List<Submission>> getSubmissions({required String examId}) async {
    if (database == null) {
      await init();
    }

    // 0. Get submissions
    final List<SubmissionData> submissions = List<Map<String, dynamic>>.from(
            await database!
                .query('submissions', where: 'examId = ?', whereArgs: [examId]))
        .map((e) => SubmissionData.fromMap(e))
        .toList();

    // 1. Get exam
    final Exam exam = await getExam(examId);

    return [
      for (final submission in submissions)
        submission.toModel(
            exam: exam,
            student: await getStudent(submission.studentId),
            answers: await getAnswers(
                examId: submission.examId, submissionId: submission.id))
    ];
  }

  /// Returns the details for the requested submissions [submissionIds] belonging to the exam [examId] from the local persistence layer.
  @override
  Future<List<Submission>> getSubmissionDetails(
      {required String examId, required List<String> submissionIds}) async {
    var res = await getSubmissions(examId: examId);

    return res
        .cast<Submission>()
        .where((element) => submissionIds.contains(element.id))
        .toList();
  }

  @override
  Future<void> setPoints(
      {required String submissionId,
      required String taskId,
      required double achievedPoints}) {
    // TODO: implement setPoints
    throw UnimplementedError();
  }

  @override
  Future<void> setGradingTable({required Exam exam}) async {
    // TODO: implement setGradingTable
    throw UnimplementedError();
  }

  // UPDATE LOCAL PERSISTENCE

  /// Adds the update of the local persistence layer to include [participant] into the [batch].
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addParticipantInsertion(
      {required Batch batch, required Participant participant}) {
    late final String childTable;
    late final ParticipantData dParticipant;

    if (participant is Course) {
      dParticipant = CourseData.fromModel(participant);
      childTable = 'courses';
    } else if (participant is Student) {
      dParticipant = StudentData.fromModel(participant);
      childTable = 'students';
    } else {
      // Triggers rollback of transaction
      throw Exception(
          "The participant type ${participant.runtimeType} is unknown.");
    }

    // Ensure that a participant with that ID exists
    batch.insert('participants', dParticipant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    // Update possibly old participant data
    batch.update('participants', dParticipant.toMap(),
        where: 'id = ?', whereArgs: [dParticipant.id]);

    batch.insert(childTable, {"id": participant.id},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Adds the update of the local persistence layer to include [task] into the [batch].
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addTaskInsertion(
      {required Batch batch, required Task task, required Exam exam}) {
    final dTask = TaskData.fromModel(task, exam);
    // Ensure that a task with that ID exists
    batch.insert('tasks', dTask.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    // Update possibly old task data
    batch
        .update('tasks', dTask.toMap(), where: 'id = ?', whereArgs: [dTask.id]);
  }

  /// Adds the update of the local persistence layer to include [lowerBound] nto the [batch].
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addGradingTableLowerBoundInsertion(
      {required Batch batch,
      required GradingTableLowerBound lowerBound,
      required Exam exam}) {
    final dLb = GradingTableLowerBoundData.fromModel(lowerBound, exam);
    // Ensure that a task with that ID exists
    batch.insert('gt_lower_bounds', dLb.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Adds the update of the local persistence layer to include [exam] into the [batch].
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addExamInsertion({required Batch batch, required Exam exam}) {
    // 1. Insert exam
    // Ensure that an exam with that ID exists
    final dExam = ExamData.fromModel(exam);
    batch.insert('exams', ExamData.fromModel(exam).toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    // Update possibly old exam data
    batch
        .update('exams', dExam.toMap(), where: 'id = ?', whereArgs: [dExam.id]);

    // 2. Insert tasks
    for (final task in exam.tasks) {
      _addTaskInsertion(batch: batch, task: task, exam: exam);
    }

    // 2a. Remove old data
    // Scenario : Teacher creates an exam. After some initial work on the exam, it is decided to remove a task from the exam.
    batch.delete('tasks',
        where:
            'examId = ? AND NOT id IN (${exam.tasks.map((e) => "'${e.id}'").join(",")})');

    // 3. Insert participants
    // "Dangling" participants are not a problem here. It is just required, that we know of linked participants.
    for (final participant in exam.participants) {
      _addParticipantInsertion(batch: batch, participant: participant);
    }

    // 4. Delete existing grading table
    // The grading table is only used and edited by one part of the application
    batch.delete('gt_lower_bounds', where: 'examId = ?', whereArgs: [dExam.id]);

    // 4a. Insert new grading table
    for (final lowerBound in exam.gradingTable.lowerBounds) {
      _addGradingTableLowerBoundInsertion(
          batch: batch, lowerBound: lowerBound, exam: exam);
    }
  }

  /// Adds the update of the local persistence layer to include [segment] into the [batch].
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addAnswerSegmentInsertion(
      {required Batch batch,
      required Submission submission,
      required Task task,
      required AnswerSegment segment}) {
    final dSegment = AnswerSegmentData.fromModel(
        submission: submission, task: task, segment: segment);

    batch.insert('answer_segments', dSegment.toMap());
  }

  /// Adds the update of the local persistence layer to include [answer] into the [batch].
  /// Importantly, present data is only overridden, if it is older.
  /// The only exception are the segments, as these are first deleted and then recreated.
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addAnswerInsertion(
      {required Batch batch,
      required Answer answer,
      required Submission submission}) {
    // 1. Insert Answer
    final dAnswer = AnswerData.fromModel(submission: submission, model: answer);

    // Ensure that an answer with that ID exists
    batch.insert('answers', dAnswer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    // Update possibly old answers data.
    // The age is determined by the last update.
    // We only update, if the local persistence layer lacks behind.
    batch.update('answers', dAnswer.toMap(),
        where: 'taskId = ? AND submissionId = ? AND updatedAt < ?',
        whereArgs: [dAnswer.taskId, dAnswer.submissionId, dAnswer.updatedAt]);

    // 2. Cleanup (pot.) old segments
    batch.delete('answer_segments',
        where: 'submissionId = ? AND taskId = ?',
        whereArgs: [submission.id, answer.task.id]);

    // 3. Insert segments
    for (final segment in answer.segments) {
      _addAnswerSegmentInsertion(
          batch: batch,
          submission: submission,
          task: answer.task,
          segment: segment);
    }
  }

  /// Adds the update of the local persistence layer to include [submission] into the [batch].
  /// Importantly, present data is only overridden, if it is older.
  /// The changes are only made effective, if the [batch] successfully commits.
  void _addSubmissionInsertion(
      {required Batch batch, required Submission submission}) {
    // 1. Insert Exam
    _addExamInsertion(batch: batch, exam: submission.exam);

    // 2. Insert submission

    // Ensure that a submission with that ID exists
    final dSubmission = SubmissionData.fromModel(model: submission);
    batch.insert('submissions', dSubmission.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    // Update possibly old submission data.
    // The age is determined by the last update.
    // We only update, if the local persistence layer lacks behind.
    batch.update('submissions', dSubmission.toMap(),
        where: 'id = ? AND updatedAt < ?',
        whereArgs: [dSubmission.id, dSubmission.updatedAt]);

    // 3. Insert answers
    for (final answer in submission.answers) {
      _addAnswerInsertion(batch: batch, answer: answer, submission: submission);
    }

    // 4. Insert student
    _addParticipantInsertion(batch: batch, participant: submission.student);
  }

  /// Inserts the [submissions] into the local persistence layer.
  Future<void> insertSubmissions(
      {required List<Submission> submissions}) async {
    if (database == null) {
      await init();
    }

    await database!.transaction((txn) async {
      final eBatch = txn.batch();
      for (final submission in submissions) {
        _addSubmissionInsertion(batch: eBatch, submission: submission);
      }

      eBatch.commit(noResult: true);
    });
  }

  /// Inserts the [exams] into the local persistence layer.
  Future<void> insertExams({required List<Exam> exams}) async {
    if (database == null) {
      await init();
    }

    await database!.transaction((txn) async {
      // 1. Insert exams
      final eBatch = txn.batch();
      for (final exam in exams) {
        _addExamInsertion(batch: eBatch, exam: exam);
      }

      eBatch.commit(noResult: true);
    });
  }

  @override
  Future<void> uploadExam({required NewExamDTO exam}) {
    // TODO: implement uploadExam
    throw UnimplementedError();
  }

  @override
  Future<void> updateExam({required NewExamDTO exam, required String examId}) {
    // TODO: implement updateExam
    throw UnimplementedError();
  }

  @override
  Future<void> uploadRemark(
      {required String submissionId, required String data}) {
    // TODO: implement uploadRemark
    throw UnimplementedError();
  }

  @override
  Future<void> publishExam({required String examId, DateTime? publishDate}) {
    // TODO: implement publishExam
    throw UnimplementedError();
  }

  @override
  Future<List<Course>> getCourses() {
    // TODO: implement getCourses
    throw UnimplementedError();
  }
}
