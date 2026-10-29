/// Evidence metadata for comparative or "scientific miracle" content.
/// This model intentionally does not infer scientific proof from a resemblance.
enum EvidenceStrength { unreviewed, primarySource, peerReviewed, contradicted }

class ClaimEvidence {
  final String claimId;
  final String claimText;
  final String sourceTitle;
  final String sourceUrl;
  final String sourceDate;
  final EvidenceStrength strength;
  final String limitations;

  const ClaimEvidence({
    required this.claimId,
    required this.claimText,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.sourceDate,
    required this.strength,
    required this.limitations,
  });

  bool get hasSource {
    if (sourceTitle.trim().isEmpty) return false;
    final uri = Uri.tryParse(sourceUrl.trim());
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }

  bool get isReadyForPublication =>
      claimId.trim().isNotEmpty &&
      claimText.trim().isNotEmpty &&
      hasSource &&
      sourceDate.trim().isNotEmpty &&
      limitations.trim().isNotEmpty &&
      strength != EvidenceStrength.unreviewed;

  String get publicationStatus {
    if (claimId.trim().isEmpty) return 'يتطلب معرّفًا ثابتًا للادعاء';
    if (claimText.trim().isEmpty) return 'يتطلب نصًا محددًا للادعاء';
    if (!hasSource) return 'يتطلب مصدرًا موثوقًا بعنوان HTTPS صالح';
    if (sourceDate.trim().isEmpty) return 'يتطلب تاريخ المصدر';
    if (limitations.trim().isEmpty) return 'يتطلب بيان حدود الدليل';
    switch (strength) {
      case EvidenceStrength.unreviewed:
        return 'لم يُراجع الدليل بعد';
      case EvidenceStrength.primarySource:
        return 'مصدر أولي؛ لا يعني وحده إجماعًا علميًا';
      case EvidenceStrength.peerReviewed:
        return 'مصدر محكّم؛ يلزم عرض الاستنتاج ضمن نطاق الدراسة';
      case EvidenceStrength.contradicted:
        return 'توجد أدلة معارضة؛ لا يُعرض الادعاء كحقيقة مثبتة';
    }
  }
}
