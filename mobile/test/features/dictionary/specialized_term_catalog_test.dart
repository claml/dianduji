import 'package:dian_du_ji/features/dictionary/data/specialized_term_catalog.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJson = '''
{
  "version": "1.0-test",
  "source": "test-source",
  "license": "MIT",
  "terms": [
    {"term": "Random Forest", "domain": "computerScience",
     "definition": "随机森林", "synonyms": ["RF"]},
    {"term": "Cell", "domain": "biology", "definition": "细胞"},
    {"term": "Cell Membrane", "domain": "biology", "definition": "细胞膜"},
    {"term": "PCR", "domain": "biology", "definition": "聚合酶链式反应"},
    {"term": "Neural Network", "domain": "computerScience",
     "definition": "神经网络"},
    {"term": "Insulin", "domain": "medicine", "definition": "胰岛素"},
    {"term": "Benign", "domain": "medicine", "definition": "良性的"},
    {"term": "Catalyst", "domain": "chemistry", "definition": "催化剂"},
    {"term": "pH", "domain": "chemistry", "definition": "酸碱度"}
  ]
}
''';

  test('loads metadata and indexes terms case-insensitively', () {
    final catalog = SpecializedTermCatalog.load(sampleJson);

    expect(catalog.metadata.version, '1.0-test');
    expect(catalog.metadata.source, 'test-source');
    expect(catalog.metadata.license, 'MIT');
    expect(catalog.length, 9);

    final hit = catalog.lookup('random forest');
    expect(hit, isNotNull);
    expect(hit!.domain, SpecializedDomain.computerScience);
    expect(hit.definition, '随机森林');
  });

  test('lookup matches synonyms and normalizes apostrophes', () {
    final catalog = SpecializedTermCatalog.load(sampleJson);

    expect(catalog.lookup('RF')?.term, 'Random Forest');
    expect(catalog.lookup('  Cell  '), isNotNull);
    expect(catalog.lookup('missing term'), isNull);
  });

  test('lookupLongestPrefix returns the longest extending term', () {
    final catalog = SpecializedTermCatalog.load(sampleJson);

    // "cell" extends to "cell membrane"; the exact "cell" hit must not win.
    expect(catalog.lookupLongestPrefix('cell')?.term, 'Cell Membrane');
    expect(catalog.lookupLongestPrefix('random')?.term, 'Random Forest');
    // No longer term exists for "insulin" or "pcr".
    expect(catalog.lookupLongestPrefix('insulin'), isNull);
    expect(catalog.lookupLongestPrefix('pcr'), isNull);
  });

  test('domains reflects the data present', () {
    final catalog = SpecializedTermCatalog.load(sampleJson);

    expect(catalog.domains, containsAll(SpecializedDomain.values));
  });

  test('malformed entries are skipped and metadata defaults are safe', () {
    final catalog = SpecializedTermCatalog.load('''
{
  "terms": [
    {"term": "Ok", "domain": "medicine", "definition": "好的"},
    {"term": "NoDomain", "definition": "x"},
    {"term": "NoDefinition", "domain": "chemistry"},
    "not-a-map"
  ]
}
''');

    expect(catalog.length, 1);
    expect(catalog.lookup('ok'), isNotNull);
    expect(catalog.metadata.version, isEmpty);
  });

  test('throws for structurally invalid documents', () {
    expect(() => SpecializedTermCatalog.load('[]'), throwsFormatException);
    expect(
      () => SpecializedTermCatalog.load('{"version": "1"}'),
      throwsFormatException,
    );
  });

  test('bundled asset loads and covers all four domains', () async {
    final catalog = await SpecializedTermCatalog.loadFromAssets();

    expect(catalog.metadata.version, isNotEmpty);
    expect(catalog.metadata.license, 'MIT');
    expect(catalog.metadata.source, isNotEmpty);
    expect(catalog.length, greaterThan(300));
    expect(
      catalog.domains.toSet(),
      containsAll(SpecializedDomain.values),
    );
    // Spot-check a multi-word term and a synonym from the real table.
    expect(
      catalog.lookup('random forest')?.domain,
      SpecializedDomain.computerScience,
    );
    expect(
      catalog.lookup('PCR')?.domain,
      SpecializedDomain.biology,
    );
    expect(catalog.lookup('pH')?.domain, SpecializedDomain.chemistry);
    expect(
      catalog.lookup('myocardial infarction')?.domain,
      SpecializedDomain.medicine,
    );
  });
}
