import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:hackathon/dao/artiste_dao.dart';
import 'package:hackathon/domain/artiste.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackathon/ColorCustom.dart';

void main() async {
}



class InfoArtiste extends StatelessWidget {

  InfoArtiste.artiste(Artiste artiste){
    init(artiste);
  }

  String? id;
  Artiste? ar;
  String? nom;
  String? langue;
  String? pays;
  String? edition;

  String? deezer;
  String? spotify;
  String errorD = '';

  void init(Artiste a) {
    langue = a.langue.toString();
    pays = a.pays.toString();
    edition = a.edition.toString();
    nom = a.nom.toString();
    deezer = a.deezer.toString();
    spotify = a.spotify.toString();
  }

  void error(ErrorDescription e) {
    print(e);
    errorD = e.toString();
  }
  void testinitinfo(){
    langue = "fr";
    pays = "france";
    edition = "ed1";
    nom = "jean";
    deezer = "deezer";
    spotify = "spo";
    errorD ='';
  }

  Widget cond(){
    return (this.errorD.isEmpty ? getInfo() : displayError());
  }
  Widget getInfo() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children:  <Widget>[
        infoList("nom", nom!),
        infoList("langue", langue!),
        infoList("pays", pays!),
        infoList("edition", edition!),
        infolink("deezer", "https://www.deezer.com/en/artist/"+deezer!),
        infolink("spotify", 'https:open.spotify.com/album/'+spotify!.substring(14))
       ],
    );
  }
  Widget displayError(){
    return Text("il n'existe aucune information sur cet artiste");
  }

  Widget infolink(String title, String info ){
    return  ListTile(
      title: Text(title),
      trailing: buttonE(title, info),
    );
        }
    Widget infoList(String title, String info ){
    return  ListTile(
      title: Row(
          children:[
            Text(title),
          ],
        ),
      //  horizontalTitleGap: 12.5,
      subtitle: Row(
        children: [
          SizedBox(
              width: 320.0,
          child :Text(info,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style:const TextStyle(fontSize: 20),
          )
          )
        ],
    ),
    );
  }
  Widget buttonE(String app, String url){
  return  ElevatedButton(
      onPressed: () => _launchURL(url),
      child:  Text(app),
    );
  }
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {

    return MaterialApp(

        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: colorCustom,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('info'),
          ),
          body: cond(),

        )
        );
  }
}
