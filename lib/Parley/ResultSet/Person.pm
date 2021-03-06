package Parley::ResultSet::Person;
# ABSTRACT: Resultset class for person table
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub users_with_roles {
    my $resultsource = shift;
    my ($rs);

    $rs = $resultsource->search(
        {
        },
        {
            join        => 'map_user_role',
            distinct    => 1,
        },
    );

    return $rs;
}

1;
