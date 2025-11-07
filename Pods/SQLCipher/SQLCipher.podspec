Pod::Spec.new do |s|
  s.name = 'SQLCipher'
  s.version = '4.5.3'
  s.summary = 'Full Database Encryption for SQLite.'
  s.homepage = 'https://www.zetetic.net/sqlcipher/'
  s.license = 'BSD'
  s.author = 'Zetetic LLC'
  s.source = { :git => 'https://github.com/sqlcipher/sqlcipher.git', :tag => "v3.4.0" }
  s.platform     = :ios, "12.0"
  s.requires_arc = false
  s.default_subspec = 'standard'  

  s.subspec 'standard' do |ss|
    ss.source_files = 'sqlite3.{h,c}'
    ss.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DNDEBUG -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=3 -DSQLITE_SOUNDEX -DSQLITE_THREADSAFE -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_STAT3 -DSQLITE_ENABLE_STAT4 -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_OMIT_JSON -DSQLITE_ENABLE_DBSTAT_VTAB -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLCIPHER_CRYPTO_CC -DSQLITE_OS_UNIX=1 -DSQLITE_DEFAULT_JOURNAL_SIZE_LIMIT=1048576' }
  end
end
