class CreateContacts < ActiveRecord::Migration
  def self.up

    create_table :contacts do |t|
      t.column :first_name, :string, :limit => 100
      t.column :middle_name, :string, :limit => 100
      t.column :last_name, :string, :limit => 100
      t.column :organization, :string, :limit => 250
      t.column :title, :string, :limit => 250
      t.timestamps
    end

    %W|first_name last_name|.each do|column|
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

    create_table :contact_addresses do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :street1, :string, :limit => 100
      t.column :street2, :string, :limit => 100
      t.column :city, :string, :limit => 100
      t.column :state, :string, :limit => 50
      t.column :zip, :string, :limit => 30
      t.column :country, :string, :limit => 100
      t.column :address_type, :string, :limit => 100
      t.column :is_primary, :boolean, :default => false
      t.timestamps
    end

    execute "ALTER TABLE contact_addresses 
          ADD CONSTRAINT contact_addresses_address_type_check
          CHECK (address_type IN ('personal', 'work','unknown'))"

    %W|street1 street2 city state zip country address_type is_primary|.each do|column|
      add_index :contact_addresses, column
    end

    create_table :contact_urls do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :url, :string, :limit => 1000, :null => false
      t.column :url_type, :string, :limit => 100
      t.column :is_primary, :boolean, :default => false
      t.timestamps
    end
    execute "ALTER TABLE contact_urls 
          ADD CONSTRAINT contact_urls_url_type_check
          CHECK (url_type IN ('personal','work','other','social','blog','rss','atom'))"

    %W|url url_type is_primary|.each do|column|
      add_index :contact_urls, column
    end

    create_table :contact_phones do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :phone, :string, :limit => 100, :null => false
      t.column :phone_type, :string, :limit => 100
      t.column :is_primary, :boolean, :default => false
      t.timestamps
    end

    execute "ALTER TABLE contact_phones 
          ADD CONSTRAINT contact_phones_phone_type_check
          CHECK (phone_type IN ('work','home','mobile','fax','other'))"

    %W|phone phone_type is_primary|.each do|column|
      add_index :contact_phones, column
    end

  end

  def self.down
    drop_table :contact_urls
    drop_table :contact_phones
    drop_table :contact_addresses
    drop_table :contact_emails
    drop_table :contacts
  end
end
