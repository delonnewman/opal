require 'native'

`Opal.exit = process.exit`

module Kernel
  @__child_process__ = `require('child_process')`
  `var __child_process__ = #{@__child_process__}`

  def system(*argv, exception: false)
    env = {}
    env = argv.shift if argv.first.is_a? Hash
    env = ENV.merge(env).to_n
    cmdname = argv.shift

    out = if argv.empty?
            `__child_process__.spawnSync(#{cmdname}, { shell: true, stdio: 'inherit', env: #{env} })`
          elsif Array === cmdname
            `__child_process__.spawnSync(#{cmdname[0]}, #{argv}, { argv0: #{cmdname[1]}, stdio: 'inherit', env: #{env} })`
          else
            `__child_process__.spawnSync(#{cmdname}, #{argv}, { stdio: 'inherit', env: #{env} })`
          end

    status = out.JS[:status]
    status = 127 if `status === null`
    pid = out.JS[:pid]

    $? = Process::Status.new(status, pid)
    raise "Command failed with exit #{status}: #{cmdname}" if exception && status != 0
    status == 0
  end

  def `(cmdline)
    Buffer.new(`__child_process__.execSync(#{cmdline})`).to_s.encode('UTF-8')
  end
end

module Process
  class Status
    def initialize(status, pid)
      @status, @pid = status, pid
    end

    def exitstatus
      @status
    end

    attr_reader :pid

    def success?
      @status == 0
    end

    def inspect
      "#<Process::Status: pid #{@pid} exit #{@status}>"
    end
  end
end

ARGV = `process.argv.slice(2)`

ARGV.shift if ARGV.first == '--'
