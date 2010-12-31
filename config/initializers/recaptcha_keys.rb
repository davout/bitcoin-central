recaptcha_configuration = YAML::load(File.open(File.join(Rails.root, "config", "recaptcha.yml")))[Rails.env]

ENV['RECAPTCHA_PUBLIC_KEY']  = recaptcha_configuration['public']
ENV['RECAPTCHA_PRIVATE_KEY'] = recaptcha_configuration['private']