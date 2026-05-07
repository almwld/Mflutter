/// =============================================================================
/// ListExtensions - إضافات القوائم
/// =============================================================================
/// إضافات مفيدة للقوائم
/// =============================================================================

extension ListExtensions<T> on List<T> {
  // ═══════════════════════════════════════════════════════════════════════════
  // الوصول
  // ═══════════════════════════════════════════════════════════════════════════

  /// الوصول الآمن
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// العنصر الأول أو null
  T? get firstOrNull => isEmpty ? null : first;

  /// العنصر الأخير أو null
  T? get lastOrNull => isEmpty ? null : last;

  /// العنصر الأول الذي يطابق أو null
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التعديل
  // ═══════════════════════════════════════════════════════════════════════════

  /// إضافة إذا لم تكن موجودة
  List<T> addIfNotNull(T? item) {
    if (item != null) {
      return [...this, item];
    }
    return this;
  }

  /// إضافة إذا لم تكن موجودة
  List<T> addIf(bool condition, T item) {
    if (condition) {
      return [...this, item];
    }
    return this;
  }

  /// إزالة العناصر الفارغة
  List<T> filterNulls() {
    return where((item) => item != null).cast<T>().toList();
  }

  /// إزالة العناصر التي تطابق
  List<T> removeWhereSafe(bool Function(T) test) {
    final result = [...this];
    result.removeWhere(test);
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التقسيم
  // ═══════════════════════════════════════════════════════════════════════════

  /// تقسيم إلى أجزاء
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// تقسيم إلى جزأين
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الترتيب
  // ═══════════════════════════════════════════════════════════════════════════

  /// ترتيب تصاعدي
  List<T> sortedBy<K extends Comparable>(K Function(T) keyOf) {
    final result = [...this];
    result.sort((a, b) => keyOf(a).compareTo(keyOf(b)));
    return result;
  }

  /// ترتيب تنازلي
  List<T> sortedByDescending<K extends Comparable>(K Function(T) keyOf) {
    final result = [...this];
    result.sort((a, b) => keyOf(b).compareTo(keyOf(a)));
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // البحث
  // ═══════════════════════════════════════════════════════════════════════════

  /// هل يحتوي على عنصر يطابق؟
  bool containsWhere(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return true;
    }
    return false;
  }

  /// عدد العناصر التي تطابق
  int countWhere(bool Function(T) test) {
    var count = 0;
    for (final item in this) {
      if (test(item)) count++;
    }
    return count;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الخرائط
  // ═══════════════════════════════════════════════════════════════════════════

  /// خريطة مع فهرس
  List<R> mapIndexed<R>(R Function(int index, T item) map) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(map(i, this[i]));
    }
    return result;
  }

  /// خريطة مع نوع
  List<R> mapWhere<R>(bool Function(T) test, R Function(T) map) {
    return where(test).map(map).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التفريغ
  // ═══════════════════════════════════════════════════════════════════════════

  /// تفريغ إلى نص
  String joinToString({
    String separator = ', ',
    String? prefix,
    String? suffix,
  }) {
    final buffer = StringBuffer();
    if (prefix != null) buffer.write(prefix);
    buffer.write(join(separator));
    if (suffix != null) buffer.write(suffix);
    return buffer.toString();
  }

  /// تفريغ مع func
  String joinTransform(
    String separator,
    String Function(T) transform, {
    String? prefix,
    String? suffix,
  }) {
    final buffer = StringBuffer();
    if (prefix != null) buffer.write(prefix);
    var first = true;
    for (final item in this) {
      if (!first) buffer.write(separator);
      buffer.write(transform(item));
      first = false;
    }
    if (suffix != null) buffer.write(suffix);
    return buffer.toString();
  }
}

/// =============================================================================
/// MapExtensions - إضافات الخرائط
/// =============================================================================

extension MapExtensions<K, V> on Map<K, V> {
  // ═══════════════════════════════════════════════════════════════════════════
  // الوصول
  // ═══════════════════════════════════════════════════════════════════════════

  /// الوصول الآمن
  V? safeGet(K key, {V? defaultValue}) {
    if (containsKey(key)) {
      return this[key];
    }
    return defaultValue;
  }

  /// الحصول أو تعيين
  V getOrSet(K key, V Function() defaultValue) {
    if (containsKey(key)) {
      return this[key]!;
    }
    final value = defaultValue();
    this[key] = value;
    return value;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التعديل
  // ═══════════════════════════════════════════════════════════════════════════

  /// إضافة إذا لم تكن موجودة
  Map<K, V> putIfAbsentSafe(K key, V Function() defaultValue) {
    if (!containsKey(key)) {
      this[key] = defaultValue();
    }
    return this;
  }

  /// إزالة ذاتياً
  Map<K, V> removeWhereSafe(bool Function(K, V) test) {
    final result = Map<K, V>.from(this);
    result.removeWhere(test);
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحويل
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل القيم
  Map<K, R> mapValues<R>(R Function(V) transform) {
    return map((k, v) => MapEntry(k, transform(v)));
  }

  /// تحويل المفاتيح
  Map<R, V> mapKeys<R>(R Function(K) transform) {
    return map((k, v) => MapEntry(transform(k), v));
  }
}

/// =============================================================================
/// SetExtensions - إضافات المجموعات
/// =============================================================================

extension SetExtensions<T> on Set<T> {
  // ═══════════════════════════════════════════════════════════════════════════
  // التعديل
  // ═══════════════════════════════════════════════════════════════════════════

  /// إضافة مجموعة
  Set<T> addAll(Iterable<T> items) => {...this, ...items};

  /// تقاطع مع مجموعة
  Set<T> intersectWith(Set<T> other) => intersection(other);

  /// فرق مع مجموعة
  Set<T> differenceFrom(Set<T> other) => difference(other);
}