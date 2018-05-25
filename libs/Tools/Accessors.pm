package Tools::Accessors;

use strict;

sub set($$$);
sub get($$);

sub new
{
    my $class = ref($_[0]) || $_[0];
    return bless {}, $class;
}

sub set($$$)
{
    my ($self, $key, $value) = @_;
    $self->{$key} = $value;
}

sub get($$)
{
    my ($self, $key) = @_;
    return $self->{$key};
}

1;
