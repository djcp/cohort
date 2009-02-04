class CreateTags < ActiveRecord::Migration
  def self.up
    # parent_id is treated as a selfsame reference by the redhill foreign key migrations plugin.
    create_table :tags do |t|
      t.column :parent_id, :integer
      t.column :tag, :string, :limit => 200, :null => false
      t.column :description, :string, :limit => 1000
      t.column :position, :integer
      t.timestamps
    end

    %W|tag position parent_id|.each do|column|
      add_index :tags, column
    end

    execute %Q[CREATE OR REPLACE FUNCTION position_fixes_on_update() RETURNS trigger AS $$
DECLARE
  max_position INTEGER;
BEGIN

  if NEW.parent_id is NULL and OLD.parent_id is NULL then
    -- take no action.
    RETURN NEW;
  END IF;

  if NEW.parent_id = OLD.parent_id then
    -- take no action.
    RETURN NEW;
  END IF;

  if NEW.parent_id is NULL then
    EXECUTE 'SELECT max(position) from ' || quote_ident(TG_TABLE_NAME) || ' where parent_id is NULL' INTO STRICT max_position;
  ELSE
    EXECUTE 'SELECT max(position) from ' || quote_ident(TG_TABLE_NAME) || ' where parent_id = ' || quote_literal(NEW.parent_id) INTO STRICT max_position;
  END IF;

  IF max_position is null THEN
    max_position := 0;
  END IF;
  NEW.position = max_position + 1;

  if OLD.parent_id is NULL then
    EXECUTE 'UPDATE ' || quote_ident(TG_TABLE_NAME) || ' set position = position - 1 where parent_id is NULL and position > ' || quote_literal(OLD.position);
  ELSE
    EXECUTE 'UPDATE ' || quote_ident(TG_TABLE_NAME) || ' set position = position - 1 where parent_id = ' || quote_literal(OLD.parent_id) || ' and position > ' || quote_literal(OLD.position);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION position_fixes_on_insert() RETURNS trigger AS $$
DECLARE
  max_position INTEGER;
BEGIN

  if NEW.parent_id is null then
    EXECUTE 'SELECT max(position) from '|| quote_ident(TG_TABLE_NAME) || ' where parent_id is NULL' INTO STRICT max_position;
  ELSE
    EXECUTE 'SELECT max(position) from '|| quote_ident(TG_TABLE_NAME) || ' where parent_id = ' || quote_literal(NEW.parent_id) INTO STRICT max_position;
  END IF;

  IF max_position is null THEN
    max_position := 0;
  END IF;

  NEW.position = max_position + 1;
  RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION parent_checks() RETURNS trigger AS $$
BEGIN
  if NEW.parent_id = NEW.id THEN
    -- Big fat negative - you can't be your own parent. Except maybe in Kentucky.
    RAISE EXCEPTION 'Can\'t be your own parent!';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER position_fixes_on_insert BEFORE INSERT tags
FOR EACH ROW EXECUTE PROCEDURE position_fixes_on_insert();

CREATE TRIGGER position_fixes_on_update BEFORE UPDATE ON tags
FOR EACH ROW EXECUTE PROCEDURE position_fixes_on_update();
]

    create_table :contacts_tags do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.references :tag, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :relationship, :string, :limit => 50
      t.timestamps
    end

    add_index :contacts_tags, ['contact_id', 'tag_id'], :unique => true
    %W|contact_id tag_id relationship|.each do |column|
      add_index :contacts_tags, column
    end
  end

  def self.down
    execute 'drop trigger position_fixes_on_update on tags'
    execute 'drop trigger position_fixes_on_insert on tags'
    execute 'drop function position_fixes_on_update()'
    execute 'drop function position_fixes_on_insert()'
    drop_table :contacts_tags
    drop_table :tags
  end
end
