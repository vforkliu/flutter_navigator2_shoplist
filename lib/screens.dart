import 'package:flutter/material.dart';
import 'constants.dart';

class CartScreen extends StatelessWidget {
  final ValueChanged<String> onItemTapped ;

  const CartScreen({Key? key, required this.onItemTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: ListView.separated(
          itemBuilder: (_, index) => ListTile(
            onTap: ()=> onItemTapped('Item ${index+index}', ),
            title:  Text('Item ${index+index}'),
            trailing: Container(
                padding: const EdgeInsets.all(6),
                decoration:  BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(' 1 ')),
          ),
          separatorBuilder: (ctx, idx) => const Divider(),
          itemCount: 5),
    );
  }
}

class ItemDetailsScreen extends StatelessWidget {
  final String item;
  const ItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              item,
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Text('$item Details')
        ],
      ),
    );
  }
}

class ItemsListScreen extends StatelessWidget {
  final ValueChanged<String> onItemTapped ;
  final ValueChanged<String> onRouteTapped ;

  const ItemsListScreen({Key? key, required this.onItemTapped, required this.onRouteTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        actions: [
          IconButton(
            onPressed: () => onRouteTapped(cartRoute),
            icon: const Icon(Icons.shopping_cart),
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (_, index) => ListTile(
          onTap: ()=>onItemTapped('Item $index'),
          title: Text('Item $index'),
        ),
        itemCount: 10,
      ),
    );
  }
}
