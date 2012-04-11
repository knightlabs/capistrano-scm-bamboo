require 'typhoeus'
require 'json'

require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM
            
      class Bamboo < Base
        def head
          "#{variable(:plan_key)}-#{variable(:build_number)}"
        end

        def query_revision(revision)
          revision
          # return revision if revision =~ /^\d+$/
          # raise "invalid revision: #{revision}"
        end

        def checkout(revision, destination)
          response = Typhoeus::Request.get("#{repository}/result/#{variable(:plan_key)}/#{variable(:build_number)}.json?expand=artifacts", :username => variable(:scm_username), :password => variable(:scm_passphrase))
          result = JSON.parse(response.body)
          artifact = result["artifacts"]["artifact"].select { |artifact| artifact["name"] == variable(:artifact) }
          artifactUrl = artifact[0]["link"]["href"]
          
          %Q{TMPDIR=`mktemp -d` && cd $TMPDIR && wget -m -nH -q #{artifactUrl} && mv artifact "#{destination}" && rm -rf "$TMPDIR"}
        end

        alias_method :export, :checkout

        # def log(from, to=nil)
        #   log_build_message(from, to)
        #   log_scm_message(from, to)
        #   'true'
        # end

        def diff(from, to=nil)
          logger.info 'bamboo does not support diff'
          'true'
        end

        private

        # def authentication
        #   if variable(:jenkins_use_netrc)
        #     "--netrc"
        #   elsif variable(:scm_username) and variable(:scm_password)
        #     "--user '#{variable(:scm_username)}:#{variable(:scm_password)}'"
        #   else
        #     ""
        #   end
        # end

        # def use_unstable?
        #   !!variable(:jenkins_use_unstable)
        # end

        # def log_build_message(from, to=nil, message=nil)
        #   message = rss_all if message.nil?
        #   doc = REXML::Document.new(message).root
        #   logger.info ''
        #   logger.info "BUILD LOG"
        #   logger.info '========='
        #   REXML::XPath.each(doc,"./entry") do |entry|
        #     title = REXML::XPath.first(entry, "./title").text
        #     time = REXML::XPath.first(entry, "./updated").text
        #     build_number = get_build_number_from_rss_all_title(title).to_i
        #     if build_number > from.to_i and (to.nil? or build_number <= to.to_i)
        #       logger.info "#{time}\t#{title}"
        #     end
        #   end
        # end

        # def log_scm_message(from, to=nil, message=nil)
        #   message = rss_changelog if message.nil?
        #   doc = REXML::Document.new(message).root
        #   logger.info "SCM LOG"
        #   logger.info '======='
        #   REXML::XPath.each(doc,"./entry") do |entry|
        #     title = REXML::XPath.first(entry, "./title").text
        #     time = REXML::XPath.first(entry, "./updated").text
        #     content = REXML::XPath.first(entry, "./content").text
        #     build_number = get_build_number_from_rss_changelog_title(title).to_i
        #     if build_number > from.to_i and (to.nil? or build_number <= to.to_i)
        #       logger.info "#{time}\t#{title}"
        #       logger.info "#{content}"
        #     end
        #   end
        # end

        # def last_deploy_build(message = nil, opts={})
        #   message = rss_all if message.nil?
        #   use_unstable = opts[:use_unstable]
        #   use_unstable = use_unstable? if use_unstable.nil?
        #   doc = REXML::Document.new(message).root
        #   valid_end_strings = ['(back to normal)', '(stable)']
        #   if use_unstable
        #     valid_end_strings << '(unstable)'
        #   end
        #   REXML::XPath.each(doc,"./entry/title") do |title|
        #     title = title.text
        #     for x in valid_end_strings
        #       return get_build_number_from_rss_all_title(title) if title.end_with? x
        #     end
        #   end
        #   raise 'can not find a build suitable for deploy'
        # end

        # def auth_opts
        #   if jenkins_username and jenkins_password
        #     {:http_basic_authentication => [jenkins_username, jenkins_password]}
        #   else
        #     {}
        #   end
        # end

        # def artifact_zip_url(revision)
        #   "#{repository}/#{revision}/artifact/*zip*/archive.zip"
        # end

        # def jenkins_username
        #   @jenkins_username ||= begin
        #                           if variable(:jenkins_use_netrc)
        #                             rc = Net::Netrc.locate(jenkins_hostname)
        #                             raise ".netrc missing or no entry found" if rc.nil?
        #                             rc.login
        #                           elsif variable(:scm_username)
        #                             variable(:scm_username)
        #                           else
        #                             nil
        #                           end
        #                         end
        # end

        # def jenkins_password
        #   @jenkins_password ||= begin
        #                           if variable(:jenkins_use_netrc)
        #                             rc = Net::Netrc.locate(jenkins_hostname)
        #                             raise ".netrc missing or no entry found" if rc.nil?
        #                             rc.password
        #                           elsif variable(:scm_password)
        #                             variable(:scm_password)
        #                           else
        #                             nil
        #                           end
        #                         end
        # end
      end
    end
  end
end
