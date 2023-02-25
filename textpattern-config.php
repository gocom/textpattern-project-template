<?php

$txpcfg['db'] = $_ENV['DATABASE_NAME'];
$txpcfg['user'] = $_ENV['DATABASE_USER'];
$txpcfg['pass'] = $_ENV['DATABASE_PASSWORD'];
$txpcfg['host'] = $_ENV['DATABASE_HOST'];
$txpcfg['table_prefix'] = $_ENV['DATABASE_TABLE_PREFIX'];
$txpcfg['txpath'] = __DIR__;
$txpcfg['dbcharset'] = $_ENV['DATABASE_CHARSET'];

define('ihu', $_ENV['IMAGE_HOST_URL']);
define('PROTOCOL', $_ENV['PROTOCOL']);

define('RAH_MEMCACHED_HOST', $_ENV['MEMCACHED_HOST']);
define('RAH_MEMCACHED_PORT', $_ENV['MEMCACHED_PORT']);
