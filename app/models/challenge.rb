class Challenge < ApplicationRecord
  include Challenges::ImportConstants
  include FriendlyId
  include Markdownable
  include PgSearch::Model
  multisearchable against: [:challenge]

  friendly_id :challenge,
              use: %i[slugged finders history]

  mount_uploader :image_file, ImageUploader
  mount_uploader :social_media_image_file, RawImageUploader
  mount_uploader :banner_file, RawImageUploader
  mount_uploader :banner_mobile_file, RawImageUploader
  mount_uploader :landing_square_image_file, ImageUploader

  belongs_to :clef_task, optional: true
  accepts_nested_attributes_for :clef_task

  has_many :challenges_organizers, dependent: :destroy, class_name: 'ChallengesOrganizer'
  accepts_nested_attributes_for :challenges_organizers, reject_if: :all_blank, allow_destroy: true
  has_many :organizers, through: :challenges_organizers, class_name: 'Organizer'

  has_many :dataset_files, dependent: :destroy
  accepts_nested_attributes_for :dataset_files, reject_if: :all_blank

  has_many :dataset_folders, dependent: :destroy, class_name: 'DatasetFolder'

  has_many :submission_file_definitions, dependent:  :destroy, inverse_of: :challenge
  accepts_nested_attributes_for :submission_file_definitions, reject_if: :all_blank, allow_destroy: true

  has_many :challenge_partners, dependent: :destroy
  accepts_nested_attributes_for :challenge_partners, reject_if: :all_blank, allow_destroy: true

  has_many :challenge_rules, dependent: :destroy, class_name: 'ChallengeRules'
  accepts_nested_attributes_for :challenge_rules, reject_if: :all_blank, allow_destroy: true

  has_many :challenge_participants, dependent: :destroy
  has_many :participants, through: :challenge_participants

  has_many :submissions, dependent: :destroy
  has_many :base_leaderboards, class_name: 'BaseLeaderboard'
  has_many :leaderboards, class_name: 'Leaderboard'
  has_many :ongoing_leaderboards, class_name: 'OngoingLeaderboard'

  has_many :challenge_problems, foreign_key: "challenge_id", class_name: "ChallengeProblems"
  has_many :challenge_leaderboard_extras, foreign_key: "challenge_id", class_name: "ChallengeLeaderboardExtra"

  has_many :votes, as: :votable
  has_many :follows, as: :followable

  # We may need to remove the following 3
  has_many :participant_challenges, class_name: 'ParticipantChallenge'
  has_many :participant_challenge_counts, class_name: 'ParticipantChallengeCount'
  has_many :challenge_registrations, class_name: 'ChallengeRegistration'

  has_many :challenge_rounds, dependent: :destroy, inverse_of: :challenge
  accepts_nested_attributes_for :challenge_rounds, reject_if: :all_blank

  has_many :invitations, dependent: :destroy
  accepts_nested_attributes_for :invitations, reject_if: :all_blank, allow_destroy: true

  has_many :teams, inverse_of: :challenge, class_name: 'Team'
  has_many :team_participants, through: :teams, class_name: 'TeamParticipant'

  has_many :category_challenges, dependent: :destroy
  accepts_nested_attributes_for :category_challenges, reject_if: :all_blank

  has_many :categories, through: :category_challenges
  has_many :newsletter_emails, class_name: 'NewsletterEmail'
  has_many :notifications, class_name: 'Notification'
  has_many :participant_ml_challenge_goals, dependent: :destroy
  has_many :ml_activity_points
  has_many :posts
  has_many :locked_submissions
  has_one :challenge_property
  has_many :baselines
  has_paper_trail

  as_enum :status,
          %i[draft running completed starting_soon],
          map: :string

  validates :status, presence: true
  validates :challenge, presence: true
  validates :challenge_client_name, uniqueness: true
  validates :challenge_client_name,
            format: { with: /\A[a-zA-Z0-9]/ }
  validates :challenge_client_name, presence: true
  validates :slug, uniqueness: true
  validate :other_scores_fieldnames_max
  validate :greater_than_zero
  #validate :banner_color, format: { with: /\A#?(?:[A-F0-9]{3}){1,2}\z/i }

  EVALUATOR_TYPES = {
    'Not Configured' => :not_configured,
    'CSV Submissions (v1, Default)' => :broker,
    'GitLab Submissions (v1)' => :gitlab,
    'Evaluations API (v2, Beta)' => :evaluations_api
  }.freeze

  SUBMISSION_WINDOW_TYPES = {
    'Rolling window (counts submission in last X hrs)' => :rolling_window,
    'Fixed window (counts submission since 00:00 UTC)' => :fixed_window
  }

  as_enum :evaluator_type, EVALUATOR_TYPES.keys(), map: :string

  default_scope do
    order("challenges.featured_sequence,
            CASE challenges.status_cd
              WHEN 'running' THEN 1
              WHEN 'starting_soon' THEN 2
              WHEN 'completed' THEN 3
              WHEN 'draft' THEN 4
              ELSE 5
            END, challenges.participant_count DESC")
  end
  scope :prize_cash, -> { where.not(prize_cash: [nil, ""]) }
  scope :prize_travel, -> { where.not(prize_travel: [nil, ""]) }
  scope :prize_academic, -> { where.not(prize_academic: [nil, ""]) }
  scope :prize_misc, -> { where.not(prize_misc: [nil, ""]) }
  scope :practice, -> { where(practice_flag: true) }
  scope :not_practice, -> { where(practice_flag: false) }
  scope :editors_selections, -> { where(editors_selection: true) }
  scope :not_editors_selections, -> { where(editors_selection: false) }
  scope :draft_or_private, -> { where("status_cd = 'draft' OR private_challenge = TRUE") }

  after_initialize :set_defaults
  after_commit :create_discourse_category, on: :create
  after_commit :create_default_associations, on: :create

  after_commit :update_discourse_category, on: :update
  after_commit :update_discourse_permissions, on: :update

  def to_s
     self.challenge
  end

  def record_page_view(parent_meta_challenge)
    if parent_meta_challenge.present?
      parent_meta_challenge.challenge_property.update!(page_views: parent_meta_challenge.challenge_property.page_views.to_i + 1)
    end

    challenge_property = self.challenge_property
    challenge_property.update!(page_views: challenge_property.page_views.to_i + 1)
  end

  def participants_and_organizers
    participants + organizers.flat_map { |organizer| organizer.participants }
  end

  def status_formatted
    'Starting soon' if status == :starting_soon
    status.capitalize
  end

  def start_dttm
    @start_dttm ||= begin
                      return nil if active_round.nil? || active_round.start_dttm.nil?

                      active_round.start_dttm
                    end
  end

  def end_dttm
    @end_dttm ||= begin
                    return nil if active_round.nil? || active_round.end_dttm.nil?

                    active_round.end_dttm
                  end
  end

  def submissions
    if meta_challenge?
      return Submission.where(meta_challenge_id: id)
    elsif ml_challenge?
      return Submission.where(ml_challenge_id: id)
    end
    return super
  end

  def submissions_remaining(participant_id, debug_submission=false)
    SubmissionsRemainingQuery.new(challenge: self, participant_id: participant_id, debug_submission: debug_submission).call
  end

  def active_round
    @active_round ||= challenge_rounds.find_by(active: true)
  end

  def previous_round
    previous_rounds = challenge_rounds.where("start_dttm < ?", active_round.start_dttm)
    return nil if previous_rounds.count == 0

    previous_rounds.last
  end

  def round_open?
    @round_open ||= active_round.present?
  end

  def should_generate_new_friendly_id?
    challenge_changed?
  end

  def post_challenge_submissions?
    post_challenge_submissions
  end

  def current_challenge_rules
    ChallengeRules.where(challenge_id: id).order('version DESC').first
  end

  def baseline_discussion
    discource_baselines = Discourse::FetchBaselineTagService.new(challenge: self).call
    discource_baselines.value if discource_baselines.success?
  end

  def has_accepted_challenge_rules?(participant)
    return false unless participant

    cp = ChallengeParticipant.where(challenge_id: id, participant_id: participant.id).first
    return false unless cp
    return false if cp.challenge_rules_accepted_version != current_challenge_rules&.version
    return false unless cp.challenge_rules_accepted_date

    true
  end

  def other_scores_fieldnames_max
    errors.add(:other_scores_fieldnames, 'A max of 5 other scores Fieldnames are allowed') if other_scores_fieldnames && (other_scores_fieldnames.count(',') > 4)
  end

  def greater_than_zero
    errors.add(:featured_sequence, 'should be greater than zero') if featured_sequence.to_i <= 0
  end

  def teams_frozen?
    if status == :completed
      # status set
      true
    else
      ended_at = team_freeze_time || end_dttm
      if ended_at && Time.zone.now > ended_at
        # there is an end date and we are past it
        true
      else
        false
      end
    end
  end

  def other_scores_fieldnames_array(participant_id=nil)
    participant = Participant.find(participant_id)

    challenge_problems = if participant.present?
                           return self.challenge_problems if participant&.admin?
                           return self.challenge_problems unless participant.present?

                           challenge_participant = participant.challenge_participants.where(challenge_id: id).first

                           return self.challenge_problems unless challenge_participant.present?

                           day_num               = (Time.now.to_date - challenge_participant.challenge_rules_accepted_date.to_date).to_i + 1
                           self.challenge_problems.where("occur_day <= ?", day_num)
                         else
                           self.challenge_problems
                         end

    if meta_challenge || ml_challenge
      return challenge_problems.pluck('challenge_round_id')
    end
    arr = other_scores_fieldnames
    arr&.split(',')&.map(&:strip) || []
  end

  def hidden_in_discourse?
    draft? || private_challenge?
  end

  def problems
    if meta_challenge? || ml_challenge
      problems = []
      challenge_problems.order('challenge_problems.weight').pluck('problem_id').each do |challenge_id|
          problems.push(Challenge.where(id: challenge_id)[0])
      end
      return problems
    end
  end

  def meta_active_round_ids
    if meta_challenge?
      return challenge_problems.pluck('challenge_round_id')
    end
  end

  def teams_participant_count
    TeamParticipant.where(team_id: team_ids).count
  end

  def challenge_problem
    ChallengeProblems.find_by(problem_id: id)
  end

  def is_a_problem?
    challenge_problem.present?
  end

  def image_url
    image_file_url.present? ?  image_file_url : get_default_image
  end

  def social_media_image_url
    social_media_image_file_url.present? ?  social_media_image_file_url : nil
  end

  def get_default_image
    num = id % 2
    path = "/assets/images/challenges/AIcrowd-ProblemStatements-#{num}.jpeg"
    if ENV['CLOUDFRONT_IMAGES_DOMAIN'].present?
      domain = ENV['CLOUDFRONT_IMAGES_DOMAIN']
      unless domain.include?("http")
        domain = "https://" + domain
      end
      path = domain + path
    end
    return path
  end

  def challenge_type
    if ml_challenge
      'ml_challenge'
    elsif meta_challenge
      'meta_challenge'
    end
  end

  def locked_submission(participant)
    team = participant.teams.where(challenge_id: self.id).first
    participant_ids = team.team_participants.pluck(:participant_id) if team.present?
    participant_ids = participant.id if participant_ids.blank?
    LockedSubmission.where(challenge_id: self.id, locked_by: participant_ids).first
  end

  private

  def set_defaults
    if new_record?
      self.challenge_client_name ||= "challenge_#{SecureRandom.hex}"
      self.featured_sequence     ||= Challenge.count + 1
      self.team_freeze_time      ||= Time.now.utc + 2.months + 3.weeks
    end
  end

  def create_default_associations
    ChallengeRound.create!(challenge: self)
    ChallengeRules.create!(challenge: self)
    ChallengeProperty.create!(challenge: self)
  end

  def create_discourse_category
    return if Rails.env.development? || Rails.env.test?

    Discourse::CreateCategoryJob.perform_later(id)
  end

  def update_discourse_category
    return if Rails.env.development? || Rails.env.test?
    if self.discourse_category_id.blank?
      Discourse::CreateCategoryJob.perform_later(id)
      return
    end
    return unless saved_change_to_attribute?(:challenge)

    Discourse::UpdateCategoryJob.perform_later(id)
  end

  def update_discourse_permissions
    return if Rails.env.development? || Rails.env.test?
    return unless saved_change_to_attribute?(:private_challenge) || saved_change_to_attribute?(:status_cd)

    Discourse::UpdatePermissionsJob.perform_later(id)
  end
end
