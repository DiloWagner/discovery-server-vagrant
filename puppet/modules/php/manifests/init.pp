class php ($modules, $xdebug)
{
	# Install PHP
	package
	{
		'php':
		name    => "php5",
		ensure  => latest
	}
	
	#package 
	#{ 
	#	$modules:
	#		ensure  => present,
	#		require => Exec['apt-get update'],
	#}

	# Install PHP Modules
	define php::loadmodule ($modname = $title) {
		package
		{
			$modname:
			ensure  => latest,
			require => Package["php"],
		}
	}

	php::loadmodule{$modules: }

	service 
	{ 
		'php5-fpm':
			ensure => running,
			require => Package['php5-fpm'],
	}

	# Add some custom xdebug ini settings to override any in php.ini
	file
	{
		'/etc/php5/mods-available/xdebug.ini':
		ensure  => present,
		require => Package["php"],
		content => "${xdebug}"
	}
}
