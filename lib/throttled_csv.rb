module ThrottledCsv
  
  def self.included(base)
    base.send :include, InstanceMethods
  end
  
  module InstanceMethods
    require 'fastercsv'
    
    protected
  
    def render_to_csv(options={})
      options.assert_valid_keys(:header,:fields,:label,:db_table,:scope,:include)
        
      filename = "#{Time.now.to_i}-#{options[:label]}.csv"
      headers.merge!(
        'Content-Type' => 'text/csv',
        'Content-Disposition' => "attachment; filename=\"#{filename}\"",
        'Content-Transfer-Encoding' => 'binary'
      )
      @performed_render = false

      render :status => 200, :text => Proc.new { |response, output|
    
        header = options[:header] || options[:fields].collect{|field| field.humanize}

        output.write FasterCSV.generate_line(header)

        last_id = 0
        while last_id do
          ar_options = build_ar_options(last_id,options)
          items = options[:scope].find(:all, ar_options)

          last_id = items.size > 0 ? items[-1].id : nil
          items.each { |s|
            data = options[:fields].collect do |column|
              value = column.split(/\b\.\b/).inject(s) do |result,expression| 
                break if result.nil?
                result.instance_eval(expression)
              end
              value.nil? ? "N/A" : value
            end
            output.write FasterCSV.generate_line(data)
          }
        end
      }
    end
  
    # this method enables our thottling by limiting the results and omitting the rows we've previously grabbed
    def build_ar_options(last_id,options={})
      default_options = {
        :conditions => ["#{options[:db_table]}.id > ?", last_id],
        :order => "#{options[:db_table]}.id asc",
        :limit => 100 
      }
      default_options.merge!({:include => options[:include]}) if options.key?(:include)
      default_options
    end
    
  end
end