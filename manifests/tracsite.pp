# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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
