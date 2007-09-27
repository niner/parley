package Parley::Controller::Terms;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use base 'Catalyst::Controller';

use Parley::App::Terms qw( :terms );

sub auto : Private {
    my ($self, $c) = @_;

    # it's always useful to have a copy of the T&Cs to show
    $c->stash->{latest_terms} =
        $c->model('ParleyDB')->resultset('Terms')->latest_terms();

    return 1;
}

sub index : Private {
    my ( $self, $c ) = @_;
}

sub accept : Local {
    my ( $self, $c ) = @_;

    my $status = $c->login_if_required(
        q{You must be logged in before you can access this area}
    );
    if (not defined $status) {
        return 0;
    }

    # no need to accept the terms again
    my $latest_terms = $c->stash->{latest_terms};
    if ($latest_terms and $latest_terms->user_accepted_latest_terms($c->_authed_user)) {
        $c->response->redirect(
            $c->uri_for('/terms')
        );
        return;
    }

    # make sure to set the template to view as we expect to get forwarded to
    $c->stash->{template} = 'terms/accept';

    # store where they were trying to get to
    if (not $c->session->{after_terms}) {
        $c->session->{after_terms} = $c->request->uri();
    }

    # deal with form submits
    if (defined $c->request->method()
            and $c->request->method() eq 'POST'
    ) {
        if ($c->request->param('terms_reject')) {
            # session logout, and remove information we've stashed
            $c->logout;
            delete $c->session->{'authed_user'};
            $c->response->redirect(
                $c->uri_for($c->config()->{default_uri})
            );
            return;
        }
        elsif ($c->request->param('terms_accept')) {
            # insert the appropriate record
            $c->model('ParleyDB')->resultset('TermsAgreed')->create(
                {
                    person_id   => $c->_authed_user()->id(),
                    terms_id    => $c->stash->{latest_terms}->id(),
                }
            );
            $c->model('ParleyDB')->schema->txn_commit;

            # if we can, send them back to where they were trying to go
            if ( $c->session->{after_terms} ) {
                $c->response->redirect(
                    delete $c->session->{after_terms}
                );
            }
            else {
                $c->response->redirect(
                    $c->uri_for($c->config()->{default_uri})
                );
            }
            return;
        }
    }

    else {
        # otherwise, show the terms to be accepted
    }
}

1;

__END__

=head1 NAME

Parley::Controller::Terms - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut