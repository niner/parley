package Parley::Schema::PreferenceTimeString;
# ABSTRACT: Schema class for preference_time_string table
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("parley.preference_time_string");
__PACKAGE__->add_columns(
    id => {
        data_type => "integer",
        #default_value => "nextval('preference_time_string_preference_time_string_id_seq'::regclass)",
        is_nullable => 0,
        size => 4,
    },
    time_string => {
        data_type => "text",
        is_nullable => 0,
        size => undef,
    },
    sample => {
        data_type => "text",
        is_nullable => 0,
        size => undef,
    },
    comment => {
        data_type => "text",
        is_nullable => 1,
        size => undef,
    },
);
__PACKAGE__->set_primary_key("id");

1;
