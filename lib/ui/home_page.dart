import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gif_seacher/ui/git_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _search;

  int _offSet = 0;
  static const String apiUrl = 'https://api.giphy.com/v1/gifs';

  @override
  void initState() {
    _getGIfs().then((value) => print(value));
  }

  Future<Map> _getGIfs() async{
    String apiKey = dotenv.get('API_KEY', fallback: null);
    http.Response response;
    if(_search == null || _search == ''){
      response = await http.get(Uri.parse('$apiUrl/trending?api_key=$apiKey&limit=20&rating=g'));
    }else{
      response = await http.get(Uri.parse('$apiUrl/search?api_key=$apiKey&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en'));
    }
    return json.decode(response.body);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child:  TextField(
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
              decoration: const InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                  )
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGIfs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                  );
                  default:
                    if(snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data){
    if(_search == null){
      return data.length;
    } else{
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index){
        if(_search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => GifPage(gifData: snapshot.data["data"][index]))
              );
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            )
          );
        }else{
          return Container(
            child: GestureDetector(
              onTap: (){
                setState(() {
                  _offSet += 19;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text("Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                ],
              ),
            ),
          );
        }

      }
    );
  }
}
