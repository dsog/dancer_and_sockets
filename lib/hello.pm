package hello;
use Dancer ':syntax';

our $VERSION = '0.1';

sub get_hello {
    to_json {api_response => 'Hello World!'}
}

get '/' => sub {
    get_hello;
};

true;
