if Jekyll.env == 'production'
  require 'nokogiri'
  require 'open-uri'
  require 'json'

  module Jekyll
    class XMLToJSONGenerator < Generator
      safe true

      def generate(site)
        xml_sources = site.config['xml_to_json']

        xml_sources.each do |source|
          xml_url = source['url']
          output_filename = source['output']

          # Fetch and parse the XML data
          xml_data = Nokogiri::XML(URI.open(xml_url))

          # Convert the entire XML to a recursive hash
          json_data = xml_to_hash(xml_data.root)

          # Save the JSON file to the _data folder
          File.open(File.join(site.source, '_data', "#{output_filename}.json"), 'w') do |f|
            f.write(JSON.pretty_generate(json_data))
          end
        end
      end

      private

      # Recursively converts an XML node and its children to a hash\
      def xml_to_hash(node)
        result = {}

        node.attributes.each do |name, attr|
          result[name] = attr.value
        end

        node.element_children.each do |child|
          result[child.name] ||= []
          result[child.name] << xml_to_hash(child)
        end

        result['text'] = node.text.strip unless node.text.strip.empty?

        result
      end
    end
  end
else
  Jekyll.logger.info "Skipping plugin in non-production environment."
end
