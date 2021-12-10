import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hackathon/domain/notification.dart';
import 'package:hackathon/services/notification_service.dart';

/// Service d'envoie de notifications.
class NotificationSender {
  /// Instance du service
  static final NotificationSender instance = NotificationSender._();

  /// Clé de serveur de Firebase Cloud Messaging
  String? _key;

  /// Crée un service d'envoie de notifications avec la clé de serveur Firebase
  /// Cloud Messaging [key].
  NotificationSender._();

  /// Envoie la [notification] aux clients.
  Future<void> envoyer(NotificationChangement notification) async {
    await _ensureInitialized();
    http.Response response =
        await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: {
              "Authorization": "key=${_key!}",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "to": "/topics/${NotificationService.topicName}",
              "notification": {
                "sound": "default",
                "body": notification.corps,
                "title": notification.titre,
                "content_available": true,
                "priority": "high"
              }
            }));

    if (response.statusCode < 400) {
      return;
    } else {
      throw Exception(response.body.toString());
    }
  }

  /// S'assure que le service est initialisé.
  Future<void> _ensureInitialized() async {
    if (_key == null) {
      String json = await rootBundle.loadString("asset/fcm.json");
      Map<String, dynamic> map = jsonDecode(json);
      _key = map["cle_serveur"];
    }
  }
}

class _TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: NotificationService.instance,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              NotificationService instance =
                  snapshot.data as NotificationService;
              instance.onNotification((notification) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(notification.toString())));
              });
              return _Envoyeur(service: NotificationSender.instance);
            } else {
              return const Text("attente service");
            }
          },
        ),
      ),
    );
  }
}

class _Envoyeur extends StatefulWidget {
  final NotificationSender service;

  const _Envoyeur({Key? key, required this.service}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _EnvoyeurState();
}

class _EnvoyeurState extends State<_Envoyeur> {
  Future<void>? _future;
  String _titre = "";
  String _body = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          enabled: _future == null,
          onChanged: (value) => _titre = value,
        ),
        TextField(
          enabled: _future == null,
          onChanged: (value) => _body = value,
        ),
        MaterialButton(
          child: const Text("envoyer"),
          onPressed: _future != null
              ? null
              : () {
                  setState(() {
                    _future = widget.service.envoyer(
                        NotificationChangement(titre: _titre, corps: _body));
                  });
                  _future!.then((value) {
                    setState(() {
                      _future = null;
                    });
                  });
                },
        )
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(_TestApp());
}