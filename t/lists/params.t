#
# Basic tests for list params

use strict;
use warnings;

use Test::More tests => 5;
use Template::Flute;

my ($spec, $html, $flute, $out);

$spec = q{<specification>
<list name="list" iterator="test">
<param name="value"/>
</list>
</specification>
};

$html = q{<html><div class="list"><div class="value">TEST</div></div></html>};

for my $value (0, 1, ' ', 'test') {
    $flute = Template::Flute->new(template => $html,
                                  specification => $spec,
                                  values => {test => [{value => $value}]},
    );

    $out = $flute->process();

    ok ($out =~ m%<div class="value">$value</div>%,
        "basic list param test with: $value")
        || diag $out;
}

$spec = q{<specification>
<list name="approval" class="approval" iterator="approvals">
<param name="email" />
</list>
</specification>
};

$html = '<html><span class="approval"><span class="email">TEST</span></span></html>';

my $value = 'LIVE';

$flute = Template::Flute->new(template => $html,
                                  specification => $spec,
                                  values => {approvals => [{email => $value}]},
                             );

$out = $flute->process();

ok ($out =~ m%<span class="email">$value</span>%,
    "basic list param test with: $value")
    || diag $out;
