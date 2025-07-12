import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/list_cubit.dart';
import '../../models/list_item/list_item.dart';
import '../../utils/toast_utils.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  void initState() {
    super.initState();
    // context.read<ListCubit>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ListCubit>().refreshItems(),
          ),
        ],
      ),
      body: BlocConsumer<ListCubit, ListState>(
        listener: (context, state) {
          if (state.error != null) {
            context.showErrorToast(state.error!);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No items available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pull to refresh or tap the refresh button',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ListCubit>().refreshItems(),
            child: ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _ListItemWidget(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ListItemWidget extends StatelessWidget {
  const _ListItemWidget({required this.item});

  final ListItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: item.imageUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
            : const CircleAvatar(child: Icon(Icons.image)),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: item.createdAt != null
            ? Text(
                '${item.createdAt!.day}/${item.createdAt!.month}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        onTap: () {
          // Handle item tap
          context.showInfoToast('点击了 ${item.title}');
        },
      ),
    );
  }
}
