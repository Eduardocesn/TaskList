import 'package:app/tela_cadastro.dart';
import 'package:app/tela_task.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listagem de tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Listagem de tarefas'),
      routes: {
        '/edit': (context) => TelaTask(),
        '/create': (context) => TelaCadastro(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference tasks = firestore.collection('tasks');

    Stream<QuerySnapshot> getTasks() {
      return tasks.snapshots();
    }

    void deleteItem(BuildContext context, String id) async {
      try {
        await tasks.doc(id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa excluído com sucesso')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir a tarefa')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: StreamBuilder<QuerySnapshot>(
              stream: getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Erro ${snapshot.error}");
                } else {
                  var docs = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var task = docs[index];
                        var nome = task['nome'];
                        var status = task['status'];
                        var id = task.id;

                        return Column(
                          children: [
                            ListTile(
                              title: Text(nome),
                              subtitle: Text(
                                  'Status: ${status ? 'Concluída' : 'Pendente'}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Excluir tarefa'),
                                          content: const Text(
                                              'Você tem certeza que deseja excluir essa tarefa?'),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancelar')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  deleteItem(context, id);
                                                },
                                                child: const Text('Excluir'))
                                          ],
                                        );
                                      });
                                },
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/edit',
                                    arguments: {
                                      'id': task.id,
                                      'nome': nome,
                                      'status': status,
                                    });
                              },
                            ),
                            const Divider(),
                          ],
                        );
                      });
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
        child: Icon(Icons.add),
        tooltip: 'Criar nova tarefa',
      ),
    );
  }
}
