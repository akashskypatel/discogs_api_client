//file path: test/all.dart

import 'unit/label_client_test.dart' as labels;
import 'unit/search_client_test.dart' as search;
import 'unit/artist_client_test.dart' as artist;
import 'unit/master_client_test.dart' as master;
import 'unit/release_client_test.dart' as release;

void main() {
  labels.main();
  search.main();
  artist.main();
  master.main();
  release.main();
}
