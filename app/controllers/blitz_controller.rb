class BlitzController < ApplicationController
  before_action :set_is_subscribed

  def index
  end

  def set_is_subscribed
    @is_subscribed = false
    if current_participant.present? && BlitzSubscription.where('participant_id = ? and end_date > ?', current_participant.id, Time.now).present?
      @is_subscribed = true
    end
  end

  def puzzles
    @categories = BlitzCategory.all()

    category = BlitzCategory.all()
    if params[:category].present?
      category = category.where(name: params[:category])
    end
    @puzzles = all_puzzles(category)
  end

  def dashboard
    @stats = get_stats
    @ongoing_data = ongoing_data
    @previous_data = previous_data
    @skill_data = skill_data
    @recommended_puzzles = puzzle_recommendation
    @activity_data = Participants::ActivityHeatmapService.new(participant: current_participant, blitz: true).call.value
  end

  private

  def get_stats
    {
      "puzzles" => Submission.where(challenge_id: BlitzPuzzle.all.pluck(:challenge_id), participant_id: current_participant.id).pluck(:challenge_id).uniq.count,
      "submissions" => Submission.where(challenge_id: BlitzPuzzle.all.pluck(:challenge_id), participant_id: current_participant.id).count,
      "apps" => 0,
      "likes" => 0,
      "views" => 0,
    }
  end

  def all_puzzles(category)
    puzzles_data = []
    puzzles = BlitzPuzzle.where('(start_date < NOW() OR start_date is null)').where(blitz_category: category).includes(:challenge, :blitz_category)
    puzzles.each do |puzzle|
      puzzles_data.push({
        "puzzle" => puzzle,
        "percentile" => puzzle.percentile(current_participant),
        "registered" => ChallengeParticipant.where(
                          challenge_id: puzzle.challenge.id,
                          registered: true,
                          participant_id: current_participant.id
                        ).count > 0
      })
    end
    return puzzles_data
  end

  def ongoing_data
    ongoing_data = []
    ongoing_puzzles = BlitzPuzzle.where(free: false, trial: false).where('end_date >= NOW()').reorder('start_date ASC').includes(:challenge, :blitz_category).limit(3)
    ongoing_puzzles.each do |puzzle|
      ongoing_data.push({
        "puzzle" => puzzle,
        "percentile" => puzzle.percentile(current_participant),
        "registered" => ChallengeParticipant.where(
                          challenge_id: puzzle.challenge.id,
                          registered: true,
                          participant_id: current_participant.id
                        ).count > 0
      })
    end
    return ongoing_data
  end

  def previous_data
    previous_data = []
    previous_puzzles = BlitzPuzzle.where('(end_date < NOW()) OR free=true OR trial=true')
                                  .where(challenge_id: ChallengeParticipant.where(participant_id: current_participant.id, registered: true).pluck(:challenge_id))
                                  .reorder('end_date DESC').includes(:challenge, :blitz_category)
    previous_puzzles.each do |puzzle|
      previous_data.push({
        "puzzle" => puzzle,
        "percentile" => puzzle.percentile(current_participant),
        "registered" => ChallengeParticipant.where(
                          challenge_id: puzzle.challenge.id,
                          registered: true,
                          participant_id: current_participant.id
                        ).count > 0
      })
    end
    return previous_data
  end

  def skill_data
    skill_matrix = {}
    categories = BlitzCategory.all.pluck(:name)
    categories.each do |c|
      skill_matrix[c] = 0
    end

    total = 0
    puzzles = BlitzPuzzle.where(challenge_id: ChallengeParticipant.where(participant_id: current_participant.id, registered: true).pluck(:challenge_id))
    puzzles.each do |puzzle|
      # TODO: better condition for marking problem as solved
      if puzzle.percentile(current_participant) > 10
        skill_matrix[puzzle.blitz_category.name] += 1
        total += 1
      end
    end

    skill_matrix.each do |k, v|
      skill_matrix[k] = ((v * 100)/([1, total].max)).ceil
    end
    
    return skill_matrix.to_json
  end

  def puzzle_recommendation
    recommendation_data = []
    recommended = {}
    unsolved = BlitzPuzzle.where(free: true).where.not(challenge_id: ChallengeParticipant.where(participant_id: current_participant.id, registered: true).pluck(:challenge_id)).includes(:challenge)
    unsolved.each do |puzzle|
      recommended[puzzle.id] = puzzle.challenge.submissions.count
    end
    puzzles = BlitzPuzzle.where(id: Hash[*recommended.sort_by {|k,v| v}.reverse.first(1).flatten(1)].keys).includes(:challenge, :blitz_category)
    puzzles.each do |puzzle|
      recommendation_data.push({
        "puzzle" => puzzle,
        "registered" => false,
        "percentile" => -1,
      })
    end
    return recommendation_data
  end

end