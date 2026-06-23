import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// 通用富文本编辑器
/// 通过 [valueJson] / [onChanged] 与外部绑定，存的就是 QuillController 的 delta JSON。
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    super.key,
    this.valueJson,
    this.onChanged,
    this.hintText = '请输入内容...',
    this.readOnly = false,
  });

  final String? valueJson;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool readOnly;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _controller.addListener(_onTextChange);
  }

  quill.QuillController _buildController() {
    if (widget.valueJson == null || widget.valueJson!.isEmpty) {
      return quill.QuillController.basic();
    }
    try {
      final list = jsonDecode(widget.valueJson!) as List<dynamic>;
      final doc = quill.Document.fromJson(list);
      return quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      return quill.QuillController.basic();
    }
  }

  void _onTextChange() {
    if (widget.onChanged == null) return;
    final delta = _controller.document.toDelta();
    final json = jsonEncode(delta.toJson());
    widget.onChanged!(json);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChange);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.readOnly)
            quill.QuillSimpleToolbar(
              controller: _controller,
              config: const quill.QuillSimpleToolbarConfig(
                showAlignmentButtons: false,
                showBackgroundColorButton: false,
                showCodeBlock: false,
                showColorButton: false,
                showDirection: false,
                showFontFamily: false,
                showFontSize: false,
                showSubscript: false,
                showSuperscript: false,
                showStrikeThrough: false,
                showInlineCode: false,
                showSearchButton: false,
                showQuote: true,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: true,
                showCodeBlock: false,
                showHeaderStyle: true,
                showIndent: false,
                showLink: true,
                showUndo: true,
                showRedo: true,
                showClearFormat: true,
                showDividers: false,
              ),
            ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 180),
            child: quill.QuillEditor.basic(
              controller: _controller,
              focusNode: _focusNode,
              scrollController: _scrollController,
              config: quill.QuillEditorConfig(
                placeholder: widget.hintText,
                padding: const EdgeInsets.all(8),
                autoFocus: false,
                expands: false,
                scrollable: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 把 QuillController 的内容转成纯文本（用于预览 / 摘要）
String richTextToPlainText(String? json) {
  if (json == null || json.isEmpty) return '';
  try {
    final list = jsonDecode(json) as List<dynamic>;
    final doc = quill.Document.fromJson(list);
    return doc.toPlainText();
  } catch (_) {
    return '';
  }
}
