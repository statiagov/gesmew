Gesmew::Core::Engine.config.to_prepare do
  if Gesmew.user_class
    Gesmew.user_class.class_eval do
      include Gesmew::UserApiAuthentication
      before_save :add_fullname

      has_many :role_users, class_name: 'Gesmew::RoleUser', foreign_key: :user_id
      has_many :gesmew_roles, through: :role_users, class_name: 'Gesmew::Role', source: :role

      has_many :inspection_users, class_name: 'Gesmew::InspectionUser', :foreign_key => :user_id
      has_many :inspections, class_name: 'Gesmew::Inspection', :through => :inspection_users


      scope :text_search, ->(query) {search(
        m: 'or',
        firstname_start: query,
        lastname_start: query,
        email: query
      ).result}

      def has_gesmew_role?(role_in_question)
        gesmew_roles.where(name: role_in_question.to_s).any?
      end

      def number_of_complete_inspections
        inspections.where.not(completed_at: nil).count
      end

      def is_part_of_inspection?(inspection_number)
        inspections.where(number: inspection_number).any?
      end

      def analytics_id
        id
      end

      private
        def add_fullname
          self[:fullname] = "#{firstname} #{lastname}"
        end
    end
  end
end
