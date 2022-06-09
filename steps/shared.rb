require 'puppet_forge'
require 'httparty'

PuppetForge.user_agent = "Relay/1.0.0"

def relay_get(key, default=nil)
    response = HTTParty.get("#{ENV['METADATA_API_URL']}/spec?q=#{key}",
        {headers: {"Content-Type" => "application/json"}}
    )

    if response.success?
        return response['value']
    elsif response.unprocessable_entity?
        return default
    else
        raise RuntimeError.new(JSON.pretty_generate(response))
    end
end

def relay_output(key, data)
    HTTParty.put("#{ENV['METADATA_API_URL']}/outputs/#{key}",
        {headers: {"Content-Type" => "application/json"},
        body: data.to_json}
    )
end

def filter_attributes(mod, fields)
    fields.prepend :slug
    retval = {}
    fields.each do |field|
        field = field.to_sym
        retval[field] = mod.attributes[field] || mod.attributes[:current_release][field]
    end
    retval
end

def slenderize(attributes)
    [:readme, :changelog, :license, :reference, :tasks].each do |attr|
       attributes[:current_release].delete attr
    end
    attributes
end
