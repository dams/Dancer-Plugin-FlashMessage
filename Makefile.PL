use ExtUtils::MakeMaker;

WriteMakefile1(
    NAME         => 'Dancer::Plugin::FlashMessage',
    ABSTRACT     => "Plugin for Dancer to display flash messages",
    LICENSE      => 'perl',
    VERSION_FROM => 'lib/Dancer/Plugin/FlashMessage.pm',
    
    META_MERGE => {
        resources => {
            repository => 'http://github.com/dams/Dancer-Plugin-FlashMessage',
        },
    },

    BUILD_REQUIRES => {
        'Test::More' => '0.87',
    },

    PREREQ_PM => {
        'Dancer' => '1.2003',
    },

    test => {TESTS => join( ' ', (glob( 't/*.t'), glob('t/*/*.t')))},
);

sub WriteMakefile1 {  #Written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.

    print STDERR "
WARNING ! This $0 file is provided just for lazy developers to
quickly build this module directly from source, and hack it. However this
module is managed by Dist::Zilla. Serious developers should install
Dist::Zilla, and issue 'dist help' to see how to build and develop it properly.
Especially, build/test/install requires are not properly set in this
file.

Contact the author if you need more help.

Now sleeping 10 secs so you get bored and go install Dist::Zilla :)\n\n";

    sleep 10;

    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;
    delete $params{AUTHOR} if $] < 5.005;
    delete $params{ABSTRACT_FROM} if $] < 5.005;
    delete $params{BINARY_LOCATION} if $] < 5.005;

    WriteMakefile(%params);
}

