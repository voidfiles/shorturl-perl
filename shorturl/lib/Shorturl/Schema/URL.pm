package Shorturl::Schema::URL;
use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(urlSchema);


use JSON::Schema;

my $schemaDef = {
  type => 'object',
  properties => {
    url => { type => 'string' },
  }
};

my $urlSchema = JSON::Schema->new($schemaDef);

sub urlSchema { $urlSchema };
# my %params = get_user_input();
# my $valid  = $validator->validate(\%params);
# if ($valid)
# {
#   my $dt = DateTime->new(%params);
#   # do something interesting here with $dt...
# }
# else
# {
#   die join("\n", "Invalid DateTime paramaters", $valid->errors);
# }

1;
