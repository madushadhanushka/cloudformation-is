#!/usr/bin/env ruby
# ----------------------------------------------------------------------------
#
# Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------

require 'yaml'

lockfile = '/var/lib/puppet/state/puppetdlock'
statefile = '/var/lib/puppet/state/state.yaml'
summaryfile = '/var/lib/puppet/state/last_run_summary.yaml'

running = false

lastrun_failed = false
failcount = nil

if File.directory?(File.dirname(lockfile))
  first_run = true
  if File.exists?(lockfile)
    running = true
  end
else
  first_run = false
end

failcount = 0
successcount = 0

if File.exist?(summaryfile)
  begin
    summary = YAML.load_file(summaryfile)
    # machines that outright failed to run like on missing dependencies
    # are treated as huge failures.  The yaml file will be valid but
    # it wont have anything but last_run in it
    unless summary.include?('events')
      failcount = 99
    else
      # and unless there are failures, the events hash just wont have the failure count
      failcount = summary['events']['failure'] || 0
      successcount = summary['events']['success'] || 0
    end
  rescue
    failcount = 0
    successcount = 0
    summary = nil
  end
end

if first_run == false
  puts 'FATAL'
elsif running == true
  puts 'RUNNING'
elsif failcount == 0 && successcount >= 1
  puts 'SUCCESS'
elsif failcount >= 1
  puts 'FAILURE'
else
  puts 'UNKNOWN'
end