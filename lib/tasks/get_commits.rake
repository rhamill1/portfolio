namespace :process do
  desc 'get all commits and format for highchart'
  task :get_commits => :environment do

    require 'json'
    require 'aws-sdk'
    require "s3"

    # client / get_repos
    gitAuthString = ENV['GIT_AUTHORIZATION_STRING']


    source_repos_owned_hash_unformatted = ENV['CURL_COMMAND']
    source_repos_owned_hash_unformatted = %x{ #{source_repos_owned_hash_unformatted} }

    # # format response
    repos_owned_hash = JSON.parse(source_repos_owned_hash_unformatted)

    # get repo names
    @repos = []
    repos_owned_hash.each do |project|
      @repos.push(project["name"])
    end

    # iterate through repos
    @all_compiled_commits = []
    @repos.each do |repo|
      # build request
      curl_repo_commits = "curl -H " + gitAuthString + " \
        https://api.github.com/repos/rhamill1/" + repo + "/commits?per_page=100"
      source_commits_hash_unformatted = %x{ #{curl_repo_commits} }

      commits_hash = JSON.parse(source_commits_hash_unformatted, :symbolize_names => true)

      # compile commits
      commits_hash.each do |commit|
        @all_compiled_commits.push([repo, commit[:commit][:author][:name], commit[:commit][:author][:date]])
      end
    end

    # remove non-me commits
    @compiled_commits = []
    def remove_non_author_commits(array)
      array.each do |commit|
        @compiled_commits.push(commit) if commit[1] == 'rhamill1'
      end
    end
    remove_non_author_commits(@all_compiled_commits)

    # get commits count
    grouped_commits = @compiled_commits.group_by{|e| [e[0], Date.parse(e[2]).at_beginning_of_week]}

    good_array = []
    grouped_commits.each do |key, value|
      new_value = value.length
      good_array.push([key[0], key[1], new_value])
    end

    # find min date
    sorted_for_min_date = good_array.sort_by{ |commit| commit[1] }
    min_date = sorted_for_min_date[0][1]

    # fill in 0 counts for the missing project/dates
    # get all mondays
    processing_monday = min_date
    all_mondays = []
    while processing_monday < Date.today do
      all_mondays.push(processing_monday)
      processing_monday += 7
    end

    # get all projects
    all_projects_w_dupes = []
    good_array.each do |project_monday|
      all_projects_w_dupes.push(project_monday[0])
    end
    all_projects = all_projects_w_dupes.uniq

    # create an array of arrays with a record of each project/monday and a third default value of 0
    total_array = []
    all_projects.each do |project|
      all_mondays.each do |monday|
        total_array.push([project, monday, 0])
      end
    end

    # add in records with actual values
    good_array.each do |project_monday|
      total_array.each do |zero_project_monday|
        project_monday[0] == zero_project_monday[0] && project_monday[1] == zero_project_monday[1] ? zero_project_monday[2] = project_monday[2] : nil
      end
    end

    final_array = []
    all_projects.each do |project|
      monday_count = []
      total_array.each do |project_monday|
        project == project_monday[0] ? monday_count.push(project_monday[2]) : nil
      end
        final_array.push([project, monday_count])
    end


    Aws.config.update(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_KEY'],
      force_path_style: true,
      region: ENV['AWS_REGION']
    )

    s3_client = Aws::S3::Client.new

    s3_client.delete_object(key: 'final_array.json', bucket: 'portfolio-json')

    s3_client.put_object(
      key: 'final_array.json',
      body: final_array.to_json,
      bucket: 'portfolio-json',
      content_type: 'application/json',
      acl: 'public-read'
    )

    first_monday_o_month_array = []
    all_mondays.each do |monday|
        monday.strftime("%d").to_i <= 7 ? first_monday_o_month_array.push(monday.strftime("%b %y")) : first_monday_o_month_array.push("")
    end

    s3_client.delete_object(key: 'first_monday_o_month_array.json', bucket: 'portfolio-json')

    s3_client.put_object(
      key: 'first_monday_o_month_array.json',
      body: first_monday_o_month_array.to_json,
      bucket: 'portfolio-json',
      content_type: 'application/json',
      acl: 'public-read'
    )


    puts 'process:get_commits ran successfully'

  end
end
