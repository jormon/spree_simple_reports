Spree::Admin::ReportsController.class_eval do

  module OverrideMethods
    def initialize
      Spree::Admin::ReportsController.add_available_report!(:total_sales_of_each_product)
      super
    end
  end
  prepend OverrideMethods

  def total_sales_of_each_product
    @variants = Spree::Variant.joins(line_items: :order)
                .select("spree_variants.id, sku, SUM(spree_line_items.quantity) as quantity, SUM((spree_line_items.price * spree_line_items.quantity) + spree_line_items.adjustment_total) as total_price")
                .where.not('spree_orders.created_at' => nil)
                .where('spree_orders.created_at' => [created_at_gt..created_at_lt])
                .group('spree_variants.id')
  end

  private

  def created_at_gt
    params[:created_at_gt] = if params[:created_at_gt].blank?
      Date.today.beginning_of_month
    else
      Date.parse(params[:created_at_gt])
    end
  end

  def created_at_lt
    params[:created_at_lt] = if params[:created_at_lt].blank?
      Date.today
    else
      Date.parse(params[:created_at_lt])
    end
  end
end