# Set up the foreman database using postgresql
class foreman::database::postgresql {
  $dbname = $foreman::db_database ? {
    'UNSET' => 'foreman',
    default => $foreman::db_database,
  }

  $password = $foreman::db_password ? {
    'UNSET' => false,
    # as soon, as the Function accepts Sensitive (Pull-Request pending), we can remove the Workaround
    #default => postgresql::postgresql_password($foreman::db_username, $foreman::db_password),
    default => postgresql::postgresql_password($foreman::db_username, $foreman::db_password_unsensitive),
  }

  # Prevents errors if run from /root etc.
  Postgresql_psql {
    cwd => '/',
  }

  include postgresql::client, postgresql::server

  postgresql::server::db { $dbname:
    user     => $foreman::db_username,
    password => $password,
    owner    => $foreman::db_username,
    encoding => 'utf8',
    locale   => 'en_US.utf8',
  }
}
