class BlitzController < ApplicationController
  before_action :set_is_subscribed
  before_action :authenticate_participant!, except: [:index, :waitlist]

  def index
    @testimonials = get_testimonials
  end

  def waitlist
    BlitzWaitlist.where(participant_id: current_participant&.id || -1, email: params[:email]).first_or_create
    redirect_to blitz_url, notice: 'Congratulations, you are in. You’ll hear from us soon! 🎉'
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
    if !@is_subscribed
      redirect_to blitz_url, notice: 'Sorry, you are not subscribed to AIcrowd Blitz'
    end
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

  def get_testimonials
    return [
      {
        "name": "Jakub",
        "message": "Blitz is a great tool for people building their careers in AI. If anyone wants to learn AI, I would highly recommend AIcrowd Blitz. You can constantly learn new concepts and apply them. ",
        "organisation": "Data Scientist DeepSense AI",
        "username": "jakub_bartczuk"
      },
      {
        "name": "Aman",
        "message": "Blitz boosted my learning by actively tackling real AI problems. It also provides theoretical knowledge. ",
        "organisation": "Lead Data Scientist ",
        "username": "aman_patkar"
      },
      {
        "name": "Mothy",
        "message": "I love the format of Blitz puzzle. They are compact but diverse. I was able to solve problems from a lot of domains in a short time. ",
        "organisation": "ML Engineer @ Quantiphi",
        "username": "g_mothy"
      },
      {
        "name": "Eric",
        "message": "As a practical learner, Blitz puzzles provided me the oppurtunity to solve problems from different domains of AI.The community is also very helpful and active. ",
        "organisation": "Student @ 42",
        "username": "eric_parisot"
      },
      {
        "name": "GlaDOS",
        "message": "For our university project, we picked Blitz puzzles. This was a unique experience and we learnt a lot in the process. As a newcomer in AI, Blitz problems are simple to solve.",
        "organisation": "Students @ Bielefeld University",
        "username": "kita"
      },
      {
        "name": "Konstantin",
        "message": "I was fascinated by Blitz because of its quirky and unique puzzles. It's a fun way to improve your AI skills in a short time",
        "organisation": "PhD in Mathematics, The Arctic University of Norway",
        "username": "konstantin_diachkov"
      },
      {
        "name": "Tverdov",
        "message": "The uniqueness of Blitz puzzles created motivation to learn & solve AI problems. It's more fun to solve AI problems when you can see your solutions work.",
        "organisation": "Program Manager @ Luxoft",
        "username": "ktverdov"
      },
      {
        "name": "Dennis",
        "message": "I enjoyed exploring different sub-domain of AI by solving Blitz puzzles. Blitz puzzles challenged me to solve complex AI problems. ",
        "organisation": "Linux System Administrator",
        "username": "denis_tsaregorodtsev"
      },
      {
        "name": "Devesh",
        "message": "AIcrowd is a unique Data Science platform as I was able to find problems for all domains. It saves me time and I am able to solve diverse puzzles, all in one place. ",
        "organisation": "Student @ BITS Pilani",
        "username": "devesh_darshan"
      },
      {
        "name": "Mark",
        "message": "Between my PhD and work, I did not find time to improve my skill. Blitz puzzles were interesting and fit into my schedule. ",
        "organisation": "PhD candidate @ Moscow University",
        "username": "markpotanin"
      },
      {
        "name": "Martin",
        "message": "Compared to other AI challenges, I found Blitz to be a fair levelled ground. The submission & scoring mechanisms are very simple and clever. Its a very enjoyable site to use.",
        "organisation": "Strategy and Architecture @ GM Technology",
        "username": "mkeywood"
      },
      {
        "name": "Robert",
        "message": "The Blitz Jigsaw puzzle was a bucket list item for me. Every puzzle makes you look at concepts in a different way, they are not generic. I used technique from bioinformatic to solve the jigsaw puzzle.",
        "organisation": "Principal Investigator @ SomaLogics",
        "username": "kirkdco"
      },
      {
        "name": "Sean",
        "message": "I started learning AI during lockdown. With Blitz I was able to continue improving my skills despite my busy schedule. The puzzle are fun & convinient to solve",
        "organisation": "ML Intern @ NVIDIA",
        "username": "sean_benhur"
      },
      {
        "name": "Vadim",
        "message": "I love learning a new skill. Apart from school, I spend my time learning AI by solving Blitz problems. It benefited me a lot! ",
        "organisation": "High School Student",
        "username": "toefl"
      }
    ]
  end

end