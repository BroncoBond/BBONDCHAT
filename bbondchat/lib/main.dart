//make sure to flutter run
// if you run on 2 dif instances, you can message using socket.io
// Import necessary packages
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// Entry point of the application. Creates and runs the Flutter app.
void main() {
  runApp(MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

// StatefulWidget for the chat screen
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// State class for the chat screen
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    // Create a socket connection to the server
    // Replace 'http://localhost:3000' with your actual server address
    socket = io.io('http://localhost:50084', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect to the socket
    socket.connect();

    // Listen for incoming messages from the server
    socket.on('message', (data) {
      print('Received message: $data');
      String message = data.toString();
      setState(() {
        _messages.add(message);
      });
    });
  }

  // Send a message from the current user
  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      String message = 'You: ${_textController.text}';
      setState(() {
        _messages.add(message);
      });
      // Emit the message to the server
      socket.emit('message', message);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    // Dispose of the text controller and disconnect from the socket when the widget is disposed
    _textController.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bronco Bond DM',
          style: TextStyle(
            fontSize: 50.0, // Set the font size to 24
            color: Colors.green[900], // Set the color to dark green
            fontFamily:
                'YourCuteFont', // Replace 'YourCuteFont' with the actual font family you want to use
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Determine if the message belongs to the current user
                bool isMyMessage = _messages[index].startsWith('You: ');

                return ListTile(
                  title: Align(
                    alignment: isMyMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color:
                            isMyMessage ? Colors.lightGreen[900] : Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _messages[index],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  // Align messages to the right if they belong to the current user
                  trailing: isMyMessage ? null : Icon(Icons.person),
                  // Align messages to the left if they belong to the other person
                  leading: isMyMessage ? Icon(Icons.person) : null,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
