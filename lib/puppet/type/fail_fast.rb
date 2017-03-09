Puppet::Type.newtype(:fail_fast) do
  desc <<-'ENDOFDESC'
  A resource type intended to be used to mark a Puppet class for fast_fail
  behavior; to stop the Puppet run if any resources in a specified Puppet
  class have failures.

  The class parameter should be the name of the class to search for
  failures in. The name needs to be in proper case; first letter of each class
  component capitalized. E.g. "Profile::Compliance".

  The default value of the class parameter is the resource title.

  ENDOFDESC

  newparam :name do
    desc "The namevar of the fail_fast resource."
  end

  newproperty :class do
    desc "Name of the Puppet class to look for failures in"
    defaultto { @resource[:name] }

    def retrieve
      @resource[:class]
    end

    def insync?(pclass)
      report = Puppet::Util::Log.destinations.keys.find do |dest|
        dest.is_a?(Puppet::Transaction::Report)
      end

      class_has_failures = report.resource_statuses.any? do |title,event|
        event.containment_path.include?(pclass) && event.failed?
      end

      !class_has_failures
    end

    def sync
      Puppet::Application.stop!
    end

    def change_to_s(previous_value, new_value)
      "aborting Puppet run due to failures in #{previous_value}"
    end
  end
end
