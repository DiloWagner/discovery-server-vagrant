class php ($modules, $xdebug)
{
	# Install PHP
	package
	{
		'php':
		name    => "php5",
		ensure  => latest
	}
	
	# Add some custom xdebug ini settings to override any in php.ini
	file
	{
		'/etc/php5/mods-available/xdebug.ini':
			ensure  => present,
			require => Package["php5-xdebug"],
			content => "${xdebug}"
	}

	file 
	{ 
		'fpm-www':
			path    => '/etc/php5/fpm/pool.d/www.conf',
			ensure  => present,
			require => Package['php5-fpm'],
			source  => 'puppet:///modules/php/www.conf',
	}

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
			ensure  => running,
			require => Package['php5-fpm'],
	}

	
}
