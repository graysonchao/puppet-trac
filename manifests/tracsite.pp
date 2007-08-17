# Install an Apache configuration for this Trac instance.
# This assumes your apache instance is configured to load everything
# in /etc/apache2/trac, and probably only works on Debian.
define tracsite($cgidir, $tracdir) {
    # Create the file
    file { "trac-$name":
        path => "/etc/apache2/trac/$name.conf",
        owner => root,
        group => root,
        mode => 644,
        content => template("trac/tracsite.erb"),
        notify => Service[apache2] # notify apache that it should restart
    }

    # Make the symlink so the cgi stuff works.
    file { "tracsym-$name":
        path => "$cgidir/$name.cgi",
        ensure => "/usr/share/trac/cgi-bin/trac.cgi"
    }
}

# $Id$
