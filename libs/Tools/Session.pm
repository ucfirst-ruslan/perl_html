package Tools::Session;

use strict;
use CGI::Session;
use CGI::Cookie;
use Tools::Accessors;

our @ISA = qw(Tools::Accessors);

# module interface

sub sessionStart($);
sub getSid($);
sub isValidExpTime($);
sub getSessionExpiration($);
sub getLastAccessTime($);
sub getSessionCreationTime($);
sub getSessionElementsAsHashref($);
sub getSessionElement($$);
sub setSessionElement($$$);
sub clearSessionElements($$);
sub flush($);
sub sessionClose($);
sub sessionDelete($);
sub getCookieWithSid($);

sub new
{
    my ($class) = ref($_[0]) || $_[0];

    return bless {
        'driver' => 'driver:File',
        'serializer' => 'serializer:Default',
        'sid' => undef,
        'sessionDir' => undef}, $class;
}
# a new session file starting or an exist file connecting by session id
sub sessionStart($)
{
    my ($self) = shift;

    return undef unless ($self->get('sessionDir'));

    return undef unless ($self->isValidExpTime($self->get('sessionExpires')));

    my $driver = $self->get('driver');
    my $serializer = $self->get('serializer');
    my $sid = $self->get('sid');
    my $workDir = $self->get('sessionDir');

    my $session = CGI::Session->new("$driver;$serializer", $sid,
        { Directory => $workDir });

    return undef unless ($session);

    $session->expire($self->get('sessionExpires'));
    $self->set('sessionHandler', $session);

    return 1;
}

# get the session file id

sub getSid($)
{
    my ($self) = shift;

    my $session = $self->get('sessionHandler');
    my $sid = $session->id();
    $self->set('sid', $sid);

    return $sid;
}

# +===========+===============+
# # |   alias   |   meaning     |
# # +===========+===============+
# # |     s     |   Second      |
# # |     m     |   Minute      |
# # |     h     |   Hour        |
# # |     w     |   Week        |
# # |     M     |   Month       |
# # |     y     |   Year        |
# # +-----------+---------------+

sub isValidExpTime($)
{
    my ($self, $expTime) = @_;
    return ($expTime =~ /^\d+$/
        || $expTime =~ /^[+]{1}[0-9]{1,2}[smhWMY]{1}$/);
}

# the session expiration date return
sub getSessionExpiration($)
{
    my $self = shift;
    my $session = $self->get('sessionHandler');
    return $session->expire();
}

# returns the last access time of the session in
# # the form of seconds from epoch. This time is used internally
# # while auto-expiring sessions and/or session parameters.
sub getLastAccessTime($)
{
    my $self = shift;
    my $session = $self->get('sessionHandler');
    return $session->atime();
}

# returns the time when the session was first created.
sub getSessionCreationTime($)
{
    my $self = shift;
    my $session = $self->get('sessionHandler');
    return $session->ctime();
}

# returns all the session parameters as a reference to a hash
sub getSessionElementsAsHashref($)
{
    my $self = shift;
    my $session = $self->get('sessionHandler');
    return $session->param_hashref();
}

# get an element by name from the session file
sub getSessionElement($$)
{
    my ($self, $key) = @_;
    my $session = $self->get('sessionHandler');
    return $session->param($key);
}

# set the element into the current session file
sub setSessionElement($$$)
{
    my ($self, $key, $value) = @_;
    my $session = $self->get('sessionHandler');
    $session->param($key, $value);
}

# clears parameters from the session object.
# # If passed an argument as an arrayref,
# # clears only those parameters found in the list.
# # clear(["_IS_LOGGED_IN"])
sub clearSessionElements($$)
{
    my ($self, $keys) = @_;
    my $session = $self->get('sessionHandler');
    $session->clear($keys);
}

# synchronizes data in the buffer with its copy in disk.
# # Normally it will be called for you just before the program terminates,
# # session object goes out of scope or close() is called.
sub flush($)
{
    my ($self) = shift;
    my $session = $self->get('sessionHandler');
    $session->flush();
}

# closes the session temporarily until new()
# # is called on the same session next time.
# # In other words, it's a call to flush() and DESTROY(), but a lot slower.
# # Normally you never have to call close().
sub sessionClose($)
{
    my ($self) = shift;
    my $session = $self->get('sessionHandler');
    $session->close();
}

# deletes the session from the disk.
# # In other words, it calls for immediate expiration
# # after which the session will not be accessible
sub sessionDelete($)
{
    my ($self) = shift;
    my $session = $self->get('sessionHandler');
    $session->delete(); 
}

# give a prepared header with cookie (redy to sending into a browser)
sub getCookieWithSid($)
{
    my ($self) = shift;
    my $cookie = new CGI::Cookie(
        -name => 'CGISESSID',
        -value => $self->getSid());
    my $session = $self->get('sessionHandler');

    return $session->header(-cookie => $cookie);
}

sub DESTROY
{
    my ($self) = shift;
    $self->flush();
    $self->sessionClose();
}

1;
