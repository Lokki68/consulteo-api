if ENV["ENABLE_SIDEKIQ_CRON"] == "true"
  schedule_file = "config/schedule.yml"

  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end

  Sidekiq::Cron::Job.create(
    name: "Unread messages notifier",
    cron: "0 * * * *",
    class: "UnreadMessagesNotifierJob"
  )
end
