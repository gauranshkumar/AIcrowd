class BlitzPuzzle < ApplicationRecord
  belongs_to :challenge
  belongs_to :blitz_category
  before_save :onsave

  def onsave
    if self.start_date.present?
      self.end_date = self.start_date + self.duration.days
    end
  end

  def percentile(current_participant)
    rank = 0
    rank_total = self.challenge.ongoing_leaderboards.count + 1
    if current_participant.present?
      rank = self.challenge.ongoing_leaderboards.where(
              submitter_id: current_participant.id,
              submitter_type: 'Participant',
              meta_challenge_id: nil,
            ).first&.row_num || 0
    end
    (rank*100/ rank_total).ceil
  end
end
