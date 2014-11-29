require 'yetty'
require 'shelr'

module Yetty
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
      Shelr::Publisher.new.dump('last')
    end

  end
end
