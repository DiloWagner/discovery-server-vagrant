exec { 'apt-get update':
  path => '/usr/bin',
}

$modules = split($phpmodules,',')

package { 'vim':
  ensure => present,
}

file { '/var/www/':
  ensure => 'directory',
}

include nginx

class
{
	'php':
	modules => $modules,
	xdebug  => $xdebug
}

class
{
	'mysql':
	password => $password
}
