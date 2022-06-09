#!/usr/bin/env ruby
require_relative "./shared.rb"

begin
    slug = relay_get('slug')

    # don't bother with these API calls if we won't use them
    unless slug
        params = {}
        [
            'query',
             'owner',
             'endorsements',
             'has_tasks',
             'with_pdk',
             'premium',
             'os',
             'os_release',
             'puppet',
             'with_minimum_score',
             'release_within'
        ].each do |key|
            params[key] = relay_get(key)
        end

        # field selection
        fields = relay_get('fields')
    end

rescue RuntimeError => e
    puts e.message
    exit 1
end

if slug
    begin
        result = PuppetForge::Module.find(slug)
    rescue Faraday::ResourceNotFound
        puts "Module #{slug} not found on the Forge"
        exit 1
    end

    # The Relay API can only accept a step payload of just under 1MB. Some modules exceed
    # that, so check for failure and then retry with a slimmed down version of the module
    begin
        relay_output('module', result.attributes)
    rescue HTTParty::Error
        relay_output('module', slenderize(result.attributes))
    end
else
    results = PuppetForge::Module.where(params).unpaginated.to_a

    # in this case, we expect the user to observe when they're requesting fields that
    # generate too large of a payload for Relay and will need to adjust their fields list
    results.map! {|mod| filter_attributes(mod, fields)}
    relay_output('modules', results)
end
