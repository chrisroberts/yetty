require 'cowsay'
require 'base64'
require 'sinatra/base'

module Yetty
  class Site
    # Web UI
    class App < Sinatra::Base

      def bucket
        storage = Miasma.api(
          :type => :storage,
          :provider => :aws,
          :credentials => {
            :aws_access_key_id => ENV['MIASMA_AWS_ACCESS_KEY_ID'],
            :aws_secret_access_key => ENV['MIASMA_AWS_SECRET_ACCESS_KEY'],
            :aws_region => ENV['MIASMA_AWS_REGION'],
            :aws_bucket_region => 'us-west-2'
          }
        )
        bucket = storage.buckets.get('cr-test-00')
      end

      set :public_folder, File.join(File.dirname(__FILE__), 'static')

      get '/' do
        haml :index
      end

      get '/recordings' do
        haml :recordings
      end

      get '/recording/:info' do
        rec_path = Base64.urlsafe_decode64(params[:info])
        user, state, name = rec_path.split('/')
        rec_url = bucket.files.get(rec_path).url
        haml(
          :recording,
          :locals => {
            :user => user,
            :state => state,
            :name => name,
            :url => rec_url
          }
        )
      end

      get '/users' do
        file = bucket.files.get('userlist.json')
        users = file ? file.body[:users] : []
        haml(
          :users,
          :locals => {
            :users => users
          }
        )
      end

      get '/users/:username' do
        user_file = bucket.files.get(
          File.join(params[:username], 'userinfo.json')
        )
        if(user_file)
          user_info = MultiJson.load(user_file.read).to_smash
        else
          user_info = Smash.new
        end
        prefix = [params[:username], 'public'].join('/')
        records = bucket.files.filter(
          :prefix => [
            params[:username],
            'public'
          ].join('/')
        )
        haml(
          :user,
          :locals => {
            :username => params[:username],
            :user_info => user_info,
            :records => records
          }
        )
      end

      get '/about' do
        haml :about
      end

    end
  end
end
