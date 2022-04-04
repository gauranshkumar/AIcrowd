class LandingPageController < ApplicationController
  def index
    @challenge_list_data = Rails.cache.fetch('challenge-list-data', expires_in: 20.minutes) do
      get_challenge_list_data
    end

    @landing_challenge_card_1 = Rails.cache.fetch('featured-challenge-1', expires_in: 20.minutes) do
      get_featured_challenge_1
    end

    @landing_challenge_card_2 = Rails.cache.fetch('featured-challenge-2', expires_in: 20.minutes) do
      get_featured_challenge_2
    end

    @landing_challenge_card_3 = Rails.cache.fetch('featured-challenge-3', expires_in: 20.minutes) do
      get_featured_challenge_3
    end

    @notebook_card_data = Rails.cache.fetch('featured-notebooks', expires_in: 20.minutes) do
      get_featured_notebooks
    end

    get_menu_items
    get_stat_list_data
    get_quotes

    @submission_card_data = Rails.cache.fetch('featured-discussions', expires_in: 20.minutes) do
      get_discourse_data
    end

    @community_members_list = Rails.cache.fetch('community-members-list', expires_in: 20.minutes) do
      get_community_members_list
    end

  end

  def host
    @page_title     = "Organize"
    @challenge_call = ChallengeCall.first
  end

  # cardBadge = {
  #   cardBadge: true,
  #   badgeColor: '#44B174',
  #   challengeEndDate: '2021/10/30',
  # }

  private

  def get_challenge_list_data
    customAvatar1 = "https://images.aicrowd.com/images/landing_page/custom-avatar-1.png"
    customAvatar2 = "https://images.aicrowd.com/images/landing_page/custom-avatar-2.png"
    customAvatar3 = "https://images.aicrowd.com/images/landing_page/custom-avatar-3.png"
    customAvatar4 = "https://images.aicrowd.com/images/landing_page/custom-avatar-4.png"
    customAvatar5 = "https://images.aicrowd.com/images/landing_page/custom-avatar-5.png"

    challenge_list_data = []
    challenges = Challenge
        .includes(:organizers)
        .where(private_challenge: false)
        .where(hidden_challenge: false)
        .where.not(status_cd: :draft)
        .limit(9)

    challenges.each do |challenge|
      challenge_organizers = []
      challenge.organizers.each do |organizer|
        challenge_organizers << {
          name: organizer.organizer,
          logo: organizer.image_file.url.gsub('.com/images', '.com/25x25/images'),
          link: organizer_path(organizer),
        }
      end
      users = []
      challenge.challenge_participants.includes(:participant).sample(20).map(&:participant).sample(4).each do |participant|
        users << {id: participant.id, image: participant.image_url.gsub('.com/images', '.com/32x32/images'), tier: 0}
      end

      challenge_list_data << {
        userCount: challenge.challenge_participants.count,
        image: challenge.landing_square_image_file.url.gsub('.com/images', '.com/180x180/images'),
        url: "/challenges/" + challenge.slug,
        name: challenge.challenge,
        prize: challenge.landing_card_prize.split(', '),
        users: users,
        userCount: challenge.challenge_participants.count,
        loading: false,
        onCard: false,
        size: 'default',
        color: challenge.banner_color.presence ||'#FFFFFF',
        cardBadge: (challenge.status_cd == "running"),
        badgeColor: '#44B174',
        challengeEndDate: challenge.active_round.end_dttm,
        organizers: challenge_organizers,
        isOngoing: (challenge.status_cd == "running")
      }
    end
    return challenge_list_data
  end

  def get_featured_challenge_1
    challenge_1 = Challenge
        .includes(:organizers)
        .where(private_challenge: false)
        .where(hidden_challenge: false)
        .where.not(status_cd: :draft)
        .where(feature_challenge_1: true)
        .first

    users = []
    challenge_1.challenge_participants.sample(20).map(&:participant).sample(4).each do |participant|
      users << {id: participant.id, image: participant.image_url.gsub('.com/images', '.com/32x32/images'), tier: 0}
    end

    challenge_organizers = []
    challenge_1.organizers.each do |organizer|
      challenge_organizers << {
        name: organizer.organizer,
        logo: organizer.image_file.url.gsub('.com/images', '.com/25x25/images'),
        link: organizer_path(organizer),
      }
    end

    landing_challenge_card_1 = {
      userCount: challenge_1.challenge_participants.count,
      image: challenge_1.landing_square_image_file.url.gsub('.com/images', '.com/180x180/images'),
      url: "/challenges/" + challenge_1.slug,
      name: challenge_1.challenge,
      prize: challenge_1.landing_card_prize.split(', '),

      users: users,
      userCount: challenge_1.challenge_participants.count,
      loading: false,
      onCard: false,
      size: 'default',
      color: challenge_1.banner_color.presence ||'#FFFFFF',
      cardBadge: (challenge_1.status_cd == "running"),
      badgeColor: '#44B174',
      challengeEndDate: challenge_1.active_round.end_dttm,
      organizers: challenge_organizers,
      isOngoing: (challenge_1.status_cd == "running")
    }
  end

  def get_featured_challenge_2
    challenge_2 = Challenge
        .includes(:organizers)
        .where(private_challenge: false)
        .where(hidden_challenge: false)
        .where.not(status_cd: :draft)
        .where(feature_challenge_2: true)
        .first

    users = []
    challenge_2.challenge_participants.sample(20).map(&:participant).sample(4).each do |participant|
      users << {id: participant.id, image: participant.image_url.gsub('.com/images', '.com/32x32/images'), tier: 0}
    end

    challenge_organizers = []
    challenge_2.organizers.each do |organizer|
      challenge_organizers << {
        name: organizer.organizer,
        logo: organizer.image_file.url.gsub('.com/images', '.com/25x25/images'),
        link: organizer_path(organizer),
      }
    end

    landing_challenge_card_2 = {
      userCount: challenge_2.challenge_participants.count,
      image: challenge_2.landing_square_image_file.url.gsub('.com/images', '.com/180x180/images'),
      url: "/challenges/" +challenge_2.slug,
      name: challenge_2.challenge,
      prize: challenge_2.landing_card_prize.split(', '),

      users: users,
      userCount: challenge_2.challenge_participants.count,
      loading: false,
      onCard: false,
      size: 'default',
      color: challenge_2.banner_color.presence || '#FFFFFF',
      cardBadge: (challenge_2.status_cd == "running"),
      badgeColor: '#44B174',
      challengeEndDate: challenge_2.active_round.end_dttm,
      organizers: challenge_organizers,
      isOngoing: (challenge_2.status_cd == "running")
    }
  end

  def get_featured_challenge_3
    challenge_3 = Challenge
        .includes(:organizers)
        .where(private_challenge: false)
        .where(hidden_challenge: false)
        .where.not(status_cd: :draft)
        .where(feature_challenge_3: true)
        .first

    users = []
    challenge_3.challenge_participants.sample(20).map(&:participant).sample(4).each do |participant|
      users << {id: participant.id, image: participant.image_url.gsub('.com/images', '.com/32x32/images'), tier: 0}
    end

    challenge_organizers = []
    challenge_3.organizers.each do |organizer|
      challenge_organizers << {
        name: organizer.organizer,
        logo: organizer.image_file.url.gsub('.com/images', '.com/25x25/images'),
        link: organizer_path(organizer),
      }
    end

    landing_challenge_card_3 = {
      userCount: challenge_3.challenge_participants.count,
      image: challenge_3.landing_square_image_file.url.gsub('.com/images', '.com/180x180/images'),
      url: "/challenges/" + challenge_3.slug,
      name: challenge_3.challenge,
      prize: challenge_3.landing_card_prize.split(', '),

      users: users,
      userCount: challenge_3.challenge_participants.count,
      loading: false,
      onCard: false,
      size: 'default',
      color: challenge_3.banner_color.presence || '#FFF',
      cardBadge: (challenge_3.status_cd == "running"),
      badgeColor: '#44B174',
      challengeEndDate: challenge_3.active_round.end_dttm,
      organizers: challenge_organizers,
      isOngoing: (challenge_3.status_cd == "running")
    }
  end



  def get_featured_notebooks
    notebook_card_data = []
    posts = Post.where.not(thumbnail: nil)
      .where(featured: true)
      .includes(:participant)
      .limit(4)

    posts.each do |post|
      notebook_card_data << {
        url: "/showcase/" + post.slug,
        title: post.title,
        description: post.tagline,
        lastUpdated: helpers.discourse_time_ago(post.updated_at),
        image: post.thumbnail_url.gsub('.com/raw_images', '.com/75x75/raw_images'),
        author: post.participant.name
      }
    end
    return notebook_card_data
  end

  def get_menu_items
    @more_menu_item = [
      {
        name: 'Organize a challenge',
        link: landing_page_host_path,
      },
      {
        name: 'Our Team',
        link: team_members_path,
      },
      {
        name: 'Jobs',
        link: job_postings_path,
      }
    ]

    @community_menu_item = [
      {
        name: 'Blog',
        link: "https://blog.aicrowd.com/",
      },
      {
        name: 'Forum',
        link: ENV['DISCOURSE_DOMAIN_NAME'],
      },
      {
        name: 'Showcase',
        link: posts_path,
      }
    ]

    @challenges_menu_item = {
      name: 'challenges',
      link: challenges_path,
    }

    @research_menu_item = {
      name: 'Research',
      link: publications_path,
    }

    @profile_menu_item = [
      {
        name: 'Profile',
        link: current_participant.present? ? participant_path(current_participant) : '/'
      },
      {
        name: 'Account Setting',
        link: current_participant.present? ? edit_participant_registration_path : '/'
      },
      {
        name: 'Notifications',
        link: current_participant.present? ? participant_notifications_message_path(current_participant): '/'
      },
      {
        name: 'Sign Out',
        link: current_participant.present? ? destroy_participant_session_path + '?key=' + Digest::MD5.hexdigest(current_participant.confirmation_token) : '/'
      },
    ]

    @community_map = 'https://images.aicrowd.com/images/landing_page/map.svg'
    @community_map_avatar = 'https://images.aicrowd.com/images/landing_page/map-avatar.png'

    @research_menu_item = {
      name: 'Research',
      link: '/research'
    }


    @notification_data = []
    if @notifications.present?
      @notifications[0..5].each do |notification|
         @notification_data << {text: "<b>" + (notification.notifiable_type || '') + "</b> " + (notification.message || ''), image: notification.thumbnail_url, date: notification.created_at, url: notification.notification_url}
      end
    end
  end

  def get_discourse_data
    @discourse_topics = Discourse::FetchLatestTopicsService.new.call

    @discourse_top_contributors_fetch = Discourse::FetchTopContributorsService.new.call
    @discourse_top_contributors = @discourse_top_contributors_fetch.value


    submission_card_data = []
    @discourse_topics.each do |val|
      submission_card_data << {
        url: "//discourse.aicrowd.com/t/#{val[1]}/#{val[0]}",
        title: val[2],
        description: val[3],
        comment_count: val[4],
        isComment: true,
        image: (Participant.find_by_name(val[5]).image_url.gsub('.com/images', '.com/32x32/images')),
        onCard: true,
        borderColor: '#fff',
        tier: 0
      }
    end
    return submission_card_data
  end

  def get_quotes
    @quotes =  {
      leaderDescription:
        '1-2 Sentences related to how these winners were selected or what does leaderboard winners mean.',
      quote: 'I love you the more in that I believe you had liked me for my own sake and for nothing else',
      author: 'John Keats',
      borderColor: 'red',
      image: 'https://images.aicrowd.com/images/landing_page/custom-avatar-1.png',
      quotes: [
        {
          quote:
            'Crowdsourcing far exceeded our expectations - you not only get #new solutions#, but also a #deeper insight to the problem# you are trying to #solve#.',
          author: 'Erik Nygren',
          post: 'Deep Learning and Artificial Intelligence Research, SBB CFF FFS',
          image: 'https://www.aicrowd.com/assets/img/testimonial-1.jpeg',
        },
        {
          quote: 'Thanks to the #agile structure# of the platform, it was #easy to design# an ML challenge #outside of the standard# framework of the training/test data challenges. For new challenges, I would #choose AIcrowd# over other platforms.',
          author: 'Łukasz Kidziński',
          post: 'Postdoctoral Researcher, Stanford',
          image: 'https://www.aicrowd.com/assets/img/testimonial-2.jpeg',
        },
        {
          quote:
            'AIcrowd was the #only platform# that was #flexible enough# to adapt to our #research vision# & execute the required interactive simulation to the specs. The team was #constantly on-call# & implemented #new ideas# to improve the challenge experience. Will definitely #work with them again#.',
          author: 'Ali Farzanehfar',
          post: 'Organizer, Insurance Pricing Game | PhD Student, Imperial College London',
          image:
            'https://media-exp1.licdn.com/dms/image/D4D03AQEUWkCeTN6jCQ/profile-displayphoto-shrink_800_800/0/1639168635336?e=1648080000&v=beta&t=mX8oJz2EV8_7V4afqk_bQsX_BHJOwRBLglxOzQzb1e0 ',
        },
        {
          quote:
            'AIcrowd allows more #flexibility# of evaluation metrics than #other platforms#. We also got #great support# from AIcrowd Research in establishing all #baseline codes#, which made it #easier# for people to join the challenge. Overall, the challenge has been #great for our lab!#',
          author: 'Ann Kennedy',
          post: 'Assistant Professor, Department of Neuroscience, Northwestern University',
          image: 'https://cpb-us-e1.wpmucdn.com/sites.northwestern.edu/dist/6/5099/files/2020/11/Ann_new.width-350.jpg ',
        }

      ],
    }
  end

  def get_stat_list_data
    @stat_list_data = [
        {
          count: 244,
          statText: 'Completed Challenges',
        },
        {
          count: '57k',
          statText: 'Community Members',
        },
        {
          count: '$772k',
          statText: 'Awarded in Prizes',
        },
        {
          count: '60',
          statText: 'Research Papers Published',
        },
        {
          count: '13 TB',
          statText: 'Codes, Models & Datasets Hosted',
        },
      ]
  end

  def get_community_members_list
    participants = []
    continent_wise_countries.each do |continent, countries|
      sql = "select country_cd, id from
      (select distinct on (country_cd) country_cd, id, random() as rank, name, image_file from participants where country_cd IN
      (select distinct country_cd from participants where country_cd is not null and country_cd!='' and country_cd IN (#{continent_wise_countries[continent]}))
      and image_file is not null and image_file !=''
      order by country_cd, rank desc) data
      order by random()
      limit 3"

      participants << ActiveRecord::Base.connection.execute(sql).values
    end
    community_members_list = []
    participants.reject(&:empty?).each do |participant_obj|
      participant_obj.each do |p|
        user = Participant.find_by_id(p[1])
        lon, lat = Geocoder.search(p[0]).first.coordinates rescue nil
        next if lon.blank?

        community_members_list << {
          lat: lat.to_s,
          lon: lon.to_s,
          image: user.image_url.gsub('.com/images', '.com/32x32/images'),
          name: user.name
        }
      end
    end
    return community_members_list
  end

  def continent_wise_countries
    {
      "AF": "'DZ', 'AO', 'BW', 'BI', 'CM', 'CV', 'CF', 'TD', 'KM', 'YT', 'CG', 'CD', 'BJ', 'GQ', 'ET', 'ER', 'DJ', 'GA', 'GM', 'GH', 'GN', 'CI', 'KE', 'LS', 'LR', 'LY', 'MG', 'MW', 'ML', 'MR', 'MU', 'MA', 'MZ', 'NA', 'NE', 'NG', 'GW', 'RE', 'RW', 'SH', 'ST', 'SN'",

      "AS": "'AF' ,'AZ' ,'BH' ,'BD' ,'AM' ,'BT' ,'IO' ,'BN' ,'MM' ,'KH' ,'LK' ,'CN' ,'TW' ,'CX' ,'CC' ,'CY' ,'GE' ,'PS' ,'HK' ,'IN' ,'ID' ,'IR' ,'IQ' ,'IL' ,'JP' ,'KZ' ,'JO' ,'KP' ,'KR' ,'KW' ,'KG' ,'LA' ,'LB' ,'MO' ,'MY' ,'MV' ,'MN' ,'OM' ,'NP' ,'PK' ,'PH' ,'TL' ,'QA' ,'RU' ,'SA'",

      "EU": "'AL' ,'AD' ,'AZ' ,'AT' ,'AM' ,'BE' ,'BA' ,'BG' ,'BY' ,'HR' ,'CY' ,'CZ' ,'DK' ,'EE' ,'FO' ,'FI' ,'AX' ,'FR' ,'GE' ,'DE' ,'GI' ,'GR' ,'VA' ,'HU' ,'IS' ,'IE' ,'IT' ,'KZ' ,'LV' ,'LI' ,'LT' ,'LU' ,'MT' ,'MC' ,'MD' ,'ME' ,'NL' ,'NO' ,'PL' ,'PT' ,'RO' ,'RU' ,'SM'",

      "NA": "'AG' ,'BS' ,'BB' ,'BM' ,'BZ' ,'VG' ,'CA' ,'KY' ,'CR' ,'CU' ,'DM' ,'DO' ,'SV' ,'GL' ,'GD' ,'GP' ,'GT' ,'HT' ,'HN' ,'JM' ,'MQ' ,'MX' ,'MS' ,'AN' ,'CW' ,'AW' ,'SX' ,'BQ' ,'NI' ,'UM' ,'PA' ,'PR' ,'BL' ,'KN' ,'AI' ,'LC' ,'MF' ,'PM' ,'VC'",

      "OC": "'AS' ,'AU' ,'SB' ,'CK' ,'FJ' ,'PF' ,'KI' ,'GU' ,'NR' ,'NC' ,'VU' ,'NZ' ,'NU' ,'NF' ,'MP' ,'UM' ,'FM' ,'MH' ,'PW' ,'PG' ,'PN'",

      "SA": "'AR' ,'BO' ,'BR' ,'CL' ,'CO' ,'EC' ,'FK' ,'GF' ,'GY' ,'PY' ,'PE'"
    }
  end

end
