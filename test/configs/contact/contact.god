# frozen_string_literal: true

# God.contact(:email) do |c|
#   c.name = 'tom'
#   c.group = 'developers'
#   c.to_email = 'tom@lepton.local'
#   c.from_email = 'god@github.com'
#   c.from_name = 'God'
#   c.delivery_method = :sendmail
# end

# God.contact(:email) do |c|
#   c.name = 'tom'
#   c.group = 'developers'
#   c.to_email = 'tom@mojombo.com'
#   c.from_email = 'god@github.com'
#   c.from_name = 'God'
#   c.server_host = 'smtp.rs.github.com'
# end

# God.contact(:webhook) do |c|
#   c.name = 'tom'
#   c.url = "http://www.postbin.org/wk7guh"
# end

God.watch do |w|
  w.name = 'contact'
  w.interval = 5.seconds
  w.start = "ruby #{File.join(File.dirname(__FILE__), *%w[simple_server.rb])}"
  w.log = '/Users/tom/contact.log'

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 2
      c.transition = :start
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits) do |c|
      c.notify = { contacts: ['tom'], priority: 1, category: 'product' }
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 20.seconds
      c.transition = :unmonitored
      c.retry_in = 10.seconds
      c.retry_times = 2
      c.retry_within = 5.minutes
    end
  end
end
