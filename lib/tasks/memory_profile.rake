require "heap-profiler"

def profile(task)
  *namespace, task_name = task.name.split(':')
  dir_path = Pathname.new("log/#{namespace.join('/')}")
  dir_path.mkdir unless dir_path.exist?
  profile_path = dir_path.join("#{task_name}_#{Time.zone.now.strftime('%Y%m%d_%H:%M:%S')}")

  GC.start

  HeapProfiler.start(profile_path)

  yield

  HeapProfiler.stop
  `bundle exec heap-profiler #{profile_path} > #{profile_path.join('result.txt')}`
end

namespace :memory_profile do
  namespace :find_each do
    desc "extendありでfind_eachのmemory profileを実行"
    task with_extend: :environment do |t, args|
      module EmptyModule; end

      profile(t) do
        User.all.extend(EmptyModule).find_each(batch_size: 1000) { |user| user.name }
      end
    end

    desc "extendなしでfind_eachのmemory profileを実行"
    task without_extend: :environment do |t, args|
      module EmptyModule; end

      profile(t) do
        User.all.find_each(batch_size: 1000) { |user| user.name }
      end
    end
  end

  namespace :generate_user_model do
    desc "extendなしでUser Relation生成のmemory profileを実行"
    task without_extend: :environment do |t, args|
      User

      module ActiveRecord
        module QueryMethods
          protected
            def build_where_clause(opts, rest = []) # :nodoc:
              opts = sanitize_forbidden_attributes(opts)

              case opts
              when String, Array
                parts = [klass.sanitize_sql(rest.empty? ? opts : [opts, *rest])]
              when Hash
                opts = opts.transform_keys do |key|
                  if key.is_a?(Array)
                    key.map { |k| klass.attribute_aliases[k.to_s] || k.to_s }
                  else
                    key = key.to_s
                    klass.attribute_aliases[key] || key
                  end
                end
                references = PredicateBuilder.references(opts)
                self.references_values |= references unless references.empty?

                parts = predicate_builder.build_from_hash(opts) do |table_name|
                  lookup_table_klass_from_join_dependencies(table_name)
                end
              when Arel::Nodes::Node
                parts = [opts]
              else
                raise ArgumentError, "Unsupported argument type: #{opts} (#{opts.class})"
              end

              Relation::WhereClause.new(parts)
            end
        end
      end

      module EmptyModule; end

      profile(t) do
        relation = User.all
        10000.times do |i|
          # relation = relation.where(name: "user#{i}")
          cl = relation.clone
          cl.send(:build_where_clause, {name: "user#{i}"})
          # cl.where!(name: "user#{i}")
        end
      end
    end

    desc "extendありでUser Relation生成のmemory profileを実行"
    task with_extend: :environment do |t, args|
      module EmptyModule; end

      User

      module ActiveRecord
        module QueryMethods
          protected
            def build_where_clause(opts, rest = []) # :nodoc:
              opts = sanitize_forbidden_attributes(opts)

              case opts
              when String, Array
                parts = [klass.sanitize_sql(rest.empty? ? opts : [opts, *rest])]
              when Hash
                opts = opts.transform_keys do |key|
                  if key.is_a?(Array)
                    key.map { |k| klass.attribute_aliases[k.to_s] || k.to_s }
                  else
                    key = key.to_s
                    klass.attribute_aliases[key] || key
                  end
                end
                references = PredicateBuilder.references(opts)
                self.references_values |= references unless references.empty?

                parts = predicate_builder.build_from_hash(opts) do |table_name|
                  lookup_table_klass_from_join_dependencies(table_name)
                end
              when Arel::Nodes::Node
                parts = [opts]
              else
                raise ArgumentError, "Unsupported argument type: #{opts} (#{opts.class})"
              end

              Relation::WhereClause.new(parts)
            end
        end
      end

      profile(t) do
        relation = User.all.extend(EmptyModule)
        10000.times do |i|
          # relation = relation.where(name: "user#{i}")
          cl = relation.clone
          cl.send(:build_where_clause, {name: "user#{i}"})
          # cl.where!(name: "user#{i}")
        end
      end
    end
  end
end
