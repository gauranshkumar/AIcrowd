class DiscourseBadgesDailyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user_badges = get_badges
    while user_badges.present? && user_badges.kind_of?(Array) do
      user_badges.each do |user_badge|
        participant = Participant.find_by(name: user_badge['username'])
        if participant.present?
          badge = AicrowdBadge.where(name: user_badge['badge_name'].strip,
                                      level: [user_badge['badge_type_id'], 4]).order('level')&.first
          if badge.present?
            participant.add_badge(badge)
            # NotificationService.new(participant.id, badge, 'badge').call
          end
        end
      end
      last_id = user_badges.last['id']
      DiscourseUserBadgesMetum.create(previous_id: last_id)
      user_badges = get_badges
    end
  end

  private

  def get_badges
    previous_id = DiscourseUserBadgesMetum.order(:created_at).last&.previous_id.to_i
    Discourse::FetchBadgesService.new(previous_id).call.value
  end
end
