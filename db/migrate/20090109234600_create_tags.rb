class CreateTags < ActiveRecord::Migration
  def self.up
    # parent_id is treated as a selfsame reference by the redhill foreign key migrations plugin.
    create_table :tags do |t|
      t.column :parent_id, :integer
      t.column :tag, :string, :limit => 200, :null => false
      t.column :description, :string, :limit => 1000
      t.column :tag_path, :string, :limit => 5000
      t.column :position, :integer
      t.column :immutable, :boolean, :default => false
      t.timestamps
    end

    %W|tag position parent_id immutable|.each do|column|
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
    RAISE EXCEPTION 'Can not be your own parent!';
  END IF;
  -- TO DO: Check to ensure a node can't be set as a child of one of its children.
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER parent_checks BEFORE UPDATE ON tags
FOR EACH ROW EXECUTE PROCEDURE parent_checks();

CREATE TRIGGER position_fixes_on_insert BEFORE INSERT ON tags
FOR EACH ROW EXECUTE PROCEDURE position_fixes_on_insert();

CREATE TRIGGER position_fixes_on_update BEFORE UPDATE ON tags
FOR EACH ROW EXECUTE PROCEDURE position_fixes_on_update();
]
  execute %Q[
CREATE OR REPLACE FUNCTION getfulltagname(integer) RETURNS TEXT AS 'DECLARE
tagid ALIAS FOR $1;
tagfullname TEXT;
tagrecord RECORD;
BEGIN
    SELECT t.* INTO tagrecord FROM tags t  where id=tagid;
     tagfullname := tagfullname || tagrecord.tag;
     IF tagrecord.parent_id IS NOT NULL  THEN
           tagfullname := getfulltagname(tagrecord.parent_id) || '' -> '' || tagfullname ;
           RETURN tagfullname;
     ELSE
           RETURN tagfullname;
     END IF;
END'  LANGUAGE 'plpgsql';
  ]


    create_table :contacts_tags, :id => false do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.references :tag, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.timestamps
    end

    add_index :contacts_tags, ['contact_id', 'tag_id'], :unique => true
    %W|contact_id tag_id|.each do |column|
      add_index :contacts_tags, column
    end
    special = Tag.create(:tag => 'Special', :immutable => true)
    autotags = Tag.create(:tag => 'Autotags', :immutable => true, :parent => special)
    never_email = Tag.create(:tag => 'Never Email', :immutable => true, :parent => special)
    never_contact = Tag.create(:tag => 'Never Contact', :immutable => true, :parent => special)
    never_phone = Tag.create(:tag => 'Never Phone', :immutable => true, :parent => special)
    uncategorized = Tag.create(:tag => 'Uncategorized', :immutable => true)
  end

  def self.down
    execute 'drop trigger position_fixes_on_update on tags'
    execute 'drop trigger position_fixes_on_insert on tags'
    execute 'drop trigger parent_checks on tags'
    execute 'drop function parent_checks()'
    execute 'drop function position_fixes_on_update()'
    execute 'drop function position_fixes_on_insert()'
    drop_table :contacts_tags
    drop_table :tags
  end
end
