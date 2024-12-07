import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaTask extends StatefulWidget {
  const TelaTask({super.key});

  @override
  State<TelaTask> createState() => _TelaTaskState();
}

class _TelaTaskState extends State<TelaTask> {
  final _formKey = GlobalKey<FormState>();
  late String nome;
  late bool status;
  late String id;

  final List<Map<String, dynamic>> statusOptions = [
    {'label': 'Concluída', 'value': true},
    {'label': 'Pendente', 'value': false},
  ];

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    id = args['id'];
    nome = args['nome'];
    status = args['status'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: nome,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira o nome';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    nome = value!;
                  },
                ),
                DropdownButtonFormField<bool>(
                  value: status,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: statusOptions.map((option) {
                    return DropdownMenuItem<bool>(
                      value: option['value'],
                      child: Text(option['label']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                  onSaved: (value) {
                    status = value!;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione um status';
                    }
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(onPressed: _saveItem, child: Text('Salvar')),
              ],
            )),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(id)
          .update(({'nome': nome, 'status': status}));

      Navigator.pop(context);
    }
  }
}
