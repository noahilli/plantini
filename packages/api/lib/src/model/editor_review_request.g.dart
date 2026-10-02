// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_review_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EditorReviewRequest extends EditorReviewRequest {
  @override
  final String? note;

  factory _$EditorReviewRequest(
          [void Function(EditorReviewRequestBuilder)? updates]) =>
      (EditorReviewRequestBuilder()..update(updates))._build();

  _$EditorReviewRequest._({this.note}) : super._();
  @override
  EditorReviewRequest rebuild(
          void Function(EditorReviewRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorReviewRequestBuilder toBuilder() =>
      EditorReviewRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorReviewRequest && note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorReviewRequest')
          ..add('note', note))
        .toString();
  }
}

class EditorReviewRequestBuilder
    implements Builder<EditorReviewRequest, EditorReviewRequestBuilder> {
  _$EditorReviewRequest? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  EditorReviewRequestBuilder() {
    EditorReviewRequest._defaults(this);
  }

  EditorReviewRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorReviewRequest other) {
    _$v = other as _$EditorReviewRequest;
  }

  @override
  void update(void Function(EditorReviewRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorReviewRequest build() => _build();

  _$EditorReviewRequest _build() {
    final _$result = _$v ??
        _$EditorReviewRequest._(
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
