require "heap_profiler"

namespace :profiler do
  desc "extendありでheap-profilerを実行"
  task with_extend: :environment do
    binding.b
    module EmptyModule; end

    GC.start

    User.all.find_each do |user|
      user.name
      puts
    end
  end

  # desc "extendなしでheap-profilerを実行"
  # task without_extend: :environment do
  #   # 実行したい処理を記述する場所
  # end
end
