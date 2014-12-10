require 'yetty'
require 'shelr'

module Yetty

  class Publisher < Shelr::Publisher

    attr_reader :file_name

    def initialize(file_name='yetty.json')
      @file_name = file_name
      super()
    end

    def prepare(id)
      out = {}
      ['meta', 'timing', 'typescript'].each do |file|
        out[file] = File.read(File.join(Shelr.data_dir(id), file))
      end

      meta = JSON.parse(out.delete('meta'))
      meta.each { |k,v| out[k] = v }
      STDOUT.print 'Description: '
      out['description'] = STDIN.gets.strip
      STDOUT.print 'Tags (ex: howto, linux): '
      out['tags'] = STDIN.gets.strip
      out['private'] = @private
      return out.to_json
    end

    def dump_filename
      file_name
    end

  end

  class Recorder < Shelr::Recorder

    def record!(options={})
      ensure_terminal_has_good_size
      check_record_dir
      with_lock_file do
        init_terminal
        request_metadata
        Shelr.terminal.puts_line
        STDOUT.puts "=> Your session started"
        STDOUT.puts "=> Please, do not resize your terminal while recording"
        STDOUT.puts "=> Press Ctrl+D or 'exit' to finish recording"
        Shelr.terminal.puts_line
        start_sound_recording if options[:sound]
        system(recorder_cmd)
        stop_sound_recording if options[:sound]
        save_as_typescript if Shelr.backend == 'ttyrec'
        Shelr.terminal.puts_line
        STDOUT.puts "=> Session finished"
      end
    end

  end
end

module Yetty
  # Record command class
  class Record < Command

    # Invoke shelr record
    def execute!
      Yetty::Recorder.record!(opts)
      Yetty::Publisher.new(arguments.first || 'yetty.json').dump('last')
    end

  end
end
