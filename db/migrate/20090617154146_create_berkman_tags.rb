class CreateBerkmanTags < ActiveRecord::Migration
  def self.up
    if ENV['BERKMAN']
      academic_years = ['2007-08','2008-09','2009-10']

      all_berkman = Tag.create(:title => 'All Berkman', :removable => false)
      ['Affiliates', 'Alumni','Faculty','Fellows','Friends','Interns','Staff'].each do |sub_tag|
        tag = Tag.create(:title => sub_tag, :parent => all_berkman, :removable => false)
        if ['Fellows','Interns','Staff'].include?(sub_tag)
          academic_years.each do |year_tag|
            Tag.create(:title => year_tag, :removable => false, :parent => tag)
          end
        end
      end

      events = Tag.create(:title => 'Events', :removable => false)
      ['Luncheon Series','Law Lab Speaker Series','Digital Natives Forum Series','Cyberscholars','Guests','Meetings'].each do |event|
        Tag.create(:title => event, :parent => events, :removable => false)
      end

      projects = Tag.create(:title => 'Projects', :removable => false)
      ['Center for Citizen Media'].each do |project|
        Tag.create(:title => project, :parent => projects, :removable => false)
      end

      Tag.create(:title => 'Press', :removable => false)

      people = Tag.create(:title => 'People', :removable => false)
      ['Students','Intern Applicants','Fellowship Applicants'].each do |group|
        tag = Tag.create(:title => group, :parent => people, :removable => false)
        if ['Intern Applicants','Fellowship Applicants'].include?(group)
          academic_years.each do |year_tag|
            Tag.create(:title => year_tag, :removable => false, :parent => tag)
          end
        end
      end

      orgs = Tag.create(:title => 'Organizations', :removable => false)
      ['Networked organizations','Oxford Internet Institute','MIT','Stanford','University of St. Gallen','Aspen Institute','Gruter Institute','University of Toronto','Yale','Brown University','University of Berkeley California','Princeton University','New York University','Harvard University'].each do |org|
        tag = Tag.create(:title => org, :parent => orgs, :removable => false)
        if org == 'MIT'
          Tag.create(:title => 'Center for Future Civic Media', :parent => tag)
          Tag.create(:title => 'Comparative Media Studies', :parent => tag)
          Tag.create(:title => 'Media Lab', :parent => tag)
          Tag.create(:title => 'Center for Collective Intelligence', :parent => tag)
        elsif org == 'Stanford'
          Tag.create(:title => 'Center for Internet & Society', :parent => tag)
        elsif org == 'University of Toronto'
          Tag.create(:title => 'Citizen lab', :parent => tag)
        elsif org == 'Yale'
          Tag.create(:title => 'Information Society Project', :parent => tag)
        elsif org == 'Brown University'
          Tag.create(:title => 'Watson Center', :parent => tag)
        elsif org == 'University of Berkeley California'
          Tag.create(:title => 'Samuelson Clinic', :parent => tag)
        elsif org == 'Princeton University'
          Tag.create(:title => 'center for information technology policy', :parent => tag)
        elsif org == 'Harvard University'
          ['Provost','Office of Sponsored Partnerships','Harvard Law School','Harvard Kennedy School','Harvard Business School','Harvard College'].each do |dept|
          Tag.create(:title => dept, :parent => tag)
          end
        end
      end

      companies = Tag.create(:title => 'Companies', :removable => false)
      ['Microsoft','Google','IBM'].each do |corp|
        Tag.create(:title => corp, :parent => companies, :removable => false)
      end
      Tag.create(:title => 'Vendors', :removable => false)
      funders = Tag.create(:title => 'Funders / Foundations', :removable => false)
      ['MacArthur Foundation','Sloan Foundation','Kauffman Foundation','Prospective','Solid No'].each do |ff|
        Tag.create(:title => ff, :removable => false, :parent => funders)
      end

    end
    special = Tag.create(:title => 'Special', :removable => false)
    autotags = Tag.create(:title => 'Autotags', :removable => false, :parent => special)
    never_email = Tag.create(:title => 'Never Email', :removable => false, :parent => special)
    never_contact = Tag.create(:title => 'Never Contact', :removable => false, :parent => special)
    never_phone = Tag.create(:title => 'Never Phone', :removable => false, :parent => special)
    uncategorized = Tag.create(:title => 'Uncategorized', :removable => false)
  end

  def self.down
  end
end
