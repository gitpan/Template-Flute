#!perl

use strict;
use warnings;
use Template::Flute;
use Test::More tests => 4;
use Data::Dumper;

my ($spec, $html, $flute, $out, $expected);

$spec =<<'SPEC';
<specification>
<list name="items" iterator="items">
  <param name="number"/>
  <param name="category" skip="empty"/>
</list>
<value name="cartline"     skip="empty"/>
<value name="zero"         skip="empty"/>
<value name="empty-string" skip="empty"/>
<value name="undefined"    skip="empty"/>
<value name="whitespace"   skip="empty"/>
</specification>
SPEC

$html =<<'HTML';
<p>There are <span class="cartline">60</span> items in your shopping cart.</p>
<p>There are <span class="zero">60</span> items in your shopping cart.</p>
<p>There are <span class="empty-string">60</span> items in your shopping cart.</p>
<p>There are <span class="undefined">60</span> items in your shopping cart.</p>
<p>There are <span class="whitespace">60</span> items in your shopping cart.</p>
<ul>
  <li class="items">
    <span class="number">1</span>
    <span class="category">My category</span>
  </li>
</ul>
HTML

my $iterator = [
                {
                 number => 1,
                 category => "tofu"
                },
                {
                 number => 2,
                 category => 0,
                },
                {
                 number => 3,
                 category => "",
                },
                {
                 number => 4,
                 category => undef
                },
                {
                 number => 5,
                 category => "  \n\n\r\n\t   ",
                },
               ];

$flute = Template::Flute->new(template => $html,
                              specification => $spec,
                              values => {
                                         items => $iterator,
                                         cartline => "42",
                                         zero => 0,
                                         'empty-string' => '',
                                         undefined => undef,
                                         whitespace => "  \n\n\r\n\t   ",
                                        });

$out = $flute->process;

$expected =<<'EXPECTED';
<p>There are <span class="cartline">42</span> items in your shopping cart.</p>
<p>There are <span class="zero">0</span> items in your shopping cart.</p>
<p>There are <span class="empty-string">60</span> items in your shopping cart.</p>
<p>There are <span class="undefined">60</span> items in your shopping cart.</p>
<p>There are <span class="whitespace">60</span> items in your shopping cart.</p>
EXPECTED

$expected =~ s/\n//g;
like $out, qr/\Q$expected\E/, "Values as expected" or diag $out;

$expected =<<'EXPECTED';
<ul>
<li class="items">
<span class="number">1</span>
<span class="category">tofu</span>
</li>
<li class="items">
<span class="number">2</span>
<span class="category">0</span>
</li>
<li class="items">
<span class="number">3</span>
<span class="category">My category</span>
</li>
<li class="items">
<span class="number">4</span>
<span class="category">My category</span>
</li>
<li class="items">
<span class="number">5</span>
<span class="category">My category</span>
</li>
</ul>
EXPECTED

$expected =~ s/\n//g;
like $out, qr/\Q$expected\E/, "Params as expected" or diag $out;





$spec =<<'SPEC';
<specification>
<pattern name="pxt" type="string">60</pattern>
<list name="items" iterator="items">
  <param name="number"/>
  <param name="category" skip="empty" pattern="pxt"/>
</list>
<value name="cartline"     skip="empty" pattern="pxt"/>
<value name="zero"         skip="empty" pattern="pxt"/>
<value name="empty-string" skip="empty" pattern="pxt"/>
<value name="undefined"    skip="empty" pattern="pxt"/>
<value name="whitespace"   skip="empty" pattern="pxt"/>
</specification>
SPEC

$html =<<'HTML';
<p class="cartline">There are 60 items in your shopping cart.</p>
<p class="zero">There are 60 items in your shopping cart.</p>
<p class="empty-string">There are 60 items in your shopping cart.</p>
<p class="undefined">There are 60 items in your shopping cart.</p>
<p class="whitespace">There are 60 items in your shopping cart.</p>
<ul>
  <li class="items">
    <span class="number">1</span>
    <span class="category">My category is 60</span>
  </li>
</ul>
HTML

$flute = Template::Flute->new(template => $html,
                              specification => $spec,
                              values => {
                                         items => $iterator,
                                         cartline => "42",
                                         zero => 0,
                                         'empty-string' => '',
                                         undefined => undef,
                                         whitespace => "  \n\n\r\n\t   ",
                                        });

$out = $flute->process;


$expected =<<'EXPECTED';
<p class="cartline">There are 42 items in your shopping cart.</p>
<p class="zero">There are 0 items in your shopping cart.</p>
<p class="empty-string">There are 60 items in your shopping cart.</p>
<p class="undefined">There are 60 items in your shopping cart.</p>
<p class="whitespace">There are 60 items in your shopping cart.</p>
EXPECTED

$expected =~ s/\n//g;
like $out, qr/\Q$expected\E/, "Values as expected" or diag $out;

$expected =<<'EXPECTED';
<ul>
<li class="items">
<span class="number">1</span>
<span class="category">My category is tofu</span>
</li>
<li class="items">
<span class="number">2</span>
<span class="category">My category is 0</span>
</li>
<li class="items">
<span class="number">3</span>
<span class="category">My category is 60</span>
</li>
<li class="items">
<span class="number">4</span>
<span class="category">My category is 60</span>
</li>
<li class="items">
<span class="number">5</span>
<span class="category">My category is 60</span>
</li>
</ul>
EXPECTED

$expected =~ s/\n//g;
like $out, qr/\Q$expected\E/, "Params as expected" or diag $out;
