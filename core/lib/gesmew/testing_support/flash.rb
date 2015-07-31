module Gesmew
  module TestingSupport
    module Flash
      def assert_flash_success(flash)
        flash = convert_flash(flash)

        within("[class='flash success']") do
          expect(page).to have_content(flash)
        end
      end

      def assert_successful_update_message(resource)
        flash = Gesmew.t(:successfully_updated, resource: Gesmew.t(resource))
        assert_flash_success(flash)
      end

      private

      def convert_flash(flash)
        if flash.is_a?(Symbol)
          flash = Gesmew.t(flash)
        end
        flash
      end
    end
  end
end
