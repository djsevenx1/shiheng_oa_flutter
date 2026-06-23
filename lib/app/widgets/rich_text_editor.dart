import 'dart:convert';

import 'package:flutter/material.dart';

/// 通用富文本编辑器（轻量版）。
///
/// 设计选择：放弃 flutter_quill 以避开 quill_native_bridge_windows 在 Flutter
/// 3.22.2 上的 `GMEM_MOVEABLE` 编译错误。改用 `TextField` 多行 + 简易工具栏：
/// - 支持标题、列表、加粗、斜体
/// - 输出为 markdown 字符串（[valueJson] / [onChanged]）
/// - 解析时用 [richTextToPlainText] 提取纯文本
///
/// 老版本 `flutter_quill 10.x` 的 API（QuillSimpleToolbarConfig / QuillEditorConfig）
/// 与 quill_native_bridge_windows 0.0.2 的 Win32 调用在当前 Flutter 下编译不过；
/// 等后续升级 Flutter 到 3.27+ 再恢复富文本组件。
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
  late TextEditingController _controller;
  bool _bold = false;
  bool _italic = false;
  final List<String> _bullets = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valueJson ?? '');
    _controller.addListener(_onTextChange);
  }

  void _onTextChange() {
    if (widget.onChanged == null) return;
    widget.onChanged!(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChange);
    _controller.dispose();
    super.dispose();
  }

  void _insertAtCursor(String text) {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.start < 0 ? value.text.length : selection.start;
    final end = selection.end < 0 ? value.text.length : selection.end;
    final newText = value.text.replaceRange(start, end, text);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  void _wrapSelection(String left, String right) {
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) return;
    final start = selection.start;
    final end = selection.end;
    final selected = value.text.substring(start, end);
    final newText = value.text.replaceRange(start, end, '$left$selected$right');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start + left.length,
        extentOffset: end + left.length,
      ),
    );
  }

  void _toggleBold() {
    setState(() => _bold = !_bold);
    _wrapSelection('**', '**');
  }

  void _toggleItalic() {
    setState(() => _italic = !_italic);
    _wrapSelection('*', '*');
  }

  void _insertHeading() => _insertAtCursor('\n## ');
  void _insertBullet() => _insertAtCursor('\n- ');
  void _insertNumbered() => _insertAtCursor('\n1. ');
  void _insertQuote() => _insertAtCursor('\n> ');
  void _insertLink() {
    _wrapSelection('[', '](https://)');
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _btn(Icons.format_bold, '加粗', _bold, _toggleBold),
                  _btn(Icons.format_italic, '斜体', _italic, _toggleItalic),
                  const SizedBox(width: 4),
                  _iconBtn(Icons.title, '标题', _insertHeading),
                  _iconBtn(Icons.format_list_bulleted, '列表', _insertBullet),
                  _iconBtn(Icons.format_list_numbered, '编号', _insertNumbered),
                  _iconBtn(Icons.format_quote, '引用', _insertQuote),
                  _iconBtn(Icons.link, '链接', _insertLink),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 180),
            child: TextField(
              controller: _controller,
              readOnly: widget.readOnly,
              maxLines: null,
              minLines: 6,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String tip, bool active, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18, color: active ? const Color(0xFF61428F) : Colors.black54),
      tooltip: tip,
      onPressed: onTap,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _iconBtn(IconData icon, String tip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18, color: Colors.black54),
      tooltip: tip,
      onPressed: onTap,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

/// 把 markdown 字符串转成纯文本（用于预览 / 摘要）。
/// 当前用最朴素的：去掉常见 markdown 标记。
String richTextToPlainText(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  var s = raw;
  // 去掉加粗 / 斜体 / 行内代码
  s = s.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1');
  s = s.replaceAll(RegExp(r'\*(.+?)\*'), r'$1');
  s = s.replaceAll(RegExp(r'`(.+?)`'), r'$1');
  // 去掉链接 [text](url) -> text
  s = s.replaceAll(RegExp(r'\[([^\]]+)\]\(([^)]+)\)'), r'$1');
  // 去掉 # 标题前缀
  s = s.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
  // 去掉 > 引用前缀
  s = s.replaceAll(RegExp(r'^>\s*', multiLine: true), '');
  // 去掉列表标记
  s = s.replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '');
  s = s.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
  return s.trim();
}
