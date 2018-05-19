module UPM
  class Tool
    class << self

      def tools; @@tools; end

      def register_tools!
        Dir["#{__dir__}/tools/*.rb"].each { |lib| require_relative(lib) }
      end

      def os_release
        @os_release ||= begin
          open("/etc/os-release") do |io|
            io.read.scan(/^(\w+)="?(.+?)"?$/)
          end.to_h
        rescue Errno::ENOENT
          {}
        end
      end

      def current_os_names
        # eg: ID=ubuntu, ID_LIKE=debian
        os_release.values_at("ID", "ID_LIKE").compact
      end

      def nice_os_name
        os_release.values_at("PRETTY_NAME", "NAME", "ID", "ID_LIKE").first || 
          (`uname -o`.chomp rescue nil)
      end

      def installed
        @@tools.select { |tool| File.which(tool.identifying_binary) }
      end

      def for_os(os_names=nil)
        os_names = os_names ? [os_names].flatten : current_os_names

        tool = nil

        if os_names.any?
          tool = @@tools.find { |name, tool| os_names.any? { |name| tool.os.include? name } }&.last
        end

        if tool.nil?
          tool = @@tools.find { |name, tool| File.which(tool.identifying_binary) }&.last
        end

        if tool.nil?
          puts "Error: couldn't find a package manager."
        end

        tool
      end

    end
  end
end