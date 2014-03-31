define trac::trac_project(
    $project_name=$title,
    $base_dir,
    $repository = false,
    $templates = "/usr/share/trac/templates",
    $cgipath = false,
    $navadd = false,
    $cc,
    $description,
    $db = "sqlite:db/trac.db",
    $owner = "www-data",
    $group = "www-data",
    $url,
    $repo_dir,
    $repo_type = "svn",
    $cgi_dir,
    $alt = $domain,
) {

    $project_dir = "$base_dir/$project_name"

    # Create the app
    exec { "tracinit-$name":
	command => "trac-admin $project_dir initenv $project_name $db $repo_type $repo_dir $templates",
	path => "/usr/bin:/bin:/usr/sbin",
	logoutput => false,
	creates => $config
    }

    # Chown it to www-data
    file { $tracdir:
	owner => $owner,
	group => $group,
	recurse => true,
	require => Exec["tracinit-$name"]
    }

    # Rewrite the config
    file { $config:
	owner => $owner,
	      group => $group,
	      content => template("trac/tracconfig.erb"),
	      require => Exec["tracinit-$name"]
    }
}
