import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../services/local_database.dart';
import '../controllers/auth_controller.dart';

class AskAiView extends StatefulWidget {
  const AskAiView({super.key});

  @override
  State<AskAiView> createState() => _AskAiViewState();
}

class _AskAiViewState extends State<AskAiView> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  String? _currentSessionId;
  List<Map<String, dynamic>> _chatSessions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGreeting();
    });
  }

  void _initializeGreeting() {
    _loadChatSessions();
    final auth = Provider.of<AuthController>(context, listen: false);
    final userName = auth.currentUser?.name ?? 'Brother';
    setState(() {
      _messages.add({
        'role': 'ai',
        'text': 'Hello $userName, How can I help you today',
      });
    });
  }

  Future<void> _loadChatSessions() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final userId = auth.currentUser?.id ?? 'local';
    final sessions = await LocalDatabase.instance.getUserChatSessions(userId);
    setState(() {
      _chatSessions = sessions;
    });
  }

  Future<void> _loadSession(String sessionId) async {
    final messages = await LocalDatabase.instance.getChatMessages(sessionId);
    setState(() {
      _currentSessionId = sessionId;
      _messages = messages
          .map((m) => {'role': m['role'], 'text': m['text']})
          .toList();
    });
  }

  Future<void> _saveCurrentSession(String title) async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final userId = auth.currentUser?.id ?? 'local';
    final db = LocalDatabase.instance;
    final sessionId = _currentSessionId ?? const Uuid().v4();

    if (_currentSessionId == null) {
      await db.createChatSession(sessionId, userId, title);
    } else {
      await db.updateChatSessionTitle(sessionId, title);
    }

    for (var msg in _messages) {
      if (msg['text'] == 'Thinking...' || msg['isLoading'] == true) continue;
      await db.saveChatMessage(sessionId, msg['role'], msg['text']);
    }

    setState(() {
      _currentSessionId = sessionId;
    });
    await _loadChatSessions();
  }

  Future<bool> _onWillPop() async {
    if (_messages.length <= 1) return true;
    if (_currentSessionId != null) {
      return await _showSaveDialog();
    }
    return await _showSaveDialog();
  }

  Future<bool> _showSaveDialog() async {
    final titleController = TextEditingController();

    if (_currentSessionId != null) {
      final session = _chatSessions.firstWhere(
        (s) => s['id'] == _currentSessionId,
        orElse: () => {},
      );
      titleController.text = session['title'] ?? 'Chat';
    } else {
      titleController.text = '';
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save Chat?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter a title to save this conversation:'),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Chat Title',
                    hintText: 'e.g., Budget Planning',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Discard',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  if (titleController.text.trim().isEmpty) {
                    titleController.text = 'Untitled Chat';
                  }
                  await _saveCurrentSession(titleController.text);
                  navigator.pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD30022),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _textController.clear();
      _messages.add({'role': 'ai', 'text': 'Thinking...', 'isLoading': true});
    });

    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      final userId = auth.currentUser?.id ?? 'local';

      final db = LocalDatabase.instance;
      final contextData = await db.getFinancialContext(userId);

      final response = await ApiService.post('/ai/chat', {
        'message': text,
        'context': contextData,
      });

      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m['isLoading'] == true);
          _messages.add({
            'role': 'ai',
            'text':
                response['reply'] ?? 'Sorry, I am unable to answer right now.',
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m['isLoading'] == true);
          _messages.add({
            'role': 'ai',
            'text': 'Error connecting to Jordan Bhai: $e',
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final allow = await _onWillPop();
        if (allow) {
          navigator.pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFD30022),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (await _onWillPop()) {
                navigator.pop();
              }
            },
          ),
          title: const Text(
            'Jordan Bhai',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.history, color: Colors.white),
              onSelected: (sessionId) {
                if (sessionId == 'new') {
                  setState(() {
                    _currentSessionId = null;
                    _messages.clear();
                    _initializeGreeting();
                  });
                } else {
                  _loadSession(sessionId);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'new',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('New Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  ..._chatSessions.map((session) {
                    return PopupMenuItem<String>(
                      value: session['id'],
                      child: Text(
                        session['title'] ?? 'Untitled',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ];
              },
            ),
          ],
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isAi = msg['role'] == 'ai';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isAi
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        if (isAi)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: SvgPicture.asset(
                                'assets/jordan_bhai.svg',
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2F8),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomRight: isAi
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                bottomLeft: isAi
                                    ? Radius.zero
                                    : const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              msg['text'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        if (!isAi)
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(left: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E0E0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_messages.isNotEmpty && _messages.last['role'] == 'user')
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child: SvgPicture.asset(
                          'assets/jordan_bhai.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF2F8),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(width: 4),
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ask me a question',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cleaning_services_outlined),
                          onPressed: () {
                            _textController.clear();
                          },
                          color: Colors.black87,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _handleSend,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
