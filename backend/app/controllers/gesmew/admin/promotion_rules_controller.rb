class Gesmew::Admin::PromotionRulesController < Gesmew::Admin::BaseController
  helper 'gesmew/promotion_rules'

  before_action :load_promotion, only: [:create, :destroy]
  before_action :validate_promotion_rule_type, only: :create

  def create
    # Remove type key from this hash so that we don't attempt
    # to set it when creating a new record, as this is raises
    # an error in ActiveRecord 3.2.
    promotion_rule_type = params[:promotion_rule].delete(:type)
    @promotion_rule = promotion_rule_type.constantize.new(params[:promotion_rule])
    @promotion_rule.promotion = @promotion
    if @promotion_rule.save
      flash[:success] = Gesmew.t(:successfully_created, :resource => Gesmew.t(:promotion_rule))
    end
    respond_to do |format|
      format.html { redirect_to gesmew.edit_admin_promotion_path(@promotion)}
      format.js   { render :layout => false }
    end
  end

  def destroy
    @promotion_rule = @promotion.promotion_rules.find(params[:id])
    if @promotion_rule.destroy
      flash[:success] = Gesmew.t(:successfully_removed, :resource => Gesmew.t(:promotion_rule))
    end
    respond_to do |format|
      format.html { redirect_to gesmew.edit_admin_promotion_path(@promotion)}
      format.js   { render :layout => false }
    end
  end

  private

  def load_promotion
    @promotion = Gesmew::Promotion.find(params[:promotion_id])
  end

  def validate_promotion_rule_type
    valid_promotion_rule_types = Rails.application.config.gesmew.promotions.rules.map(&:to_s)
    if !valid_promotion_rule_types.include?(params[:promotion_rule][:type])
      flash[:error] = Gesmew.t(:invalid_promotion_rule)
      respond_to do |format|
        format.html { redirect_to gesmew.edit_admin_promotion_path(@promotion)}
        format.js   { render :layout => false }
      end
    end
  end
end
