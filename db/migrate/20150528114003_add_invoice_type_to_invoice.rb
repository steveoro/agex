class AddInvoiceTypeToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_type_id, :integer, :default => 0, :null => false, :comment => 'defines the type of automatic computations on the invoice'

    add_index :invoices, ["invoice_type_id"], :name => "invoice_type_id"
  end
end
