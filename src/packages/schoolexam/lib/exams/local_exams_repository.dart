import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/exams/models/grading_table_lower_bound.dart';
import 'package:schoolexam/exams/persistence/answer_segment_data.dart';
import 'package:schoolexam/exams/persistence/correctable_data.dart';
import 'package:schoolexam/exams/persistence/exam_data.dart';
import 'package:schoolexam/exams/persistence/grading_table_lower_bound_data.dart';
import 'package:schoolexam/exams/persistence/participant_data.dart';
import 'package:schoolexam/exams/persistence/task_data.dart';
import 'package:sqflite/sqflite.dart';

class LocalExamsRepository extends ExamsRepository {
  Database? database;

  Future<void> init() async {
    final path = p.join(await getDatabasesPath(), 'exams_repository.db');

    // DEBUG PURPOSES
    bool dbExists = await File(path).exists();

    if (!dbExists) {
      // Copy from asset
      ByteData data =
          await rootBundle.load(p.join("assets", "databases", "dummy.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }
    //

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
          'CREATE TABLE IF NOT EXISTS submissions(id TEXT PRIMARY KEY, examId TEXT NOT NULL, data TEXT NOT NULL, studentId TEXT NOT NULL, achievedPoints REAL DEFAULT 0 NOT NULL, status TEXT NOT NULL, FOREIGN KEY(examId) REFERENCES exams(id) ON DELETE CASCADE, FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS answer_segments(submissionId TEXT NOT NULL, taskId TEXT NOT NULL, segmentId INT NOT NULL, startPage INT NOT NULL, endPage INT NOT NULL, startY DOUBLE NOT NULL, endY DOUBLE NOT NULL, PRIMARY KEY(segmentId, submissionId, taskId), FOREIGN KEY(submissionId) REFERENCES submissions(id) ON DELETE CASCADE, FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS answers(submissionId TEXT NOT NULL, taskId TEXT NOT NULL, achievedPoints REAL DEFAULT 0 NOT NULL, status TEXT NOT NULL, PRIMARY KEY(submissionId, taskId), FOREIGN KEY(submissionId) REFERENCES submissions(id) ON DELETE CASCADE, FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE)');
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
        '	WHERE cc.courseId IN (${courses.map((e) => "\'$e\'").join(",")})'
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

  // TODO : Handle not existing
  Future<Student> getStudent(String id) async => List<
          Map<String,
              dynamic>>.from(await database!.rawQuery(
          'SELECT p.id, p.displayName FROM participants p INNER JOIN students s ON s.id = p.id WHERE s.id = ?',
          [id]))
      .map((e) => StudentData.fromMap(e))
      .first
      .toModel([]) as Student;

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
                'id IN (${answers.map((e) => "\'${e.taskId}\'").join(",")})'))
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

  /// Inserts the [exams] into the local persistence layer.
  /// However, this may cascade into a deletion of referencing entities.
  Future<void> insertExams({required List<Exam> exams}) async {
    if (database == null) {
      await init();
    }

    await database!.transaction((txn) async {
      // 1. Insert exams
      final eBatch = txn.batch();
      for (final exam in exams) {
        // Ensure that an exam with that ID exists
        final dExam = ExamData.fromModel(exam);
        eBatch.insert('exams', ExamData.fromModel(exam).toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        // Update possibly old exam data
        eBatch.update('exams', dExam.toMap(),
            where: 'id = ?', whereArgs: [dExam.id]);

        // 2. Insert tasks
        for (final task in exam.tasks) {
          final dTask = TaskData.fromModel(task, exam);
          // Ensure that a task with that ID exists
          eBatch.insert('tasks', dTask.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore);
          // Update possibly old task data
          eBatch.update('tasks', dTask.toMap(),
              where: 'id = ?', whereArgs: [dTask.id]);
        }
        // 2a. Delete tasks
        // Scenario : Teacher creates an exam. After some initial work on the exam, it is decided to remove a task from the exam.
        eBatch.delete('tasks',
            where:
                'examId = ? AND NOT id IN (${exam.tasks.map((e) => "\'${e.id}\'").join(",")})');

        // 3. Insert participants
        // "Dangling" participants are not a problem here. It is just required, that we know of linked participants.
        for (final participant in exam.participants) {
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
          eBatch.insert('participants', dParticipant.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore);
          // Update possibly old participant data
          eBatch.update('participants', dParticipant.toMap(),
              where: 'id = ?', whereArgs: [dParticipant.id]);

          eBatch.insert(childTable, {"id": participant.id},
              conflictAlgorithm: ConflictAlgorithm.ignore);

          // 4.a Delete old grading table

          eBatch.delete('gt_lower_bounds',
              where: 'examId = ?', whereArgs: [exam.id]);

          // 4.b insert new grading table
          for (final lb in exam.gradingTable.lowerBounds) {
            final dLb = GradingTableLowerBoundData.fromModel(lb, exam);
            eBatch.insert('gt_lower_bounds', dLb.toMap());
          }
        }
      }

      eBatch.commit(noResult: true);
    });
  }

  @override
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
  Future<void> setPoints({required String submissionId,  required String taskId, required double achievedPoints}) {
    // TODO: implement setPoints
    throw UnimplementedError();
  }

  @override
  Future<void> setGradingTable({required Exam exam}) async {
    // TODO: implement setGradingTable
    throw UnimplementedError();
  }
}
