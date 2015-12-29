module Recaptcha
  module ClientHelper
    # Your public API can be specified in the +options+ hash or preferably
    # using the Configuration.
    def recaptcha_tags(options = {})
      public_key = options[:public_key] || Recaptcha.configuration.public_key!

      script_url = Recaptcha.configuration.api_server_url(ssl: options[:ssl])
      script_url += "?hl=#{options[:hl]}" unless options[:hl].to_s == ""
      fallback_uri = "#{script_url.chomp('.js')}/fallback?k=#{public_key}"

      data_attributes = [:theme, :type, :callback, :expired_callback, :size]
      data_attributes = options.each_with_object({}) do |(k, v), a|
        a[k] = v if data_attributes.include?(k)
      end
      data_attributes[:sitekey] = public_key
      data_attributes[:stoken] = Recaptcha::Token.secure_token if options[:stoken] != false
      data_attributes = data_attributes.map { |k,v| %{data-#{k.to_s.tr('_','-')}="#{v}"} }.join(" ")

      html = %{<script src="#{script_url}" async defer></script>\n}
      html << %{<div class="g-recaptcha" #{data_attributes}></div>\n}

      if options[:noscript] != false
        html << <<-HTML
          <noscript>
            <div>
              <div>
                <div>
                  <iframe src="#{fallback_uri}" frameborder="0" scrolling="no">
                  </iframe>
                </div>
                <div>
                  <textarea id="g-recaptcha-response" name="g-recaptcha-response"
                    class="g-recaptcha-response" value="">
                  </textarea>
                </div>
              </div>
            </div>
          </noscript>
        HTML
      end

      html.respond_to?(:html_safe) ? html.html_safe : html
    end
  end
end
