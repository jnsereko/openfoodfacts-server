# This file is part of Product Opener.
# 
# Product Opener
# Copyright (C) 2011-2015 Association Open Food Facts
# Contact: contact@openfoodfacts.org
# Address: 21 rue des Iles, 94100 Saint-Maur des Foss�s, France
# 
# Product Opener is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# startup file for preloading modules into Apache/mod_perl when the server starts
# (instead of when each httpd child starts)
# see http://apache.perl.org/docs/1.0/guide/performance.html#Code_Profiling_Techniques
#
use strict;

use Carp ();

eval { Carp::confess("init") };

# used for debugging hanging httpd processes
# http://perl.apache.org/docs/1.0/guide/debug.html#Detecting_hanging_processes
$SIG{'USR2'} = sub { 
   Carp::confess("caught SIGUSR2!");
};

use CGI ();
CGI->compile(':all');

use Storable ();
use LWP::Simple ();
use LWP::UserAgent ();
use Image::Magick ();
use File::Copy ();
use XML::Encoding ();
use Encode ();
use Cache::Memcached::Fast ();
use URI::Escape::XS ();
use Algorithm::CheckDigits ();
use Clone ();
use Crypt::PasswdMD5 ();
use DateTime ();
use DateTime::Format::CLDR ();
use DateTime::Format::Mail ();
use DateTime::Locale ();
use Digest::MD5 ();
use Encode::Punycode ();
use File::Path ();
use HTML::Defang ();
use HTML::Entities ();
use Image::OCR::Tesseract ();
use JSON ();
use List::Util ();
use MongoDB ();

# Needs to be configured
use lib "/home/off/lib/";

use ProductOpener::Lang qw/:all/;

use ProductOpener::Store qw/:all/;
use ProductOpener::Config qw/:all/;
use ProductOpener::Display qw/:all/;
use ProductOpener::Products qw/:all/;
use ProductOpener::Food qw/:all/;
use ProductOpener::Images qw/:all/;
use ProductOpener::Index qw/:all/;
use ProductOpener::Version qw/:all/;

use Apache2::Const -compile => qw(OK);
use Apache2::Connection ();
use Apache2::RequestRec ();
use APR::Table ();


$Apache::Registry::NameWithVirtualHost = 0; 

sub My::ProxyRemoteAddr ($) {
  my $r = shift;

  # we'll only look at the X-Forwarded-For header if the requests
  # comes from our proxy at localhost
  return Apache2::Const::OK
      unless (($r->useragent_ip eq "127.0.0.1") 
	or 1	# all IPs
)
          and $r->headers_in->get('X-Forwarded-For');

  # Select last value in the chain -- original client's ip
  if (my ($ip) = $r->headers_in->get('X-Forwarded-For') =~ /([^,\s]+)$/) {
    $r->useragent_ip($ip);
  }

  return Apache2::Const::OK;
}

print STDERR "version: $ProductOpener::Version::version\n";

1;
