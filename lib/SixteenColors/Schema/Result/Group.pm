package SixteenColors::Schema::Result::Group;

use strict;
use warnings;

use parent qw( DBIx::Class );

use Text::CleanFragment ();

__PACKAGE__->load_components( qw( TimeStamp Core ) );
__PACKAGE__->table( 'grp' );
__PACKAGE__->add_columns(
    id => {
        data_type         => 'bigint',
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    name => {
        data_type   => 'varchar',
        size        => 512,
        is_nullable => 0,
    },
    shortname => {
        data_type   => 'varchar',
        size        => 128,
        is_nullable => 0,
    },
    ctime => {
        data_type     => 'timestamp',
        default_value => \'CURRENT_TIMESTAMP',
        set_on_create => 1,
    },
    mtime => {
        data_type     => 'timestamp',
        is_nullable   => 1,
        set_on_create => 1,
        set_on_update => 1,
    },
);
__PACKAGE__->set_primary_key( qw( id ) );
__PACKAGE__->add_unique_constraint( [ 'shortname' ] );

__PACKAGE__->has_many(
    artist_joins => 'SixteenColors::Schema::Result::ArtistGroupJoin' =>
        'group_id' );
__PACKAGE__->many_to_many( artists => 'artist_joins' => 'artist' );

__PACKAGE__->has_many(
    tags => 'SixteenColors::Schema::Result::Group::Tag' =>
        'group_id' );

sub store_column {
    my ( $self, $name, $value ) = @_;

    if ( $name eq 'name' && !$self->shortname ) {
        my $fragment = lc Text::CleanFragment::clean_fragment( $value );
        $self->shortname( $fragment );
    }

    $self->next::method( $name, $value );
}

sub TO_JSON {
    my $self = shift;
    return { $self->get_columns };
}

1;
