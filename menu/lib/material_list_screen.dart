import 'package:flutter/material.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/data/providers.dart';

class MaterialListScreen extends ConsumerWidget {
  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialList = ref.watch(materialListProvider);

    return Scaffold(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    ref
                                        .read(selectButtonProvider.notifier)
                                        .state = 'edit';
                                    ref
                                        .read(materialProvider.notifier)
                                        .updateMaterial(material);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MaterialCreateScreen(
                                                user: currentUser!),
                                      ),
                                    );
                                  }),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  MaterialRepository(currentUser!)
                                      .deleteMaterial(material);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => const Text('エラーが発生しました'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(selectButtonProvider.notifier).state = 'Resist';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialCreateScreen(user: currentUser!),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
