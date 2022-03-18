# Be sure to restart your server when you modify this file.
#
# +grant_on+ accepts:
# * Nothing (always grants)
# * A block which evaluates to boolean (recieves the object as parameter)
# * A block with a hash composed of methods to run on the target object with
#   expected values (+votes: 5+ for instance).
#
# +grant_on+ can have a +:to+ method name, which called over the target object
# should retrieve the object to badge (could be +:user+, +:self+, +:follower+,
# etc). If it's not defined merit will apply the badge to the user who
# triggered the action (:action_user by default). If it's :itself, it badges
# the created object (new user for instance).
#
# The :temporary option indicates that if the condition doesn't hold but the
# badge is granted, then it's removed. It's false by default (badges are kept
# forever).

module Merit
  class BadgeRules
    include Merit::BadgeRulesMethods

    def initialize
      ### CHALLENGE BADGES

      # Badges for number of submissions

      grant_on 'submissions#create', badge: 'Made Submission', level: 1 do |submission|
        submission.participant.submissions.where(grading_status_cd: 'graded').count >= 10
      end

      grant_on 'submissions#create', badge: 'Made Submission', level: 2 do |submission|
        submission.participant.submissions.where(grading_status_cd: 'graded').count >= 100
      end

      grant_on 'submissions#create', badge: 'Made Submission', level: 3 do |submission|
        submission.participant.submissions.where(grading_status_cd: 'graded').count >= 300
      end

      # Finished in top 20 percentile
      # Finished in top 10 percentile
      # Finished in top 5 percentile

      # Shared Practice Problem
      grant_on 'challenges#shared_challenge', badge: 'Shared Practice Problem', level: 1 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: true).count >= 5
      end

      grant_on 'challenges#shared_challenge', badge: 'Shared Practice Problem', level: 2 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: true).count >= 15
      end

      grant_on 'challenges#shared_challenge', badge: 'Shared Practice Problem', level: 3 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: true).count >= 35
      end

      # Shared Challenges
      grant_on 'challenges#shared_challenge', badge: 'Shared Challenge', level: 1 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 5
      end

      grant_on 'challenges#shared_challenge', badge: 'Shared Challenge', level: 2 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 15
      end

      grant_on 'challenges#shared_challenge', badge: 'Shared Challenge', level: 3 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 35
      end

      grant_on 'challenges#shared_challenge', badge: 'Shared First Challenge', level: 4 do |current_participant|
        challenge_ids = ActivityMeta.where(participant_id: current_participant.id, event: 'shared_challenge').pluck(:acted_on)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 1
      end


      # Participated In Practice Challenge

      grant_on 'submissions#create', badge: 'Participated In Practice Challenge', level: 1 do |submission|
        challenge_ids = submission.participant.submissions.pluck(:challenge_id)
        Challenge.where(id: challenge_ids, practice_flag: true).count >= 10
      end

      grant_on 'submissions#create', badge: 'Participated In Practice Challenge', level: 2 do |submission|
        challenge_ids = submission.participant.submissions.pluck(:challenge_id)
        Challenge.where(id: challenge_ids, practice_flag: true).count >= 20
      end

      grant_on 'submissions#create', badge: 'Participated In Practice Challenge', level: 3 do |submission|
        challenge_ids = submission.participant.submissions.pluck(:challenge_id)
        Challenge.where(id: challenge_ids, practice_flag: true).count >= 30
      end

      grant_on 'submissions#create', badge: 'Participated In First Practice Problem', level: 4 do |submission|
        submission.challenge.practice_flag
      end
      
      # Participated in n number of challenges
      grant_on 'submissions#create', badge: 'Participated Challenge', level: 1 do |submission|
        challenge_ids = submission.participant.submissions.pluck(:challenge_id)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 3
      end

      grant_on 'submissions#create', badge: 'Participated Challenge', level: 2 do |submission|
        challenge_ids = submission.participant.submissions.pluck(:challenge_id)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 9
      end

      grant_on 'submissions#create', badge: 'Participated Challenge', level: 3 do |submission|
        challenge_ids = submission.participant.submissions.pluck(:challenge_id)
        Challenge.where(id: challenge_ids, practice_flag: false).count >= 21
      end

      grant_on 'submissions#create', badge: 'Participated In First Challenge', level: 4 do |submission|
        submission.challenge.practice_flag == false
      end

      # Submission Streak
      grant_on 'submissions#create', badge: 'Submission Streak', level: 1 do |submission|
        submission.participant_streak_days >= 3
      end

      grant_on 'submissions#create', badge: 'Submission Streak', level: 1 do |submission|
        submission.participant_streak_days >= 7
      end

      grant_on 'submissions#create', badge: 'Submission Streak', level: 1 do |submission|
        submission.participant_streak_days >= 30
      end

      # Leaderboard Ninja: TODO
      # Improved Score: TODO

      # Invited User
      grant_on 'team_invitations/acceptances#create', badge: 'Invited User', model_name: "Invitation", level: 1 do |invitation|
        TeamInvitation.where(invitor_id: invitation.invitor_id, status: 'accepted').count >= 1
      end

      grant_on 'team_invitations/acceptances#create', badge: 'Invited User', model_name: "Invitation", level: 1 do |invitation|
        TeamInvitation.where(invitor_id: invitation.invitor_id, status: 'accepted').count >= 5
      end

      grant_on 'team_invitations/acceptances#create', badge: 'Invited User', model_name: "Invitation", level: 1 do |invitation|
        TeamInvitation.where(invitor_id: invitation.invitor_id, status: 'accepted').count >= 15
      end



      ### NOTEBOOK BADGES

      # Create Notebook Badges
      grant_on 'posts#create', badge: 'Created Notebook', model_name: 'Post', level: 1 do |post|
        post.participant.posts.where(private: false).count >= 3
      end

      grant_on 'posts#create', badge: 'Created Notebook', model_name: 'Post', level: 2 do |post|
        post.participant.posts.where(private: false).count >= 10
      end

      grant_on 'posts#create', badge: 'Created Notebook', model_name: 'Post', level: 3 do |post|
        post.participant.posts.where(private: false).count >= 25
      end

      # Won Blitz Community Explainer
      grant_on 'posts#update', badge: 'Blitz Community Contribution Winner', level: 2, to: :participant do |post|
        post.blitz_community_winner
      end

      # Community Contribution Winner
      grant_on 'posts#update', badge: 'Community Contribution Winner', level: 3, to: :participant do |post|
        post.community_contribution_winner
      end

      # Shared Notebook
      grant_on 'badges#shared_notebook', badge: 'Shared Notebook', model_name: 'Participant', level: 1 do |participant|
        participant.points(category: 'Shared Notebook') >= 10
      end

      grant_on 'badges#shared_notebook', badge: 'Shared Notebook', model_name: 'Participant', level: 2 do |participant|
        participant.points(category: 'Shared Notebook') >= 25
      end

      grant_on 'badges#shared_notebook', badge: 'Shared Notebook', model_name: 'Participant', level: 3 do |participant|
        participant.points(category: 'Shared Notebook') >= 40
      end

      grant_on 'badges#shared_notebook', badge: 'Shared Notebook', model_name: 'Participant', level: 4 do |participant|
        participant.points(category: 'Shared Notebook') > 0
      end

      # Notebook Was Shared
      grant_on 'badges#notebook_was_shared', badge: 'Notebook Was Shared', model_name: 'Post', to: :participant, level: 1 do |post|
        post.participant.points(category: 'Notebook Was Shared') >= 3
      end

      grant_on 'badges#notebook_was_shared', badge: 'Notebook Was Shared', model_name: 'Post', to: :participant, level: 2 do |post|
        post.participant.points(category: 'Notebook Was Shared') >= 15
      end

      grant_on 'badges#notebook_was_shared', badge: 'Notebook Was Shared', model_name: 'Post', to: :participant, level: 3 do |post|
        post.participant.points(category: 'Notebook Was Shared') >= 30
      end

      grant_on 'badges#notebook_was_shared', badge: 'Notebook Was Shared', model_name: 'Post', to: :participant, level: 4 do |post|
        post.participant.points(category: 'Notebook Was Shared') >= 1
      end

      # Notebook Was Liked
      grant_on ['votes#create', 'votes#white_vote_create'], badge: 'Notebook Was Liked', level: 1, to: :participant do |vote|
        vote.votable.is_a?(Post) && vote.votable.votes.count >= 5
      end

      grant_on ['votes#create', 'votes#white_vote_create'], badge: 'Notebook Was Liked', level: 2, to: :participant do |vote|
        vote.votable.is_a?(Post) && vote.votable.votes.count >= 20
      end

      grant_on ['votes#create', 'votes#white_vote_create'], badge: 'Notebook Was Liked', level: 3, to: :participant do |vote|
        vote.votable.is_a?(Post) && vote.votable.votes.count >= 35
      end

      # Commented On Notebook
      grant_on ['commontator/comments#create'], badge: 'Commented on Notebook', model_name: 'CommontatorThread', level: 4 do |comment|
        comment.commontable_type == "Post" && CommontatorComment.where(thread_id: comment.id).count >= 1
      end

      grant_on ['commontator/comments#create'], badge: 'Commented On Notebook', model_name: 'CommontatorThread', level: 1 do |comment|
        comment.commontable_type == "Post" && CommontatorComment.where(thread_id: comment.id).count >= 5
      end

      grant_on ['commontator/comments#create'], badge: 'Commented On Notebook', model_name: 'CommontatorThread', level: 2 do |comment|
        comment.commontable_type == "Post" && CommontatorComment.where(thread_id: comment.id).count >= 15
      end

      # Notebook Received Comment
      grant_on ['commontator/comments#create'], badge: 'Notebook Received First Comment', model_name: 'CommontatorThread', to: :post_user, level: 4 do |comment|
        comment.commontable_type == "Post"
      end

      grant_on ['commontator/comments#create'], badge: 'Notebook Received Comment', model_name: 'CommontatorThread', to: :post_user, level: 1 do |comment|
        post_ids = comment.post_user.posts.pluck(:participant_id)
        thread_ids = CommontatorThread.where(commontable_type: 'Post', commontable_id: post_ids).pluck(:id)
        CommontatorComment.where(thread_id: thread_ids).count >= 3
      end

      grant_on ['commontator/comments#create'], badge: 'Notebook Received Comment', model_name: 'CommontatorThread', to: :post_user, level: 2 do |comment|
        post_ids = comment.post_user.posts.pluck(:participant_id)
        thread_ids = CommontatorThread.where(commontable_type: 'Post', commontable_id: post_ids).pluck(:id)
        CommontatorComment.where(thread_id: thread_ids).count >= 15
      end

      grant_on ['commontator/comments#create'], badge: 'Notebook Received Comment', model_name: 'CommontatorThread', to: :post_user, level: 3 do |comment|
        post_ids = comment.post_user.posts.pluck(:participant_id)
        thread_ids = CommontatorThread.where(commontable_type: 'Post', commontable_id: post_ids).pluck(:id)
        CommontatorComment.where(thread_id: thread_ids).count >= 30
      end

      # Bookmarked Notebook
      grant_on 'post_bookmarks#create', badge: 'Bookmarked Notebook', level: 1, model_name: 'Post' do |post|
        post.post_bookmarks.count >= 5
      end

      grant_on 'post_bookmarks#create', badge: 'Bookmarked Notebook', level: 2, model_name: 'Post' do |post|
        post.post_bookmarks.count >= 15
      end

      # Notebook Received Bookmark
      grant_on 'post_bookmarks#create', badge: 'Notebook Received First Bookmark', level: 4, model_name: 'Post', to: :participant do |post|
        post.post_bookmarks.count >= 1
      end

      grant_on 'post_bookmarks#create', badge: 'Notebook Received Bookmark', level: 1, model_name: 'Post', to: :participant do |post|
        post.post_bookmarks.count >= 3
      end

      grant_on 'post_bookmarks#create', badge: 'Notebook Received Bookmark', level: 2, model_name: 'Post', to: :participant do |post|
        post.post_bookmarks.count >= 15
      end

      grant_on 'post_bookmarks#create', badge: 'Notebook Received Bookmark', level: 3, model_name: 'Post', to: :participant do |post|
        post.post_bookmarks.count >= 30
      end

      # Notebook Was Executed
      grant_on 'badges#executed_notebook', badge: 'Notebook Was Executed', model_name: 'Post', to: :participant, level: 1 do |post|
        post.participant.points(category:'Notebook Was Executed') >= 5
      end

      grant_on 'badges#executed_notebook', badge: 'Notebook Was Executed', model_name: 'Post', to: :participant, level: 2 do |post|
        post.participant.points(category: 'Notebook Was Executed') >= 15
      end

      grant_on 'badges#executed_notebook', badge: 'Notebook Was Executed', model_name: 'Post', to: :participant, level: 3 do |post|
        post.participant.points(category: 'Notebook Was Executed') >= 35
      end

      # Created first notebook
      grant_on 'posts#create', badge: 'Created First Notebook', model_name: 'Post', level: 4 do |post|
        post.participant.posts.where(private: false).count >= 1
      end

      # Liked 1 notebook
      grant_on 'votes#create', badge: 'Liked First Notebook', level: 4, to: :participant do |vote|
        vote.participant.votes.where(votable_type: "Post").count >= 1
      end

      # Notebook got first like
      grant_on 'votes#create', badge: 'Notebook Received Like', to: :post_user, level: 4 do |vote|
        vote.votable_type == "Post" &&  Vote.where(votable_type: "Post", votable_id: vote.votable.participant.posts.pluck(:id)).where.not(participant_id: vote.votable.participant.id).count == 1
      end

      # Complete Bio/Profile
      # grant_on 'participants#update', badge: 'Completed Profile', level: 3 do |participant|
      #   participant.website.present? && participant.github.present? && participant.linkedin.present? && participant.twitter.present? && participant.bio.present?
      # end

      # Followed their first Aicrew member
      grant_on 'follows#create', badge: 'Followed First Member', level: 4 do |follow|
        follow.participant.following.where(followable_type: "Participant").count >= 1
      end

      # Got First Follower
      grant_on 'follows#create', badge: 'Got First Follower', level: 4, to: :followable do |follow|
        Follow.where(followable_id: follow.followable_id, followable_type: "Participant").count >= 1
      end

      # Attended First Townhall/Workshop
      # Awarded via Discourse

      # Liked First Challenge
      grant_on 'votes#create', badge: 'Liked First Challenge', level: 4 do |vote|
        vote.participant.votes.where(votable_type: "Challenge").count >= 1
      end

      # First Submission
      grant_on 'submissions#create', badge: 'First Submission', level: 4 do |submission|
        submission.participant.submissions.count >= 1
      end

      # First Successful Submission
      grant_on 'submissions#index', badge: 'First Successful Submission', level: 4 do |current_participant|
        current_participant.submissions.where(grading_status_cd: 'graded').count >= 1
      end

      # Liked First Practice Problem
      # grant_on 'votes#create', badge: 'Liked First Practice Problem', level: 4 do |vote|
      #   challenge_ids = vote.participant.votes.where(votable_type: "Challenge").pluck(:votable_id)
      #   Challenge.where(id: challenge_ids, practice_flag: true).count >= 1
      # end

      # Shared First Practice Problem

      # Followed First Practice Problem
      #  grant_on 'follows#create', badge: 'Followed Practice Challenge', level: 4 do |follow|
      #   followable_ids = Follow.where(participant_id: follow.participant_id, followable_type: "Challenge").pluck(:followable_id)
      #   Challenge.where(id: followable_ids, practice_flag: true).count >= 1
      # end

      # Bookmarked First Notebook
      grant_on 'post_bookmarks#create', badge: 'Bookmarked First Notebook', level: 4, model_name: 'Post' do |post|
        post.post_bookmarks.count >= 1
      end

      # Downloaded First Notebook
      grant_on 'badges#downloaded_notebook', badge: 'Downloaded First Notebook', level: 4

      # Notebook Received Download"
      grant_on 'badges#notebook_received_download', badge: 'Notebook Received Download', model_name: 'Post', to: :participant, level: 4

    end
  end
end
