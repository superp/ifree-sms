class IfreeSmsCreateMessages < ActiveRecord::Migration
  def self.up
    create_table :ifree_sms_messages do |t|
      # Messageable
      t.string  :messageable_type, :limit => 40
      t.integer :messageable_id
      
      # Sms info
      t.integer  :sms_id
      t.integer  :phone, :limit => 8
      t.integer  :service_number
      t.string   :sms_text
      t.datetime :now
      
      t.integer :status_id, :limit => 1, :default => 1
		  
      t.timestamps
    end

    add_index :ifree_sms_messages, [:messageable_type, :messageable_id]
    add_index :ifree_sms_messages, :sms_id
    add_index :ifree_sms_messages, :phone
    add_index :ifree_sms_messages, :service_number
    add_index :ifree_sms_messages, :status_id
  end

  def self.down
    drop_table :ifree_sms_messages
  end
end
