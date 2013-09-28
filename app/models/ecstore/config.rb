#encoding:utf-8
class Ecstore::Config < Ecstore::Base
      self.table_name = "sdb_imodec_configs"
      attr_accessible :name,:key,:value

      validates :key, :presence=>{ :presence=>true, :message=>"key不能为空"},
                              :format=> { :with=>/[\w_]+/i, :message=>"key格式不正确", :if=>"key.present?" },
                              :uniqueness=>{ :message=> "key不能重复",:if=>"key.present?" }

      def self.search_value
            search_config  = self.find_by_key("search_key")
            search_config.value if search_config
      end
      
      class << self

            def get(k)
                  config = self.find_by_key(k.to_s)
                  return config.value if config
                  nil
            end

            def report_top
                  report = self.find_by_key("report_top")
                  return []  unless report
                  _new_arr = []
                  arr = report.value.split("|")
                  (arr.size/2).times  do
                  	_new_arr << arr.drop(2)
                  end
                  _new_arr
            end

            def report_right
                  report = self.find_by_key("report_top")
                  return []  unless report
                  _new_arr = []
                  arr = report.value.split("|")
                  (arr.size/2).times  do
                  	_new_arr << arr.drop(2)
                  end
                  _new_arr
            end
      end
end