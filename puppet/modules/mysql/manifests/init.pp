class mysql ($password)
{
	####################################
	### MySQL
	####################################
	$sqlaccess = "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$password');\nGRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$password';\nFLUSH PRIVILEGES;"

	package 
	{ 
		['mysql-server']:
			ensure  => present,
			require => Exec['apt-get update'],
	}

	file 
	{ 
		'/etc/mysql/my.cnf':
			source  => 'puppet:///modules/mysql/my.cnf',
			require => Package['mysql-server'],
			notify  => Service['mysql'],
	}

	# Create an SQL file that we need.
	file
	{
		'/etc/mysql/remote.sql':
			ensure  => present,
			require => Package['mysql-server'],
			content => $sqlaccess
	}

	# Run MySQL as a service
	service
	{ 
		'mysql':
	    	enable    => true,
		ensure    => running,
		require   => [File["/etc/mysql/my.cnf"], File["/etc/mysql/remote.sql"]],
		subscribe => [
	  		File["/etc/mysql/my.cnf"],
	  		File["/etc/mysql/remote.sql"]
		],
	}

        exec 
	{ 
		'set-mysql-password':
	      		command => "mysqladmin -uroot password ${password}",
			unless  => "mysqladmin -uroot -p${password} status",
		        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin'],
		        require => Service['mysql'];
	}

	# Make sure bind-address is commented out
	exec
	{ 
		"bind-address":
			command => 'sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf',
			path    => ['/bin', '/usr/bin'],
			require => File["/etc/mysql/my.cnf"]
	}
}
