module Fastlane
    module Actions
      module SharedValues
        VALIDATE_SPECS_CUSTOM_VALUE = :VALIDATE_SPECS_CUSTOM_VALUE
      end
  
      class ValidateSpecsAction < Action
        def self.run(params)
          directories = params[:directories]
          UI.message "Directories to validate: #{directories}"
  
          lookup 'fdescribe(', directories
          lookup 'fcontext(', directories
          lookup 'fit(', directories
  
          # sh "shellcommand ./path"
  
          # Actions.lane_context[SharedValues::VALIDATE_SPECS_CUSTOM_VALUE] = "my_val"
        end
  
        def self.lookup(keyword, directories)
          results = directories.each_with_object([]) do |directory, list|
            output = `grep -r '#{keyword}' '#{directory}'`
            list << output if output
          end.select { |o| o.length > 0 }
  
          if results.count > 0
            UI.error "⛔️  We found some #{keyword} usage in your test code. (#{results.count} occurences)"
            UI.user_error!('QuikSpec Validation failed with errors.')
          else
            UI.success "✅  No #{keyword} is used in your test code."
          end
        end
  
        #####################################################
        # @!group Documentation
        #####################################################
  
        def self.description
          'Validate your QuickSpec classes to not use `fit`, `fcontext` or `fdescribe`'
        end
  
        def self.available_options
          [
            FastlaneCore::ConfigItem.new(key: :directories,
                                         is_string: false,
                                         description: 'The directories to validate')
          ]
        end
  
        def self.authors
          ["fousa/fousa"]
        end
  
        def self.is_supported?(platform)
          true
        end
      end
    end
  end
  