ActiveAdmin.register BlitzPuzzle do
  includes :challenge, :blitz_category

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      # Show all the practice problems, except the one already used.
      f.input :challenge, as: :searchable_select, collection: Challenge.where.not(id: BlitzPuzzle.all.where.not(id: f.object.id).pluck(:challenge_id))
      f.input :app_link
      f.input :baseline_link
      f.input :difficulty, as: :select, collection: {'Easy': 1, 'Medium': 2, 'Hard': 3}
      f.input :blitz_category_id, as: :searchable_select, collection: BlitzCategory.all
      f.li '', class: "input" do
        f.label :start_date, class: 'label'
        f.date_field :start_date
      end
      f.input :duration
      f.input :free
      f.input :trial
      f.actions
    end
  end
end
