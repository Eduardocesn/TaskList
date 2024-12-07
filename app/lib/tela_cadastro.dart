import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaCadastro extends StatefulWidget {
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  @override
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  bool status = false;

  final List<Map<String, dynamic>> statusOptions = [
    {'label': 'Concluída', 'value': true},
    {'label': 'Pendente', 'value': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar nova tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
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
                  decoration: const InputDecoration(labelText: 'Status'),
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
                ElevatedButton(onPressed: _saveItem, child: const Text('Salvar')),
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
          .add(({'nome': nome, 'status': status}));

      Navigator.pop(context);
    }
  }
}
