ActiveAdmin.register BlitzSubscription do
  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      # Show all the practice problems, except the one already used.
      f.input :participant_id
      f.li '', class: "input" do
        f.label :start_date, class: 'label'
        f.date_field :start_date
      end
      f.li '', class: "input" do
        f.label :end_date, class: 'label'
        f.date_field :end_date
      end
      f.input :source
      f.actions
    end
  end
end
