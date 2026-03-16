import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';
import '../../global/global_api.dart';

class AiChatProvider extends ChangeNotifier {
  bool _isOpen = false;
  bool _isLoading = false;
  
  List<ChatMessage> _messages = [
    ChatMessage(
      role: 'ai',
      content: 'Hi! I am your HIMS Agent. Ask me questions about patient data or revenue, like "Which service made the most revenue in July 2025?"',
    )
  ];

  bool get isOpen => _isOpen;
  bool get isLoading => _isLoading;
  List<ChatMessage> get messages => _messages;

  void toggleChat() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void openChat() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  void closeChat() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages = [
      ChatMessage(
        role: 'ai',
        content: 'Chat history cleared. How can I help you today?',
      )
    ];
    notifyListeners();
  }

  Future<void> sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(role: 'user', content: query));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${GlobalApi.baseUrl}/ai/query-data'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add your authorization header here if needed
          // 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'query': query,
        }),
      );

      print('AI API Response Status: ${response.statusCode}');
      print('AI API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Assuming your API returns something like { "success": true, "answer": "..." }
        // or just the answer directly. Adjust this depending on your actual API response structure.
        if (data['success'] == true && data['answer'] != null) {
          _messages.add(ChatMessage(
            role: 'ai',
            content: data['answer'].toString(),
          ));
        } else if (data['message'] != null) {
          _messages.add(ChatMessage(
             role: 'ai',
             content: data['message'].toString(),
          ));
        } else if (data['answer'] != null) {
           _messages.add(ChatMessage(
             role: 'ai',
             content: data['answer'].toString(),
          ));
        } else {
           _messages.add(ChatMessage(
            role: 'ai',
            content: 'Received an unexpected response format from the server.',
          ));
        }
      } else {
        _messages.add(ChatMessage(
          role: 'ai',
          content: 'Server error: ${response.statusCode}',
        ));
      }
    } catch (error) {
       print('Error calling AI API: $error');
      _messages.add(ChatMessage(
        role: 'ai',
        content: "Sorry, I couldn't process your request at this time. Please check your internet connection.",
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
