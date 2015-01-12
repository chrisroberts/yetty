require 'base64'
require 'bogo'
require 'sinatra/base'

module Yetty
  class Site
    # Web UI
    class App < Sinatra::Base

      include Bogo::Memoization

      set :protection, :except => :frame_options

      def config
        memoize(:config, :direct) do
          path = ENV['YETTY_SITE_CONFIG']
          unless(path)
            path = Command::DEFAULT_CONFIGURATION_FILES.detect do |check|
              full_check = File.expand_path(check)
              File.exists?(full_check)
            end
          end
          MultiJson.load(File.read(path)).to_smash
        end
      end

      def bucket
        storage = Miasma.api(
          :type => :storage,
          :provider => config.get(:site, :storage, :provider),
          :credentials => config.get(:site, :storage, :credentials)
        )
        storage.buckets.get(config.get(:site, :storage, :bucket))
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

      get '/embed/:info' do
        rec_path = Base64.urlsafe_decode64(params[:info])
        user, state, name = rec_path.split('/')
        rec_url = bucket.files.get(rec_path).url
        haml(
          :embed,
          :layout => :embed_layout,
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
        users = file ? MultiJson.load(file.body.readpartial).to_smash[:users] : []
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
