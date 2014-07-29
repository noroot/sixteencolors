#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use File::Basename ();
use Path::Class::Dir ();
use SixteenColors::Schema;
use Try::Tiny;

# TEMP: Update once we have Catalyst to use to load the schema
use SixteenColors::Schema;
my @dsn = ( 'dbi:SQLite:dbname=sixteencolors.db', undef, undef, {}, { quote_names => 1 } ); 
my $schema = SixteenColors::Schema->connect( @dsn );
# /TEMP

my $rs = $schema->resultset( 'Pack' );

if( !@ARGV ) {
    print <<"EOUSAGE"
USAGE: $0 /path/to/archive/sorted/by/year/
       $0 /path/to/directory/year/1990/
       $0 year /path/to/directory/
       $0 year /path/to/file.ext
EOUSAGE
}
elsif( -d $ARGV[ 0 ] ) {
    my $dir = Path::Class::Dir->new( shift );

    if( $dir->basename =~ m{^\d{4}$} ) {
        _index_dir( $dir->basename, $dir );
    }
    else {
        my @years = sort map { $_->basename }
            grep { $_->is_dir && $_->basename =~ m{^\d{4}$} }
            $dir->children( no_hidden => 1 );
        _index_dir( $_, $dir->subdir( $_ ) ) for @years;
    }
}
else {
    my $year = shift;
    my @files = @ARGV;

    unless ( $year =~ m{^\d\d\d\d$} ) {
        print "[ERROR] Invalid year specified\n";
        exit;
    }

    if( @files == 1 && -d $files[ 0 ] ) {
        _index_dir( $year, @files );
    }
    else {
        _index( $year, @files );
    }
}

sub _index_dir {
    my $year  = shift;
    my $dir   = Path::Class::Dir->new( shift );
    my @files = map { $_->stringify } grep { !$_->is_dir }
        $dir->children( no_hidden => 1 );
    _index( $year, @files );
}

sub _index {
    my( $year, @files ) = @_;

    for my $file ( @files ) {
        next if -d $file;

        unless( $file =~ m{\.zip$}i ) {
            printf "[ERROR] %s is not a zip file\n", $file;
            next;
        }

        printf "Indexing %s\n", $file;

        my $basename = File::Basename::basename( $file );
        if ( $rs->search( { filename => $basename } )->count ) {
            printf
                "[ERROR] A file of the same name (%s) has already been indexed\n",
                $basename;
            next;
        }

        try {
            # TODO: Indexing
            die 'do indexing here';
        }
        catch {
            printf "[ERROR] Problem indexing pack: %s\n", $_;
        };
    }
}