import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});    //constuctor

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {  //store logic
  final _formKey = GlobalKey<FormState>();      //control form

  TextEditingController nameController = TextEditingController(); //store input from user
  TextEditingController courseController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  void submitForm() /*run when press submit*/ {
    if (_formKey.currentState!.validate()) {  //validate fields
      showDialog(   //open mini popup window
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Form Submitted"),
            content: const Text("Your form has been submitted successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      nameController.clear();
      courseController.clear();
      idController.clear();
      commentController.clear(); //clear drom when submitted
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    courseController.dispose();
    idController.dispose();
    commentController.dispose();
    super.dispose();
  }   //press another page data cleared

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Student Feedback Form",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Please fill in the form below",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: "Course",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Course cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: "Student ID",
                  filled: true, //painting
                  fillColor: Colors.white, //choose
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Student ID cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Comment",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Comment cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: submitForm,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}