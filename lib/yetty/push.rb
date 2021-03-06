require 'yetty'

module Yetty
  # Push command class
  class Push < Command

    # Push shelr json to storage
    def execute!
      run_action('Updating user list') do
        file = bucket.files.get('userlist.json')
        content = file ? MultiJson.load(file.body.readpartial).to_smash : Smash.new(:users => [])
        unless(content[:users].include?(user[:username]))
          content[:users].push(user[:username]).uniq!
          file = bucket.files.build
          file.name = 'userlist.json'
          file.content_type = 'application/json'
          file.body = MultiJson.dump(content)
          file.save
        end
      end
      filename = arguments.first
      run_action("Pushing file #{filename}") do
        key_name = File.basename(filename).sub(/\.[^\.]+$/, '')
        file_content = File.read(filename)
        data = MultiJson.load(file_content).to_smash
        state = data[:private] || options[:push][:private] ? 'private' : 'public'
        key_name = File.join(user[:username], state, "#{Time.now.to_i}-#{key_name}.json")
        file = bucket.files.build
        file.name = key_name
        file.content_type = 'application/json'
        file.body = file_content
        file.save
        encoded_key = Base64.urlsafe_encode64(file.name)
        Smash.new(
          :bucket => bucket.name,
          :key => file.name,
          :encoded_key => encoded_key,
          :link => options.get(:site, :url) ? File.join(options[:site][:url], 'recording', encoded_key) : 'Not configured!'
        )
      end
    end

  end
end
