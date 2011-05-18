package Parley::Controller::Forum;
# ABSTRACT: Forum actions controller class
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use base 'Catalyst::Controller';

use Parley::App::Error qw( :methods );

sub setup : Chained('/') PathPart('forum') CaptureArgs(1) {
    my ($self, $c, $forum) = @_;

    # make sure the paramter looks sane
    if (not $forum =~ m{\A\d+\z}) {
        $c->stash->{error}{message} =
                $c->localize('non-integer forum id passed')
            . ': ['
            . $forum
            . ']';
        return;
    }

    # get the matching forum
    $c->_current_forum(
        $c->model('ParleyDB::Forum')->record_from_id(
            $forum
        )
    );
}

sub list : Local {
    my ($self, $c) = @_;

    # get a list of (active) forums
    $c->stash->{forum_list} =
        $c->model('ParleyDB')->resultset('Forum')
            ->forum_list();
}

sub view : Chained('setup') PathPart Args(0) {
    my ($self, $c) = @_;

    if (not defined $c->_current_forum) {
        parley_die($c, $c->localize('There is no current forum to view'));
        return;
    }

    # page to show - either a param, or show the first
    $c->stash->{current_page}= $c->request->param('page') || 1;

    # get a list of (active) threads in a given forum
    $c->stash->{thread_list} =
        $c->model('ParleyDB')->resultset('Thread')->search(
            {
                forum_id    => $c->_current_forum->id(),
                'me.active' => 1,
            },
            {
                join        => 'last_post',
                order_by    => [\'sticky DESC', \'last_post.created DESC'],
                # pager information
                rows        => $c->config->{threads_per_page},
                page        => $c->stash->{current_page},

                prefetch => [
                    { creator => 'authentication' },
                    {'last_post' => { 'creator' => 'authentication' } },
                    'forum',
                ],
            }
        );

    # setup the pager
    $self->_forum_view_pager($c);
}



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller (Private/Helper) Methods
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub _forum_view_pager {
    my ($self, $c) = @_;

    $c->stash->{page} = $c->stash->{thread_list}->pager();

    # TODO - find a better way to do this if possible
    # set up Data::SpreadPagination
    my $pagination = Data::SpreadPagination->new(
        {
            totalEntries        => $c->stash->{page}->total_entries(),
            entriesPerPage      => $c->config->{threads_per_page},
            currentPage         => $c->stash->{current_page},
            maxPages            => 4,
        }
    );
    $c->stash->{page_range_spread} = $pagination->pages_in_spread();
}


1;

__END__

=pod

=head1 NAME

Parley::Controller::Forum - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=cut

vim: ts=8 sts=4 et sw=4 sr sta
