#!/usr/bin/env perl
use Modern::Perl;

use AnyEvent;
use AnyEvent::Socket qw/tcp_server/;
use AnyEvent::Handle;
use JSON qw/from_json/;
use TryCatch;

use hello;

my $guard = tcp_server undef, 9000, sub {
    my ($fh, $host, $port) = @_;

    my $hdl = AnyEvent::Handle->new( fh => $fh,
        on_error => sub {
            say "we got an error";
            say "$_[2]";
            $_[0]->destroy;
        }
    );

    my $reader;
    $reader = sub {
        try {
            my $line = $_[1];
            $hdl->push_read( line => $reader ) if ($line eq "");

            my $request = from_json($line);
            $hdl->push_read( line => $reader ) if !$request;

            no strict 'refs';
            # This is the line that needs the smart mapping logic.
            my $function =
                "hello::" . $request->{verb} . '_' . $request->{function};
            my $response = $function->();
            if ( $response ){
                syswrite $fh, $response;
            }
        } catch ($e) {
            print "error: " . $e . "\n";
        }
        $hdl->push_read( line => $reader );
    };
    $hdl->push_read( line => $reader );
};

AnyEvent->condvar->recv;
