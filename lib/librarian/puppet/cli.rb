require 'librarian/helpers'

require 'librarian/cli'
require 'librarian/puppet'

module Librarian
  module Puppet

      class Cli < Librarian::Cli
      class_option :debug, :type => :boolean

      def initialize(*)
        super

        environment.ui.instance_variable_set(:@debug, true) if options[:debug]
      end

      module Particularity
        def root_module
          Puppet
        end
      end

      include Particularity
      extend Particularity

      source_root Pathname.new(__FILE__).dirname.join("templates")

      def init
        copy_file environment.specfile_name
      end

      desc "install", "Resolves and installs all of the dependencies you specify."
      option "quiet", :type => :boolean, :default => false
      option "verbose", :type => :boolean, :default => false
      option "line-numbers", :type => :boolean, :default => false
      option "clean", :type => :boolean, :default => false
      option "strip-dot-git", :type => :boolean
      option "path", :type => :string
      option "destructive", :type => :boolean, :default => false
      option "local", :type => :boolean, :default => false
      def install

        unless File.exist?('Puppetfile')
          say "Could not find Puppetfile in #{Dir.pwd}", :red
          exit 1
        end

        ensure!
        clean! if options["clean"]
        unless options["destructive"].nil?
          environment.config_db.local['destructive'] = options['destructive'].to_s
        end
        if options.include?("strip-dot-git")
          strip_dot_git_val = options["strip-dot-git"] ? "1" : nil
          environment.config_db.local["install.strip-dot-git"] = strip_dot_git_val
        end
        if options.include?("path")
          environment.config_db.local["path"] = options["path"]
        end

        environment.config_db.local['mode'] = options['local'] ? 'local' : nil

        resolve!
        install!
      end

      desc "package", "Cache the puppet modules in vendor/puppet/cache."
      option "quiet", :type => :boolean, :default => false
      option "verbose", :type => :boolean, :default => false
      option "line-numbers", :type => :boolean, :default => false
      option "clean", :type => :boolean, :default => false
      option "strip-dot-git", :type => :boolean
      option "path", :type => :string
      option "destructive", :type => :boolean, :default => false
      def package
        environment.vendor!
        install
      end

      def version
        say "librarian-puppet v#{Librarian::Puppet::VERSION}"
      end
    end
  end
end
