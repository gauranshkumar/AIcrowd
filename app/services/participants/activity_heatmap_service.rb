module Participants
  class ActivityHeatmapService < ::BaseService
    VALUE_OF_VISIT      = 1.freeze
    VALUE_OF_SUBMISSION = 10.freeze

    def initialize(participant:, blitz: nil)
      @participant = participant
      @blitz = false;
      if blitz.present?
        @blitz = true;
      end
    end

    def call
      if @blitz
        activity = aicrowd_visits.map do |key, value|
          {
            date:                 key,
            val:                  activity_value(aicrowd_visits[key].to_i, aicrowd_submissions[key].to_i, gitlab_contributions[key].to_i),
            visits:               aicrowd_visits[key].to_i,
            submissions:          aicrowd_submissions[key].to_i
          }
        end
      else
        activity = aicrowd_visits.map do |key, value|
          {
            date:                 key,
            val:                  activity_value(aicrowd_visits[key].to_i, aicrowd_submissions[key].to_i, gitlab_contributions[key].to_i),
            visits:               aicrowd_visits[key].to_i,
            submissions:          aicrowd_submissions[key].to_i,
            gitlab_contributions: gitlab_contributions[key].to_i
          }
        end
      end

      activity_data = activity.sort_by { |entry| entry[:date] }

      success(activity_data)
    end

    private

    attr_reader :participant

    def activity_value(visits_count, submissions_count, gitlab_contributions)
      visits_count * VALUE_OF_VISIT + submissions_count * VALUE_OF_SUBMISSION + gitlab_contributions
    end

    def aicrowd_visits
      @aicrowd_visits ||= participant.visits.group_by_day(:started_at, range: time_range).count
    end

    def aicrowd_submissions
      if @blitz
        @aicrowd_submissions ||= participant.submissions.where(challenge_id: BlitzPuzzle.all.pluck(:challenge_id)).group_by_day(:created_at, range: time_range).count
      else
        @aicrowd_submissions ||= participant.submissions.group_by_day(:created_at, range: time_range).count
      end
    end

    def gitlab_contributions
      @gitlab_contributions ||= gitlab_activity
    end

    def gitlab_activity
      result = Rails.cache.fetch("gitlab-activity-calendar/#{participant.name}", expires_in: 15.minutes) do
        Gitlab::FetchCalendarActivityService.new(participant: participant).call
      end

      if result.success?
        result.value
      else
        {}
      end
    end

    def time_range
      if @blitz
        return 3.month.ago.midnight..Time.current.midnight
      else
        time_range_end = Time.current + 1.day
        return 1.year.ago.midnight..time_range_end
      end
    end
  end
end
