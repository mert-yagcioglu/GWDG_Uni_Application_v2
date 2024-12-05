import 'package:flutter/material.dart';
import 'package:gwdg_fdo_application/views/detection.dart';
import '../views/add_pid_credential.dart';
import '../views/add_repo.dart';
import '../views/camera_screen.dart';
import '../views/list_fdo.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
  {'role': 'bot', 'message': 'Merhaba! Ben GWDG Chatbot :)\nSana nasıl yardımcı olabilirim?'},
  {'role': 'bot', 'message': 'Aşağıdaki sekmeler hakkında sana bilgi verebilirim.:\n- List FDO\n- Create FDO\n- Fast Detection\n- Add Repo\n- Add PID Credentials\n- Log Out'},
  ];

  final Map<String, String> chatbotResponses = {
    'List FDO': 'Bu sekme, mevcut FDO nesnelerini listelemenizi ve detaylarını incelemenizi sağlar.',
    'Create FDO': 'Bu sekmede yeni bir FDO nesnesi oluşturabilirsiniz.',
    'Fast Detection': 'Bu sekme hızlı algılama yaparak FDO nesnelerini tanımlamanızı sağlar.',
    'Add Repo': 'Veri tabanı bağlantısı eklemek ve yeni bir repo oluşturmak için bu sekmeyi kullanabilirsiniz.',
    'Add PID Credentials': 'PID kimlik bilgilerinizi eklemek ve düzenlemek için bu sekme kullanılır.',
    'Log Out': 'Uygulamadan çıkış yapmanızı sağlar.',
  };

  final Map<String, Widget> navigationRoutes = {
    'List FDO': ListFDOScreen(),
    'Create FDO': CameraScreen(),
    'Fast Detection': DetectionPage(),
    'Add Repo': AddRepoScreen(),
    'Add PID Credentials': AddPidCredentialScreen(),
  };

  void _handleMessage(String userMessage) {
    setState(() {
      _messages.add({'role': 'user', 'message': userMessage});
    });

    String botResponse = 'Üzgünüm, bunu anlayamadım.\n Aşağıdaki sekmeler hakkında sana bilgi verebilirim:\n- List FDO\n- Create FDO\n- Fast Detection\n- Add Repo\n- Add PID Credentials\n- Log Out';
    String? matchedKey;

    chatbotResponses.forEach((key, value) {
      if (userMessage.toLowerCase().contains(key.toLowerCase())) {
        botResponse = value;
        matchedKey = key;
      }
    });

    setState(() {
      _messages.add({
        'role': 'bot',
        'message': botResponse,
        'button': matchedKey != null ? matchedKey : null,
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message']!,
                          style: TextStyle(color: isUser ? Colors.white : Colors.black),
                        ),
                        if (message['button'] != null)
                          TextButton(
                            onPressed: () {
                              final matchedKey = message['button'];
                              if (navigationRoutes.containsKey(matchedKey)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => navigationRoutes[matchedKey]!,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Bu sekmeye git →',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Sekmeler hakkında soru sorun...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleMessage(_messageController.text),
                  child: Text('Gönder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
