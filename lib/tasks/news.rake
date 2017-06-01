# Rake task, that periodically updates current news and broadcast it if needed
#
#   environment variables:
#     BACKGROUND - Anything, run task in background, if variable was set
#     PIDFILE - String, path to pid-file
#       default - ./tmp/pids/news.pid
#     INTERVAL - Integer, periodicity of update
#       default - 60 seconds
#
#   Examples
#     BACKGROUND=y rails news:run_observer &>>"$(pwd)/log/news_observer.log"
#
namespace :news do
  desc "update and broadcast news if needed"
  task run_observer: :environment do
    observer_logger = Logger.new(Rails.root.join("log", "news_observer.log"))

    if ENV["BACKGROUND"]
      Process.daemon(true, true)
    end

    File.open((ENV["PIDFILE"] || Rails.root.join("tmp", "pids", "news.pid")), "a") do |f|
      f << Process.pid
    end

    Signal.trap("TERM") do
      observer_logger.info "STOP news observer..."
      abort
    end

    observer_logger.info "START news observer..."

    loop do
      sleep ENV["INTERVAL"] || 60
      NewsHandler.update_and_broadcast_if_needed
      observer_logger.info "-------observer: news updated--------"
      observer_logger.info "@current_news.title: #{NewsHandler.instance_variable_get(:@current_news)&.title}"
      observer_logger.info "@need_broadcast: #{NewsHandler.instance_variable_get(:@need_broadcast)}"
    end
  end
end
