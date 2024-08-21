def logger(task)
  *namespace, task_name = task.name.split(':')
  dir_path = Pathname.new("log/#{namespace.join('/')}")
  dir_path.mkdir unless dir_path.exist?
  log_path = dir_path.join("#{task_name}_#{Time.zone.now.strftime('%Y%m%d %H:%M:%S')}.log")
  Logger.new(log_path)
end

def measure_rss(task, enumerator, &proc)
  logger = logger(task)

  GC.start

  logger.info `ps -o rss= -p #{$$}`

  enumerator.with_index(1) do |record, i|
    proc.call record
    logger.info `ps -o rss= -p #{$$}` if (i % 10000).zero?
  end
end


namespace :measure_rss do
  desc "extendありでfind_eachのrssを計測"
  task with_extend: :environment do |t, args|
    module EmptyModule; end

    measure_rss(t, User.all.extend(EmptyModule).find_each) { |user| user.name }
  end

  desc "extendなしでfind_eachのrssを計測-profilerを実行"
  task without_extend: :environment do |t, args|
    module EmptyModule; end

    measure_rss(t, User.all.find_each) { |user| user.name }
  end
end
