import 'package:flutter/material.dart';
import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/view_model/material_list_view_model.dart';

class MaterialListScreen extends ConsumerWidget {
  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialList = ref.watch(materialListProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              materialList.when(
                data: (materials) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      MaterialRepository(currentUser!)
                                          .deleteMaterial(material);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => CircularProgressIndicator(),
                error: (error, stackTrace) => Text('エラーが発生しました: $error'),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              ref.read(selectButtonProvider.notifier).state = 'Resist';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MaterialCreateScreen(user: currentUser!),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
