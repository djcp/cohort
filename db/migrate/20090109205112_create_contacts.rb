class CreateContacts < ActiveRecord::Migration
  def self.up

    create_table :contacts do |t|
      t.column :first_name, :string, :limit => 100
      t.column :last_name, :string, :limit => 100
      t.column :organization, :string, :limit => 100
      t.column :title, :string, :limit => 100
      t.column :work_url, :string, :limit => 300
      t.column :personal_url, :string, :limit => 300
      t.column :street1, :string, :limit => 100
      t.column :street2, :string, :limit => 100
      t.column :city, :string, :limit => 100
      t.column :state, :string, :limit => 2
      t.column :zip, :string, :limit => 15
      t.column :country, :string, :limit => 2
      t.column :phone, :string, :limit => 25
      t.timestamps
    end

    %W|first_name last_name street1 street2 city state zip country phone|.each do|column|
      add_index :contacts, column
    end

    create_table :contact_emails do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :email, :string, :limit => 200, :null => false
      t.column :email_type, :string, :limit => 100
      t.column :is_primary, :boolean, :default => false
      t.timestamps
    end
    execute "ALTER TABLE contact_emails 
          ADD CONSTRAINT contact_emails_email_type_check
          CHECK (email_type IN ('personal', 'work','unknown'))"

    %W|email email_type is_primary|.each do|column|
      add_index :contact_emails, column
    end
    add_index :contact_emails, ['contact_id','email'], :unique => true
  end

  def self.down
    drop_table :contact_emails
    drop_table :contacts
  end
end
