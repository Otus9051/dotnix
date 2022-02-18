#! @perl@/bin/perl -w

use strict;
use DBI;
use DBD::SQLite;
use String::ShellQuote;
use Config;

my $program = $ARGV[0];

my $dbPath = "/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbPath", "", "")
    or die "cannot open database `$dbPath'";
$dbh->{RaiseError} = 0;
$dbh->{PrintError} = 0;

my $system = $ENV{"NIX_SYSTEM"} // $Config{myarchname};

my $res = $dbh->selectall_arrayref(
    "select package from Programs where system = ? and name = ?",
    { Slice => {} }, $system, $program);

if (!defined $res || scalar @$res == 0) {
    print STDERR "$program: command not found\n";
} else {
    my $package = @$res[0]->{package};
    if (defined $ENV{"NIX_AUTO_RUN"} and $ENV{"NIX_AUTO_RUN"} == "0") {
         print STDERR <<EOF;
The program '$program' is not in your PATH. You can make it available in an
ephemeral shell by typing:
  nix-shell -p $package
EOF
    } else {
       print STDOUT "Using $program from package $package\n";
       exec("nix-shell", "-p", $package, "--run", shell_quote("exec", @ARGV));
    }
}

exit 127;
