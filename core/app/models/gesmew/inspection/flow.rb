module Gesmew
 class Inspection < Gesmew::Base
   module Flow
    def self.included(klass)
      klass.class_eval do
        class_attribute :next_event_transitions
        class_attribute :previous_states
        class_attribute :inspection_flow
        class_attribute :inspection_steps
        class_attribute :removed_transitions

        self.inspection_steps ||= {}
        self.next_event_transitions ||= []
        self.previous_states ||= [:pending]
        self.removed_transitions ||= []

        def self.inspection_flow(&block)
          if block_given?
            @inspection_flow = block
            define_state_machine!
          else
            @inspection_flow
          end
        end

        def self.define_state_machine!
          self.inspection_steps ||= {}
          self.next_event_transitions ||= []
          self.previous_states ||= [:pending]
          self.removed_transitions ||= []

          instance_eval(&inspection_flow)

          klass = self

          # To avoid a ton of warnings when the state machine is re-defined
          StateMachines::Machine.ignore_method_conflicts = true
          # To avoid multiple occurrences of the same transition being defined
          # On first definition, state_machines will not be defined
          state_machines.clear if respond_to?(:state_machines)
          state_machine :state, initial: :pending, use_transactions: false, action: :save_state do
            klass.next_event_transitions.each { |t| transition(t.merge(on: :next)) }

            # Persist the state on the inspection
            after_transition do |inspection, transition|
              inspection.state = inspection.state
              inspection.state_changes.create(
                previous_state: transition.from,
                next_state: transition.to,
                name: 'inspection'
              )
              inspection.save
            end

            event :process do
              transition to: :processing, from: :pending
            end

            event :grade_and_comment do
              transition to: :grading_and_commenting, from: :processing
            end

            event :complete do
              transition to: :completed, from: :grading_and_commenting
            end
          end

          alias_method :save_state, :save
        end

        def self.go_to_state(name, options = {})
          self.inspection_steps[name] = options
          previous_states.each do |state|
            add_transition({from:state,to: name}.merge(options))
          end
          if options[:if]
            previous_states << name
          else
            self.previous_states = [name]
          end
        end

        def self.insert_inspection_step(name, options = {})
          before = options.delete(:before)
          after  = options.delete(:after) unless before
          after  = self.inspection_steps.keys.last unless before || after

          cloned_steps = self.inspection_steps.clone
          cloned_removed_transistions = self.removed_transistion.clone

          inspection_flow do
            cloned_steps.each_pair do |key, value|
              go_to_state(name,options) if key == before
              go_to_state(key, value)
              go_to_state(name, options) if key == after
            end
            cloned_removed_transistions.each do |transistion|
              remove_transitions(transistion)
            end
          end
        end

        def self.remove_inspection_step(name)
          cloned_steps = self.inspection_steps.clone
          cloned_removed_transitions = self.removed_transitions.clone
          inspection_flow do
            cloned_steps.each_pair do |key, value|
              go_to_state(key, value) unless key == name
            end
            cloned_removed_transitions.each do |transition|
              remove_transition(transition)
            end
          end
        end

        def self.remove_transition(options = {})
          self.removed_transitions << options
          self.next_event_transitions.delete(find_transition(options))
        end

        def self.find_transition(options = {})
          return nil if options.nil? || !options.include?(:from) || !options.include?(:to)
          self.next_event_transitions.detect do |transition|
            transition[options[:from].to_sym] == options[:to].to_sym
          end
        end

        def self.inspection_step_names
          self.inspection_steps.keys
        end

        def self.add_transition(options)
          self.next_event_transitions << { options.delete(:from) => options.delete(:to) }.merge(options)
        end

        def inspection_steps
          steps = (self.class.inspection_steps.each_with_object([]) do |(step, options), inspection_steps|
            next if options.include?(:if) && !options[:if].call(self)
            inspection_steps << step
          end).map(&:to_s)
          # Ensure there is always a complete step
          steps << "completed" unless steps.include?("completed")
          steps
        end

        def has_inspection_step?(step)
          step.present? && self.checkout_steps.include?(step)
        end

        def passed_inspection_step?(step)
          has_ispection_step?(step) && inspection_step_index(step) < inspection_step_index(state)
        end

        def inspection_step_index(step)
          self.inspection_steps.index(step).to_i
        end

        def can_go_to_state?(state)
          return false unless has_inspection_step?(self.state) && has_inspection_step?(state)
          inspection_step_index(state) > inspection_step_index(self.state)
        end
      end
    end
  end
 end
end
