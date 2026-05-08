import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Agency data model — shared across screens via a simple in-memory store
// ─────────────────────────────────────────────────────────────────────────────

class AgencyStore {
  AgencyStore._();
  static final AgencyStore instance = AgencyStore._();

  AgencyData? agency; // null = no agency created yet

  void create(AgencyData data) => agency = data;
  void clear() => agency = null;
}

class AgencyData {
  final String name;
  final String announcement;
  final String? photoPath; // local file path
  final String id;
  int members;

  AgencyData({
    required this.name,
    required this.announcement,
    this.photoPath,
    required this.id,
    this.members = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Create / Edit Agency Screen
// ─────────────────────────────────────────────────────────────────────────────

class CreateAgencyScreen extends StatefulWidget {
  /// Pass existing agency to edit it instead of creating new.
  final AgencyData? existing;
  const CreateAgencyScreen({super.key, this.existing});

  @override
  State<CreateAgencyScreen> createState() => _CreateAgencyScreenState();
}

class _CreateAgencyScreenState extends State<CreateAgencyScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _annoCtrl;
  XFile? _pickedImage;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _annoCtrl = TextEditingController(text: widget.existing?.announcement ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _annoCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().length >= 5 &&
      _annoCtrl.text.trim().isNotEmpty;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (result != null) setState(() => _pickedImage = result);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final photoPath = _pickedImage?.path ?? widget.existing?.photoPath;
    final id = widget.existing?.id ??
        '1${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    AgencyStore.instance.create(AgencyData(
      name: _nameCtrl.text.trim(),
      announcement: _annoCtrl.text.trim(),
      photoPath: photoPath,
      id: id,
      members: widget.existing?.members ?? 0,
    ));

    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isEdit ? 'Agency updated!' : 'Agency created!'),
      backgroundColor: AppColors.primaryPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Navigator.pop(context, true); // return true = success
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingPhoto = widget.existing?.photoPath != null;
    final showPhoto = _pickedImage != null || hasExistingPhoto;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          _isEdit ? 'Edit Agency' : 'Create an Agency',
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // ── Photo picker ─────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: showPhoto
                                      ? AppColors.primaryPurple.withValues(alpha: 0.4)
                                      : Colors.transparent,
                                  width: 2),
                            ),
                            child: showPhoto
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: _pickedImage != null
                                        ? Image.file(
                                            File(_pickedImage!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(widget.existing!.photoPath!),
                                            fit: BoxFit.cover,
                                          ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_photo_alternate_rounded,
                                          color: Color(0xFFBBBBBB), size: 32),
                                      const SizedBox(height: 4),
                                      Text('Add Photo',
                                          style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 11)),
                                    ],
                                  ),
                          ),
                          // Edit badge when photo exists
                          if (showPhoto)
                            Positioned(
                              bottom: 4, right: 4,
                              child: Container(
                                width: 26, height: 26,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    color: Colors.white, size: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Tap to choose agency photo',
                        style: TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 12)),
                  ),
                  const SizedBox(height: 28),

                  // ── Agency name ──────────────────────────────────
                  _FieldLabel(
                    label: '*Agency name',
                    counter: '${_nameCtrl.text.length}/20',
                  ),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _nameCtrl,
                    hint: 'At least 5 characters',
                    maxLength: 20,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // ── Announcement ─────────────────────────────────
                  _FieldLabel(
                    label: '*Announcement',
                    counter: '${_annoCtrl.text.length}/200',
                  ),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _annoCtrl,
                    hint: 'Write something about your agency',
                    maxLength: 200,
                    maxLines: 5,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── Submit button ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).padding.bottom + 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_canSubmit && !_loading) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit
                      ? AppColors.primaryPurple
                      : const Color(0xFFDDDDDD),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        _isEdit ? 'Save Changes' : 'Create',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _canSubmit ? Colors.white : Colors.white60,
                        ),
                      ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label, counter;
  const _FieldLabel({required this.label, required this.counter});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      Text(counter,
          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
    ],
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength, maxLines;
  final ValueChanged<String> onChanged;
  const _Field({
    required this.controller, required this.hint,
    required this.maxLength, required this.maxLines,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLength: maxLength,
    maxLines: maxLines,
    onChanged: onChanged,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
      counterText: '',
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5)),
    ),
  );
}
