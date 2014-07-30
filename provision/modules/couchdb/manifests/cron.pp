class cron {
  cron { compact_db:
    command => "/usr/bin/curl  -H "Content-Type: application/json" -X POST  http://${db_host}:5984/sensors/_compact",
    user    => root,
    hour    => 2,
    minute  => 0,
  }
}
