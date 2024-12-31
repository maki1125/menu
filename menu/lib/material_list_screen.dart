import 'package:flutter/material.dart';
import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/material_create_screen.dart';

class MaterialListScreen extends ConsumerWidget {
  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialList = ref.watch(materialListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('材料一覧'),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          materialList.when(
            data: (materials) {
              return Expanded(
                child: ListView.builder(
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];

                    return ListTile(
                      title: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                              '   ${material.name ?? ''}      ${material.quantity?.toString()}${material.unit}     ${material.price?.toString()}円'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              MaterialRepository(currentUser!)
                                  .deleteMaterial(material);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => CircularProgressIndicator(),
            error: (error, stackTrace) => Text('エラーが発生しました'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaterialCreateScreen(),
                  ),
                );
              },
              child: const Text('追加'),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
