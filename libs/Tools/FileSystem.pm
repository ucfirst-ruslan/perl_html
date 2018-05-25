package Tools::FileSystem;

use strict;
use File::Find;
use File::Path;
#use String::ShellQuote;
use Tools::Accessors;

our @ISA = qw(Tools::Accessors);

# module interface
sub isDirectoryExists($$);
sub isFileReadable($$);
sub getSubDirsList($$);
sub getFilesList($$;$);
sub changeOwner($$$$);
sub changeMode($$$);
sub mkDir($$$$$);
sub deleteDir($$);
sub getFileContent($$);
sub saveFile($$$);

sub new
{
    my $class = ref($_[0]) || $_[0];
    return bless {}, $class;
}

sub isDirectoryExists($$)
{
    my ($self, $directory) = @_;

    return (-e $directory && -d $directory);
}

sub isFileReadable($$)
{
    my ($self, $file) = @_;

    return (-f $file && -r $file);
}

sub getSubDirsList($$)
{
    my ($self, $directory) = @_;

    return undef unless ($directory);

    return undef unless ($self->isDirectoryExists($directory));

    my $dh = undef;

    return undef unless (opendir($dh, $directory));

    my @subdirs = grep { /[^.]{1,2}$/
        && -d "$directory/$_"
        && ($_ = "$directory/$_")} readdir($dh);

    closedir $dh;

    return \@subdirs;
}

sub getFilesList($$;$)
{
    my ($self, $directory, $extention) = @_;

    return undef unless ($directory);

    return undef unless ($self->isDirectoryExists($directory));

    my $dh = undef;

    return undef unless (opendir($dh, $directory));

    my @files = ();

    if ($extention)
    {
        @files = grep {/$extention$/
            && -f "$directory/$_"
            && ($_ = "$directory/$_")} readdir($dh);
    }
    else
    {
        @files = grep {-f "$directory/$_"
            && ($_ = "$directory/$_")} readdir($dh);
    }

    closedir $dh;

    return \@files;
}

sub changeMode($$$)
{
    my ($self, $mode, $file) = @_;

    return undef unless ($mode =~ /^\d{3}$/);

    return undef unless ($file || @$file);

    my $count = 0;
    $mode = oct($mode);

    if (ref($file) eq 'ARRAY')
    {
        $count = chmod($mode, @$file);
    }
    else
    {
        $count = chmod($mode, $file);
    }

    return $count;
}

sub changeOwner($$$$)
{
    my ($self, $uid, $gid, $file) = @_;

    return undef unless ($uid =~ /^\d{1,}$/ && $gid =~ /^\d{1,}$/);

    return undef unless ($file || @$file);

    my $count = 0;

    if (ref($file) eq 'ARRAY')
    {
        $count = chown $uid, $gid, @$file;
    }
    else
    {
        $count = chown $uid, $gid, $file;
    }

    return $count;
}

sub mkDir($$$$$)
{
    my ($self, $dirname, $mode, $uid, $gid) = @_;

    return undef unless ($dirname);

    return undef unless ($mode =~ /^\d+$/);

    $self->isDirectoryExists($dirname)
    && $self->changeOwner($uid, $gid, $dirname)
    && $self->changeMode($mode, $dirname)
    && (return 1);

    my $error = undef;

    my %options = (
        'mode' => oct($mode),
        'owner' => $uid,
        'group' => $gid,
        'error' => \$error
    );

    my $count = mkpath($dirname, \%options);

    return undef if (@$error);

    return $self->isDirectoryExists($dirname);
}

sub deleteDir($$)
{
    my ($self, $dirname) = @_;

    return undef unless ($dirname);

    return 1 unless ($self->isDirectoryExists($dirname)
        || $self->isFileReadable($dirname));

    my $error = undef;

    my $count = rmtree($dirname, {'error' => \$error});

    return undef if (ref($error) eq 'ARRAY' && scalar(@$error));

    return $count || 1;
}

sub getFileContent($$)
{
    my ($self, $filePath) = @_;

    return undef unless ($self->isFileReadable($filePath));

    my $fh = undef;

    return undef unless (open $fh, "< $filePath");

    binmode $fh;

    my @content = ();

    while (<$fh>)
    {
        chomp($_);
        push @content, $_;
    }

    close $fh;

    if (wantarray)
    {
        return @content;
    }
    else
    {
        return join("\n", @content);
    }
}

sub saveFile($$$)
{
    my ($self, $filePath, $data) = @_;

    my $fh = undef;

    return undef unless (open $fh, "> $filePath");

    binmode $fh;

    if (ref($data) eq 'ARRAY')
    {
        while (@$data)
        {
            my $string = shift @$data;
            print $fh "$string\n";
        }
    }
    else
    {
        print $fh $data;
    }

    close $fh;

    return 1;
}

1;
