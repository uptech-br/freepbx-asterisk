# shellcheck shell=bash

function write_odbc_ini() {
  cat <<EOF > /etc/odbc.ini
[MySQL-asteriskcdrdb]
driver=MariaDB Unicode
server=${DBHOST-db}
database=${DBCDR-asteriskcdrdb}
Port=3306
option=3
EOF
}
