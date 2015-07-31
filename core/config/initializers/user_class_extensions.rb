Gesmew::Core::Engine.config.to_prepare do
  if Gesmew.user_class
    Gesmew.user_class.class_eval do
      include Gesmew::UserApiAuthentication

      has_many :role_users, class_name: 'Gesmew::RoleUser', foreign_key: :user_id
      has_many :gesmew_roles, through: :role_users, class_name: 'Gesmew::Role', source: :role


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
