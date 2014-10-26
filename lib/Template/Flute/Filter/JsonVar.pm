package Template::Flute::Filter::JsonVar;

use base 'Template::Flute::Filter';
use JSON;

=head1 NAME

Template::Flute::Filters::JsonVar - JSON to Javascript variable filter

=head1 DESCRIPTION

Takes a Perl structure or a JSON string and returns Javascript
which parses the JSON string with Jquery and assigns it to
the variable C<json>.

Example:

    {username => 'shopper@nitesi.biz', city => 'Vienna'};

results in the following JavaScript:

    var json = $.parseJSON('{"post":"Vienna","username":"shopper@nitesi.biz"}');

=head1 PREREQUISITES

L<JSON> module.

=head1 METHODS

=head2 init

The init method allows you to set the following options:

=over 4

=item engine

Value is either C<jquery> or C<eval>.

=back

=cut

sub init {
    my ($self, %args) = @_;

    $self->{engine} = $args{options}->{engine};
}

=head2 filter

Filters the given Perl structure to a JSON string.

=cut

sub filter {
    my ($self, $struct) = @_;
    my ($json);

    if (ref($struct)) {
        # turn into JSON first
        $json = to_json($struct, {pretty => 0});
    }
    else {
        $json = $struct;
    }

    unless ($self->{engine}) {
        die "No engine specified for json_var filter.";
    }

    if ($self->{engine} eq 'jquery') {
        return  q{
var json = $.parseJSON('}
        . _json_filter($json) . q{');};
    }

    if ($self->{engine} eq 'eval') {
        return  q{
var json = eval('(}
        . _json_filter($json) . q{)');};
    }
}

sub _json_filter {
    my $value = shift;

    return '' unless defined $value;

    # escape single quote
    $value =~ s!'!\\'!g;

    # other escapes - from Template::Plugin::JSON::Escape
    $value =~ s!&!\\u0026!g;
    $value =~ s!<!\\u003c!g;
    $value =~ s!>!\\u003e!g;
    $value =~ s!\+!\\u002b!g;
    $value =~ s!\x{2028}!\\u2028!g;
    $value =~ s!\x{2029}!\\u2029!g;
    $value;
}

1;
