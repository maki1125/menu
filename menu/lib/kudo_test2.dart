import 'package:flutter/material.dart';

class CardListExample extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card with Text and Image")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index){

        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              print("Card tapped!");
            },
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListTile(
                  leading: Icon(Icons.account_circle, size: 40), // 左のアイコン
                title: Text("User Name"), // タイトル
                subtitle: Text("This is a subtitle."), // サブタイトル
                trailing: Icon(Icons.arrow_forward), 
                ),),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                   child:Image.asset(
                      'assets/0.jpeg',
                      //height: 100,
                      //width: 50,
                      fit: BoxFit.cover,
                   ),
                  )
                  
                  )
                
              ],
            ),
          ),
        );
        }
      ),
      
    );
  }
}