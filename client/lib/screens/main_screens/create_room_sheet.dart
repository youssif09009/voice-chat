import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/room_api.dart';
import 'voice_room.dart';

// ---------------------------------------------------------------------------
// Public helper — show the sheet
// ---------------------------------------------------------------------------

Future<void> showCreateRoomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreateRoomSheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

class _CreateRoomSheet extends StatefulWidget {
  const _CreateRoomSheet();

  @override
  State<_CreateRoomSheet> createState() => _CreateRoomSheetState();
}

class _CreateRoomSheetState extends State<_CreateRoomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _announcementController = TextEditingController();

  String _selectedCategory = 'social';
  String _selectedCoverEmoji = '🎵';
  bool _isCreating = false;

  // ---- Picker options ----
  static const _categories = [
    ('social', '💬', 'Social'),
    ('gaming', '🎮', 'Gaming'),
    ('music', '🎵', 'Music'),
    ('trending', '🔥', 'Trending'),
    ('vip', '👑', 'VIP'),
  ];

  static const _emojis = [
    '🎵', '🎮', '👑', '🚀', '🌙', '🔥', '💬', '🎧',
    '🏆', '⚡', '🌐', '🎶', '📈', '🕵️', '☕', '🎙',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);

    final room = await RoomApi.instance.createRoom(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim().isEmpty
          ? 'Host'
          : _usernameController.text.trim(),
      hostEmoji: _selectedCoverEmoji,
      coverEmoji: _selectedCoverEmoji,
      maxSlots: 999999, // unlimited
      category: _selectedCategory,
      accentColor: '#8B5CF6',
      announcement: _announcementController.text.trim(),
      isVip: _selectedCategory == 'vip',
      tags: [
        _categories
            .firstWhere((c) => c.$1 == _selectedCategory)
            .$3,
      ],
    );

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create room. Is the server running?'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    // Close sheet then navigate into the new room
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VoiceRoomScreen(roomInfo: room)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12112A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Create a Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set it up and go live instantly',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Room name
              _Label('Room Name'),
              _Field(
                controller: _nameController,
                hint: 'e.g. Chill & Talk',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a room name' : null,
              ),
              const SizedBox(height: 16),

              // Your name
              _Label('Your Name'),
              _Field(
                controller: _usernameController,
                hint: 'e.g. King_Nexus',
              ),
              const SizedBox(height: 16),

              // Announcement
              _Label('Announcement (optional)'),
              _Field(
                controller: _announcementController,
                hint: 'Welcome message for the room...',
              ),
              const SizedBox(height: 20),

              // Category
              _Label('Category'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSelected = _selectedCategory == c.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.$2,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            c.$3,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Cover emoji
              _Label('Cover Emoji'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis.map((e) {
                  final isSelected = _selectedCoverEmoji == e;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCoverEmoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(e,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isCreating
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        ),
                      )
                    : GestureDetector(
                        onTap: _submit,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryPurple,
                                Color(0xFFD946EF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple
                                    .withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mic_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Create & Go Live',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryPurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}
