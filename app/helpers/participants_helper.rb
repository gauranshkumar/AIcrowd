module ParticipantsHelper
  def avatar_url(participant, size)
    if participant.avatar
      if size == 'profile'
        participant.avatar.url('thumbnail')
      else
        participant.avatar.url(size)
      end
    else
      'https://www.gravatar.com/avatar/?d=mm&s=200'
    end
  end
  # usage:  <%= image_tag avatar_url(user,'medium'), class: "img-responsive" %>
  #         <%= image_tag avatar_url(user,'thumbnail') %>

  def participant_link(participant)
    participant.present? ? participant_path(participant) : '#'
  end

  def rating_tier_class(participant)
    tier = 1
    percentile = (1 - ((participant.ranking - 1).to_f/Participant.rated_users_count))*100
    case percentile
    when 99..100
      tier = 5
    when 95..99
      tier = 4
    when 80..95
      tier = 3
    when 60..80
      tier = 2
    end
    if participant.admin?
      tier = 0
    end
    return "user-rating-" + tier.to_s
  end

  def participant_avatar(participant, base_class='avatar')
    if participant.nil?
      return image_tag '/assets/img/user-avatar-default.svg', class: base_class
    end
    classes = base_class #+ ' ' + rating_tier_class(participant)
    image_url = participant.image_url
    unless base_class.include?('original')
      image_url = image_url.gsub('.com/images', '.com/100x100/images')
    end
    return image_tag image_url, class: classes
  end

  def avatar
    params[:avatar].present? ? params[:avatar] : true
  end

  def location_id(participant)
    uniq_id = SecureRandom.hex(2)
    random_class = uniq_id.to_s + '_' + participant&.id.to_s
    "participant_#{random_class}"
  end

  def followable_and_follow(follow, followers_or_following)
    follow_participant = followers_or_following == 'followers' ? follow.participant : follow.followable
    return { followable: follow_participant, follow: current_participant.following_participant?(follow_participant.id) ? follow : nil }
  end

  def get_award_point_on_day(participant)
    return if participant.nil?

    participant.ml_activity_points.group_by_day(:created_at, format: "%Y-%m-%d").sum_points_by_day
  end

  def global_leaderboard_ranking_change(participant)
    if participant.ratings.count > 1
      previous_rank = participant.ratings.order('created_at desc').second.rank
      current_rank = participant.ratings.order('created_at desc').first.rank
    end

    if participant.ratings.count == 1 || previous_rank == current_rank
      return image_tag(
        "icon-change-none.svg",
        data: { toggle: 'tooltip' },
        title: 'No change')
    end

    if current_rank > previous_rank
      return image_tag("icon-change-down.svg",
        data:  { toggle: 'tooltip' },
        title: "-#{current_rank - previous_rank} change, previous rank #{previous_rank}")
    end

    if current_rank < previous_rank && previous_rank != 0
      return image_tag(
        "icon-change-up.svg",
        data:  { toggle: 'tooltip' },
        title: "+#{previous_rank - current_rank} change, previous rank #{previous_rank}")
    end
  end

  # country gender affiliation empty
  # Probability 1%
  # Have at least one challenge participant
  def show_participant_edit_popup?(participant)
    participant.present? && rand(100) < 2 && participant.gender_cd.blank? && participant.affiliation.blank? && participant.challenge_participants.where(registered: true).exists?
  end

  def show_weekly_challenge_popup
    return false if (Setting.first.weekly_popup_title.blank? || Setting.first.weekly_popup_description.blank? || Setting.first.weekly_popup_button.blank? || Setting.first.weekly_popup_link.blank? || Time.now > Setting.first.weekly_popup_end_date || Time.now < Setting.first.weekly_popup_start_date)
    cookies && cookies['_cookie_eu_consented'] == 'true' && (cookies['_cookie_weekly_challenge'].blank? || (cookies['_cookie_weekly_challenge'] && Date.parse(cookies['_cookie_weekly_challenge']) < Setting.first.weekly_popup_start_date ))
  end
end
