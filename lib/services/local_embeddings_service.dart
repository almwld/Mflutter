import 'dart:math';

class LocalEmbedding {
  const LocalEmbedding(this.id, this.text, this.vector);
  final String id;
  final String text;
  final List<double> vector;
}

class LocalEmbeddingsService {
  static final Map<String, String> _texts = {};
  static final Map<String, List<double>> _vectors = {};
  static final Map<String, int> _documentFrequency = {};
  static const _dimensions = 512;

  static void indexVerse(String id, String text) {
    _texts[id] = text;
    _rebuild();
  }

  static void indexAll(Map<String, String> documents) {
    _texts.addAll(documents);
    _rebuild();
  }

  static List<String> searchSimilar(String query, {int topK=5}) {
    if (_texts.isEmpty) return [];
    final q = _vectorize(query);
    final scored = <MapEntry<String,double>>[];
    for (final entry in _vectors.entries) {
      scored.add(MapEntry(entry.key, cosineSimilarity(q, entry.value)));
    }
    scored.sort((a,b)=>b.value.compareTo(a.value));
    return scored.take(topK).map((e)=>_texts[e.key]!).toList();
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    var dot=0.0, na=0.0, nb=0.0;
    final n=min(a.length,b.length);
    for(var i=0;i<n;i++){dot+=a[i]*b[i];na+=a[i]*a[i];nb+=b[i]*b[i];}
    if(na==0 || nb==0) return 0;
    return dot/(sqrt(na)*sqrt(nb));
  }

  static void _rebuild() {
    _documentFrequency.clear();
    final tokenSets=<String,Set<String>>{};
    for(final e in _texts.entries){
      final tokens=_tokens(e.value).toSet();
      tokenSets[e.key]=tokens;
      for(final token in tokens){_documentFrequency[token]=(_documentFrequency[token]??0)+1;}
    }
    _vectors
      ..clear()
      ..addEntries(_texts.keys.map((id)=>MapEntry(id,_vectorize(_texts[id]!))));
  }

  static List<double> _vectorize(String text) {
    final tokens=_tokens(text);
    final vector=List.filled(_dimensions,0.0);
    final nDocs=max(1,_texts.length);
    for(final token in tokens){
      final df=_documentFrequency[token]??0;
      final idf=log((nDocs+1)/(df+1))+1;
      final hash=token.hashCode.abs()%_dimensions;
      vector[hash]+=idf;
    }
    final norm=sqrt(vector.fold<double>(0,(s,v)=>s+v*v));
    if(norm>0){for(var i=0;i<vector.length;i++)vector[i]/=norm;}
    return vector;
  }

  static List<String> _tokens(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^\u0600-\u06FFa-z0-9 ]'), ' ')
        .split(RegExp(r'\\s+')).where((e)=>e.isNotEmpty).toList();
}
