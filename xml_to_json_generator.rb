require 'jekyll'  # Load Jekyll before checking the environment
require 'nokogiri'
require 'open-uri'
require 'json'

  module Jekyll
    class XMLToJSONGenerator < Generator
      safe true

      def generate(site)
        xml_sources = site.config['xml_to_json'] || []

        xml_sources.each do |source|
          xml_url = source['url']
          output_key = source['output']

          # Fetch and parse the XML data
          xml_data = Nokogiri::XML(URI.open(xml_url))

          # Convert the entire XML to a recursive hash
          json_data = xml_to_hash(xml_data.root)

          # Instead of saving to a file, inject directly into site.data
          site.data[output_key] = json_data
        end
      end

      private

      # Recursively converts an XML node and its children to a hash
      def xml_to_hash(node)
        result = {}

        # Add element's attributes
        node.attributes.each do |name, attr|
          result[name] = attr.value
        end

        # Add child elements recursively
        node.element_children.each do |child|
          result[child.name] ||= []
          result[child.name] << xml_to_hash(child)
        end

        # Add element's text content (if it exists)
        text_content = node.text.strip
        result['text'] = text_content unless text_content.empty?

        result
      end
    end
  end
