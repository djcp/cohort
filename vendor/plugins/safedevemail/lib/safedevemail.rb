# Safedevemail
module ActionMailer
	class Base
		private

    def perform_delivery_sendmail(mail)
			#check if environment is dev and dev_mailto is set
			unless sendmail_settings[:dev_mailto].nil?
				#send to dev_mailto
				destinations = sendmail_settings[:dev_mailto]	
			else
				#send to intended recipient
				destinations = mail.destinations
			end

			# Remove -t because that extracts the recipients from the headers
			arguments = sendmail_settings[:arguments].gsub(/(\s?-t$)|(-t\s)/,'').gsub(/-t([^\s]+)|-([^\s]+)t([^\s]*?)/,'-\1\2')

			IO.popen("#{sendmail_settings[:location]} #{arguments} #{destinations}","w+") do |sm|
				sm.print(mail.encoded.gsub(/\r/, ''))
				sm.flush
      end
    end

    def perform_delivery_smtp(mail)
			#check if environment is dev and dev_mailto is set
			unless smtp_settings[:dev_mailto].nil?
				#send to dev_mailto
				destinations = smtp_settings[:dev_mailto]	
			else
				#send to intended recipient
				destinations = mail.destinations
			end
			mail.ready_to_send

			Net::SMTP.start(smtp_settings[:address], smtp_settings[:port], smtp_settings[:domain],
					smtp_settings[:user_name], smtp_settings[:password], smtp_settings[:authentication]) do |smtp|
				smtp.sendmail(mail.encoded, mail.from, destinations)
			end
    end

	end
end
