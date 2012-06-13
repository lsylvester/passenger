require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ruby/shared/loader_spec'
require 'ruby/shared/ruby_loader_spec'
require 'ruby/shared/rails/analytics_logging_extensions_spec'

module PhusionPassenger

describe "Rack loader" do
	include LoaderSpecHelper

	before :each do
		@stub = register_stub(RackStub.new("rack"))
	end

	def start(options = {})
		@loader = Loader.new(["ruby", "#{PhusionPassenger.helper_scripts_dir}/rack-loader.rb"], @stub.app_root)
		return @loader.start(options)
	end

	it_should_behave_like "a loader"
	it_should_behave_like "a Ruby loader"

	it "calls the starting_worker_process event with forked=false" do
		File.prepend(@stub.startup_file, %q{
			history_file = "history.txt"
			PhusionPassenger.on_event(:starting_worker_process) do |forked|
				::File.open(history_file, 'a') do |f|
					f.puts "worker_process_started: forked=#{forked}\n"
				end
			end
			::File.open(history_file, 'a') do |f|
				f.puts "end of startup file\n"
			end
		})
		result = start
		result[:status].should == "Ready"
		File.read("#{@stub.app_root}/history.txt").should ==
			"end of startup file\n" +
			"worker_process_started: forked=false\n"
	end
end

describe "Rack loader with Rails 3.0" do
	include LoaderSpecHelper

	before :each do
		@stub = register_stub(RackStub.new("rails3.0"))
	end

	def start(options = {})
		@loader = Loader.new(["ruby", "#{PhusionPassenger.helper_scripts_dir}/rack-loader.rb"], @stub.app_root)
		return @loader.start(options)
	end

	def rails_version
		return "3.0"
	end

	include_shared_example_group "analytics logging extensions for Rails"
end

end # module PhusionPassenger
