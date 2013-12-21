#!/usr/bin/env gawk
# needs header_file defined
function print_line() {
  printf( "%-18s%6s/%-12s # %s\n", service, port, proto, rest );
}

function print_regular() {
  if ( proto == 0 ) {
    proto = "tcp";
    print_line();

    proto = "udp";
    print_line();

    proto = 0;
  } else {
    print_line();
  }
}


BEGIN {
  if (strip == "yes") {
    strip = 1;
  }
  started = 0;
  finished = 0;

  while( (getline line < header_file) > 0 ) {
    print "# " line;
  }
}

{
  if ( $0 ~ /Transport/ ) {
    started = 1;
  }
  if ( $0 ~ /ARGUS Protocol/ ) {
    finished = 1;
  }
  if ( started > 0 && started < 5 ) {
    started++;
  }
  if ( started == 5 && finished != 1 ) {
    if ( $0 !~ /^Apple Remote|^Assistant)/ ) {
      if ( $0 ~ /^                |^Service/ && strip != 1) { 
        print "#  " $0;

      } else if ( $2 ~ /-/ ) {
        rest = $0;
        service = $1;
        proto = $3;
        if ( proto ~ /tcp|udp|dccp|sctp/ ) {
          sub(/^ *[^ ]+/, "", rest);
        } else {
          proto = 0;
        }
        sub(/^ *[^ ]+/, "", rest);
        sub(/^ *[^ ]+/, "", rest);
        sub(/^ */, "", rest);

        port = $2;
        end = $2;
        sub(/-.+/, "", port);
        sub(/.+-/, "", end);
        while(port <= end)  {
          print_regular();
          port++;
        }
      } else if ( $1 != "" && $2 != "" ) {
        service = $1;
        port = $2;
        proto = $3;
        rest = $0;
        if ( proto ~ /tcp|udp|dccp|sctp/ ) {
          sub(/^ *[^ ]+/, "", rest);
        } else {
          proto = 0;
        }
        sub(/^ *[^ ]+/, "", rest);
        sub(/^ *[^ ]+/, "", rest);
        sub(/^ */, "", rest);

        if ( $1 == "Desktop" && $2 == "(Net" ) {
          $1 = "apple-rmt-dsktop";
          $2 = $3;
          $3 = $4;
          sub(/^ *[^ ]+/, "", rest)
        } else if ( $1 == "Escale" && $2 == "(Newton" ) {
          $1 = "escale-newton-dock";
          $2 = $3;
          $3 = $4;
          sub(/^ *[^ ]+/, "", rest)
        }
        print_regular();
      }
    }
  }
}
