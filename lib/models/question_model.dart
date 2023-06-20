//we will create our question model here
//create a simple class
class Question {
  final String id;
  final String title;
  final Map<String, bool> options;

  Question({
    required this.id,
    required this.title,
    required this.options,
  });

  @override
  String tostring() {
    return 'Question(id: $id, title: $title, options: $options)';
  }
}
