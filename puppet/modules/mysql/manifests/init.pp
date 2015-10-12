class mysql ($password)
{
	####################################
	### MySQL
	####################################
	#$sqlaccess = "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$password';\nFLUSH PRIVILEGES;"

	package 
	{ 
		['mysql-server']:
			ensure  => present,
			require => Exec['apt-get update'],
	}

	service 
	{ 
		'mysql':
			ensure  => running,
			require => Package['mysql-server'],
	}

	file 
	{ 
		'/etc/mysql/my.cnf':
			source  => 'puppet:///modules/mysql/my.cnf',
			require => Package['mysql-server'],
			notify  => Service['mysql'],
	}

        exec 
	{ 
		'set-mysql-password':
	   	        unless  => 'mysqladmin -uroot -proot password ${password}',
	      		command => 'mysqladmin -uroot password ${password}',
		        path    => ['/bin', '/usr/bin'],
		        require => Service['mysql'];
	}

	# Make sure bind-address is commented out
	#exec
	#{ 
	#	"bind-address":
	#		command => 'sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf',
	#		require => File["/etc/mysql/my.cnf"]
	#}
}
