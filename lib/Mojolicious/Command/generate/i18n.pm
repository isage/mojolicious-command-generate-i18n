package Mojolicious::Command::generate::i18n;

use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojo::Command';

our $VERSION = 0.1;

use File::Find;
use Getopt::Long;
use Locale::PO;

has description => 'Generate i18n lexicon files from po files.';

has usage => '$0 generate i18n [po_dir]';

sub run {
    my $self     = shift;
    my $po_dir = shift || 'I18N';

    my @langs;

    my $app_class = $ENV{MOJO_APP}||'MyApp';
    $app_class =~s|::|/|g;

    local @ARGV = @_ if @_;


    # Find all templates of project
    unless (@langs) {
        find(
            sub {
                push @langs, $File::Find::name if (/\.po$/);
            },
            $po_dir
        );
    }

    foreach my $lang(@langs)
    {
      my $language=$lang;
      $language=~s|$po_dir||;
      $language=~s|/||g;
      $language=~s|\.po||g;
      my $lexem_file = $self->rel_file("lib/$app_class/I18N/$language.pm");
      my %oldlex     = ();

      if (-e $lexem_file) {
            %oldlex = eval {
                require "$app_class/I18N/$language.pm";
                no strict 'refs';
                %{*{"${app_class}::I18N::${language}::Lexicon"}};
            };
            %oldlex = () if ($@);
      }
      my %lexicon = %oldlex;
      my $hash=Locale::PO->load_file_ashash($lang);
      while(my($key,$val)=each(%{$hash}))
      {
        if ($key ne '""')
        {
          my $str="\$lexicon{$key}=".$val->msgstr().";";
          eval($str);
        }
      }
      $lexicon{_AUTO}=1;
      if (-e $lexem_file) {
          open INFILE, '<',$lexem_file;
          my $str;
          while(<INFILE>)
          {
            last if (m/MARKER. DO NOT REMOVE. NO CHANGES BELOW./);
            $str.=$_;
          }
          close INFILE;
          $self->write_file($lexem_file,$str.$self->render_data('lexicon',\%lexicon));
      }
      else
      {
        $self->render_to_file('package', $lexem_file, $app_class, $language,\%lexicon);
      }

    }
}

1;

__DATA__
@@ lexicon
% my ($lexicon) = @_;
# MARKER. DO NOT REMOVE. NO CHANGES BELOW.
our %Lexicon = (
% foreach my $lexem (sort keys %$lexicon) {
    % my $data = $lexicon->{$lexem} || '';
    % $lexem=~s/'/\\'/g;
    % utf8::encode $data;
    % $data =~s/'/\\'/g;
    % if( $data =~ s/\n/\\n/g ){
    %   $data = '"' . $data . '"';
    % } else {
    %   $data = "'${data}'";
    % }
    % unless ($lexem=~s/\n/\\n/g) {
    '<%= $lexem %>' => <%= $data %>,
    % } else {
    "<%= $lexem %>" => <%= $data %>,
    % };
% }
);


@@ package
% my ($app_class, $language, $lexicon) = @_;
package <%= $app_class %>::I18N::<%= $language %>;
use base '<%= $app_class %>::I18N';
use utf8;


# MARKER. DO NOT REMOVE. NO CHANGES BELOW.
our %Lexicon = (
% foreach my $lexem (sort keys %$lexicon) {
    % my $data = $lexicon->{$lexem} || '';
    % $lexem=~s/'/\\'/g;
    % utf8::encode $data;
    % $data =~s/'/\\'/g;
    % if( $data =~ s/\n/\\n/g ){
    %   $data = '"' . $data . '"';
    % } else {
    %   $data = "'${data}'";
    % }
    % unless ($lexem=~s/\n/\\n/g) {
    '<%= $lexem %>' => <%= $data %>,
    % } else {
    "<%= $lexem %>" => <%= $data %>,
    % };
% }
);

1;

__END__

=head1 NAME

Mojolicious::Command::generate::i18n - Generate Lexicon from .po files

=head1 SYNOPSIS

    $ ./script/my_mojolicious_app generate i18n [po_files_location]

This command used to generate Locale::Maketext::Lexicon files for Mojolicious app from .po files.
By default it searches for .po files under I18N dir.
If Lexicon file for language exists files will be merged.

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/isage/mojolicious-command-generate-i18n

=head1 AUTHOR

Epifanov Ivan, C<isage@aumi.ru>.

=head1 CREDITS

This module partly based on Sergey Zasenko (C<undef@cpan.org>) Mojolicious::Command::Generate::Lexicon

=head1 COPYRIGHT

Copyright (C) 2012, Epifanov Ivan

This program is free software, you can redistribute it and/or modify it
under the terms of the Artistic License version 2.0.

=cut
