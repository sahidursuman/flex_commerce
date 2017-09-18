class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.monetize   :amount
      t.integer    :status,    index: true, default: 0
      t.integer    :processor, index: true
      t.integer    :variety,   index: true
      t.references :order,     index: true, type: :uuid, foreign_key: true
      t.jsonb      :processor_response

      t.timestamps
    end
  end
end
