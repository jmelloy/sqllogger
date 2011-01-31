#!/usr/bin/perl

# Jeffrey Melloy <jmelloy@visualdistortion.org>
# $URL$
# $Rev$ $Date$

use warnings;
use strict;
use CGI qw(-no_debug escapeHTML);

my $log_dir = "/Users/jmelloy/gaim/";

open(OUT, "| psql >/dev/null") or die $!;

chdir "$log_dir" or die qq{Log diectory does not exist.};

foreach my $service (glob 'aim') {
    chdir $service;
    print $service . "\n";
    foreach my $login_user (glob '*') {
        chdir $login_user;
        print "\t" . $login_user . "\n";
        foreach my $recip (glob '*') {
            chdir $recip;
            print "\t\t" . $recip . "\n";
            foreach my $logfile (glob '*') {
                print "\t\t\t" . $logfile . "\n";
                $_ = $logfile;

                my ($date) = /(\d\d\d\d\-\d\d\-\d\d)/
                    or die qq{Unable to get date. $!};

                undef $/;

                open (FILE, $logfile) or die qq{Unable to open $logfile: $!};

                my $content = <FILE>;

                close(FILE);

                $content = escapeHTML($content);

                $content =~ s/\n((?!\(\d\d\:\d\d\:\d\d\)[\w\_\.\@\+\- ]*\: ))/<br>$1/g or die $!;

                my @filecontents = split(/\n/, $content);

                for(my $i = 1; $i < @filecontents; $i++) {
                    $_ = $filecontents[$i];

                    my $time;
                    my $sender;
                    my $receiver;
                    my $message;

                    ($time, $sender) = /^\((\d\d\:\d\d\:\d\d)\) ([\w\@\_\.\+\- ]*)\: / or die qq{$!};

                    $_ = $sender;

                    if($sender =~ /$login_user/i) {
                        $receiver = $recip;
                    } else {
                        $receiver = $login_user;
                    }

                    $_ = $filecontents[$i];

                    ($message) = /\)[\w\@\_\.\+\- ]*\: (.*)/ or die
                    qq{$logfile / Line $i / $_: $!};

                    $message =~ s/\\/\\\\/g;
                    $message =~ s/\'/\\\'/g;

                    my $timestamp = $date . " " . $time;

                    my $query = "insert into im.message_v
                        (sender_sn, recipient_sn, message, message_date,
                        sender_service, recipient_service)
                        values
                        (\'$sender\',
                        \'$receiver\',
                        \'$message\',
                        \'$timestamp\',
                        \'$service\',
                        \'$service\');\n";

                    print OUT $query;

                }

                my $backup = $logfile;
                $backup =~ s/\.txt.*/.txt.bak/;
                system('mv',$logfile,$backup);
            }
            chdir "..";
        }
        chdir "..";
    }
    chdir "..";
}
