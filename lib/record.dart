import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  String? title;
  Timestamp? start;
  int? reps;
  int? buttonsOrNotches;
  List<RecordMessage>? messages;
  bool? goals;

  Record({
    this.title,
    this.start,
    this.reps,
    this.buttonsOrNotches,
    this.messages,
    this.goals,
  });

  factory Record.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    //convert messages into map
    List<RecordMessage>? messagesAsRecords = [];
    if (data?['messages'] is Iterable) {
      var messagesMap = List.from(data?['messages']);
      messagesMap.forEach((element) {
        messagesAsRecords.add(RecordMessage.fromMap(element));
      });
    }

    return Record(
      title: data?['title'],
      start: data?['start'],
      reps: data?['reps'],
      buttonsOrNotches: data?['buttonsOrNotches'],
      messages: messagesAsRecords,
      goals: data?['goals'],
    );
  }

  Map<String, dynamic> toFirestore() {
    List<Map<String, dynamic>> messagesAsMap = [];
    messages?.forEach((element) {
      messagesAsMap.add(element.toMap());
    });
    return {
      if (title != null) "title": title,
      if (start != null) "start": start,
      if (reps != null) "reps": reps,
      if (buttonsOrNotches != null) "buttonsOrNotches": buttonsOrNotches,
      if (messages != null) "messages": messagesAsMap,
      if (goals != null) "goals": goals,
    };
  }
}

class RecordMessage {
  Timestamp? datetime;
  String? message;
  int? rep;
  bool? correctPress;

  RecordMessage({
    this.datetime,
    this.message,
    this.rep,
    this.correctPress,
  });

  factory RecordMessage.fromMap(Map<String, dynamic> map) {
    return RecordMessage(
      datetime: map["datetime"],
      message: map["message"],
      rep: map["rep"],
      correctPress: map["correctPress"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (datetime != null) "datetime": datetime,
      if (message != null) "message": message,
      if (rep != null) "rep": rep,
      if (correctPress != null) "correctPress": correctPress,
    };
  }
}
