class CohortMigrationPostgresql

  def self.can_be_extended?(connection)
    # FIXME - inspect the server version and ensure it has plpgsql installed.
   return true 
  end

  def self.before_tag_table_destroy
    [
    'drop trigger position_fixes_on_update on tags',
    'drop trigger position_fixes_on_insert on tags',
    'drop trigger parent_checks on tags',
    'drop function parent_checks()',
    'drop function position_fixes_on_update()',
    'drop function position_fixes_on_insert()'
    ]
  end

  def self.after_tag_table_create
    [%Q[CREATE OR REPLACE FUNCTION position_fixes_on_update() RETURNS trigger AS $$
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
    -- Big fat negative - you can't be your own parent.
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
]]
  end
end
