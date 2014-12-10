require 'yetty'

module Yetty
  # User command class
  class User < Command

    # Invoke shelr record
    def execute!
      ui.info 'Configuration population (.yetty)'
      site_url = ui.ask('Site URL', 'http://localhost:4000')
      username = ui.ask('Username', ENV['USER'])
      provider = ui.ask('Storage Provider', 'aws')
      bucket = ui.ask('Storage bucket', 'yetty')
      credentials = Hash[
        ui.ask('Storage credentials(k=v,k=v...)').split(',').map{|x|x.split('=')}
      ]
      run_action('Writing configuration file (.yetty)') do
        File.open('.yetty', 'w+') do |file|
          file.write(
            MultiJson.dump(
              Smash.new(
                :site => {
                  :url => site_url
                },
                :user => {
                  :username => username,
                  :storage => {
                    :provider => provider,
                    :bucket => bucket,
                    :credentials => credentials
                  }
                }
              ),
              :pretty => true
            )
          )
        end
      end
    end

  end
end
