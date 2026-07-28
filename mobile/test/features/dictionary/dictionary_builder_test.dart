import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/dictionary_builder/dictionary_builder.dart';

void main() {
  test('builds a ranked indexed dictionary with source metadata', () async {
    final directory = await Directory.systemTemp.createTemp(
      'dian_du_ji_dictionary_builder_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}${Platform.pathSeparator}ecdict.csv');
    final output = File('${directory.path}${Platform.pathSeparator}ecdict.db');
    await source.writeAsString(
      '''
word,phonetic,definition,translation,pos,collins,oxford,tag,bnc,frq,exchange,detail,audio
rare,rɛə,uncommon,稀有的,adj.,0,0,,99999,99999,,,
look,lʊk,direct gaze,看,v.,5,1,zk  cet4,100,100,p:looked/d:looked/i:looking,,
language,ˈlæŋɡwɪdʒ,communication system,语言,n.,4,1,gk  cet4,200,200,,,
study,ˈstʌdi,learn,学习,v.,3,1,cet4,300,300,p:studied/3:studies/i:studying,,
'''
          .trimLeft(),
    );

    final report = await buildDictionary(
      sourceCsv: source,
      outputDatabase: output,
      sourceRevision: 'fixture-revision',
      maximumEntries: 3,
    );

    expect(report.entryCount, 3);
    expect(report.sha256, hasLength(64));
    final database = sqlite3.open(output.path, mode: OpenMode.readOnly);
    addTearDown(database.close);
    expect(
      database
          .select('SELECT word FROM entries ORDER BY word')
          .map((row) => row['word']),
      ['language', 'look', 'study'],
    );
    expect(
      database
          .select("SELECT lemma FROM lemmas WHERE form = 'looked'")
          .single['lemma'],
      'look',
    );
    expect(
      database
          .select("SELECT value FROM metadata WHERE key = 'source_revision'")
          .single['value'],
      'fixture-revision',
    );
  });
}
