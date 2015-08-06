Gesmew::Core::Engine.config.to_prepare do
  if Gesmew.user_class
    Gesmew.user_class.class_eval do
      include Gesmew::UserApiAuthentication

      belongs_to :contact_information

      has_many :role_users, class_name: 'Gesmew::RoleUser', foreign_key: :user_id
      has_many :gesmew_roles, through: :role_users, class_name: 'Gesmew::Role', source: :role

      has_many :inspection_users, class_name: 'Gesmew::InspectionUser'
      has_many :inspections, class_name: 'Gesmew::Inspection', foreign_key: :inspection_id, through: :inspection_users, source: :inspection


      # has_gesmew_role? simply needs to return true or false whether a user has a role or not.
      def has_gesmew_role?(role_in_question)
        gesmew_roles.where(name: role_in_question.to_s).any?
      end

      def analytics_id
        id
      end
    end
  end
end
