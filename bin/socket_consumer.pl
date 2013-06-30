use Modern::Perl;

use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use JSON;

my $server = 'localhost';
my $port = 9000;

sub get_hello {
    my ($fh, $handle) = @_;
    my $cmd = { verb => 'get', function => 'hello' };
    syswrite $fh, "@{[to_json($cmd)]}\015\012";

    $handle->push_read( line => sub {
        my ($handle, $line) = @_;
        say "$line";
    });
};

tcp_connect $server, $port, sub {
    my ($fh) = @_ or die "Connecting to $server:$port failed: $!";

    my $handle;
    $handle = AnyEvent::Handle->new(
        fh     => $fh,
        on_error => sub {
            say "we got an error";
            say "$_[2]";
            $_[0]->destroy;
        },
        on_eof => sub {
            $handle->destroy;
            say "Server ended.";
        },
        on_read => sub {
            print $_[0]->rbuf;
            $_[0]->rbuf = "";
        },
    );

    get_hello ($fh, $handle);
};

AnyEvent->condvar->recv;

