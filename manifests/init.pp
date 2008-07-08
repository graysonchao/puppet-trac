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

# Create a new Trac instance.  Example usage:
#
#    Trac {
#        alt => "Reductive Labs",
#        cgidir => "/export/docroots/reductivelabs.com/cgi-bin",
#        cc => "luke@abuse.com",
#        url => "https://reductivelabs.com",
#        repobase => "/export/svn/repos"
#    }
#
#    trac {
#        enhost:
#            description => "Enhost - LDAP System Information Uploader";
#        puppet:
#            description => "Puppet - Portable System Automation",
#            cc => "puppet-dev@madstop.com";
#   }
define trac(
    $basedir = "/export/svn/trac",
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
    $repobase,
    $cgidir,
    $replyto = "trac@$domain",
    $from = "trac@$domain",
    $logo = "/images/traclogo.png",
    $alt = $domain,
    $smtpserver = "mail.$domain",
    $repostype = "svn",
    $apache = false
) {
    $repo = $repository ? {
        false => "$repobase/$name",
        default => $repository
    }
    $link = "$url/trac/$name"
    $tracdir = "$basedir/$name"
    $config = "$tracdir/conf/trac.ini"

    $anon_permissions = "BROWSER_VIEW CHANGESET_VIEW FILE_VIEW LOG_VIEW MILESTONE_VIEW REPORT_SQL_VIEW REPORT_VIEW ROADMAP_VIEW SEARCH_VIEW TICKET_VIEW TIMELINE_VIEW WIKI_VIEW"
    $authenticated_permissions = "anonymous TICKET_APPEND TICKET_CHGPROP TICKET_CREATE_SIMPLE TICKET_MODIFY WIKI_CREATE WIKI_MODIFY"
    $developer_permissions = "TRAC_ADMIN"

    # Create the app
    exec { "tracinit-$name":
        command => "trac-admin $tracdir initenv $name $db $repostype $repo $templates",
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

#    exec { "init-$name-trac-authenticated-permissions":
#        command => "trac-admin $tracdir permission add authenticated $authenticated_permissions",
#        refreshonly => true,
#        subscribe => Exec["tracinit-$name"],
#    }
#
#    exec { "init-$name-trac-dev-permissions":
#        command => "trac-admin $tracdir permission add developer $developer_permissions",
#        refreshonly => true,
#        subscribe => Exec["tracinit-$name"],
#    }
#
#    exec { "init-$name-trac-anon-permissions":
#        command => "trac-admin $tracdir permission remove $anon_permissions",
#        refreshonly => true,
#        subscribe => Exec["tracinit-$name"],
#    }

    # Now create the apache config
    if $apache {
        tracsite { $name:
            tracdir => $tracdir,
            cgidir => $cgidir
        }
    }
}
