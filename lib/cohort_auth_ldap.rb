module CohortAuthLDAP
  gem 'ruby-net-ldap'
  require 'net/ldap'

  def self.authenticate(mail,password)
    ldap_con = initialize_ldap_con(LDAP_BIND_USERNAME,LDAP_BIND_PASSWORD)
    mail_filter = Net::LDAP::Filter.eq( 'mail', mail )
    op_filter = Net::LDAP::Filter.eq('objectClass','organizationPerson')
    dn = ""
    ldap_con.search( :base => LDAP_BASE_TREE, :filter => op_filter && mail_filter, :attributes=> 'dn') do |entry|
      dn = entry.dn
    end
    login_succeeded = false
    unless dn.empty?
      ldap_con = initialize_ldap_con(dn,password)
      login_succeeded = true if ldap_con.bind
    end
    login_succeeded
  end

  def self.initialize_ldap_con(user,pass)
    Net::LDAP.new({
      :port => LDAP_BIND_PORT,
      :host => LDAP_BIND_HOST,
      :encryption => :simple_tls,
      :auth => {
            :method => :simple, 
            :username => user, 
            :password => pass
            }
      })
  end

end
