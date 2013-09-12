module Spree
  class InvoiceController < BaseController
    
    def show
      @order = Order.find_by_id(params[:order_id])
      #@order.create_invoice(:user => @order.user)
      @address = @order.bill_address
      @invoice_print = current_spree_user.has_spree_role?(:admin) ? Spree::Invoice.find_or_create_by_order_id_and_user_id(@order.id, (@order ? @order.user_id : nil)) : current_spree_user.invoices.find_or_create_by_order_id(@order.id)
      if @invoice_print
        respond_to do |format|
          format.pdf  { send_data @invoice_print.generate_pdf, :filename => "#{@invoice_print.invoice_number}.pdf", :type => 'application/pdf' }
          format.html { render :file => Spree::Config[:invoice_template_path].to_s, :layout => false }
        end
      else
        if current_spree_user.has_spree_role?(:admin)
          return redirect_to(admin_orders_path, :notice => t(:no_such_order_found, :scope => :spree))
        else
          return redirect_to(orders_path, :alert => t(:no_such_order_found, :scope => :spree))
        end
      end
    end
  end
end
