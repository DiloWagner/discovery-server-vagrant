exec { 
	'apt-get update':
		path => '/usr/bin',
}

$modules = split($phpmodules,',')

package { 
	'vim':
  		ensure => present,
}

file { 
	'/var/www/':
		ensure => 'directory',
}

class
{
	'nginx':
}

class
{
	'mysql':
		password => $password,
		require  => Class['nginx']
}

class
{
	'php':
		modules => $modules,
		xdebug  => $xdebug,
		require => Class['mysql']
}
