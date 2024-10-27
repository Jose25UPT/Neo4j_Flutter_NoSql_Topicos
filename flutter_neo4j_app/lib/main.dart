import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Neo4j',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Neo4j'),
        ),
        body: NodesList(),
      ),
    );
  }
}

class NodesList extends StatefulWidget {
  @override
  _NodesListState createState() => _NodesListState();
}

class _NodesListState extends State<NodesList> {
  List<dynamic> nodes = [];
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    fetchNodes();
  }

  Future<void> fetchNodes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/nodes'));
    if (response.statusCode == 200) {
      setState(() {
        nodes = json.decode(response.body);
        isLoading = false; // Cambiar a false al terminar la carga
      });
    } else {
      setState(() {
        isLoading = false; // Cambiar a false si hay un error
      });
      throw Exception('Failed to load nodes');
    }
  }

  Future<void> addNode(String name, String type, String description) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/nodes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'type': type,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      fetchNodes(); // Recargar los nodos después de agregar uno nuevo
    } else {
      throw Exception('Failed to add node');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // Indicador de carga
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(nodes[index]['name'] ?? 'Unnamed Node'),
                subtitle: Text('Tipo: ${nodes[index]['type'] ?? 'N/A'}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(nodes[index]['name']),
                      content: Text('Tipo: ${nodes[index]['type']}\nDescripción: ${nodes[index]['description'] ?? 'N/A'}'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cerrar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String name = '';
                  String type = '';
                  String description = '';
                  return AlertDialog(
                    title: Text('Agregar Nodo'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(labelText: 'Nombre'),
                          onChanged: (value) => name = value,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Tipo'),
                          onChanged: (value) => type = value,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Descripción'),
                          onChanged: (value) => description = value,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          addNode(name, type, description);
                          Navigator.of(context).pop();
                        },
                        child: Text('Agregar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancelar'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Agregar Nodo'),
          ),
        ),
      ],
    );
  }
}
