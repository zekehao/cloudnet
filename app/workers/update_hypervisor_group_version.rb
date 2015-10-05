class UpdateHypervisorGroupVersion
  include Sidekiq::Worker
  sidekiq_options unique: true
  
  # Get HV zones from Onapp, match with existing location and update hv_group_version which is basically version of Onapp
  def perform
    squall = Squall::HypervisorZone.new(uri: ONAPP_CP[:uri], user: ONAPP_CP[:user], pass: ONAPP_CP[:pass])
    hv_zones = squall.list
    hv_zones.each do |hv_zone|
      begin
        location = Location.where(hv_group_id: hv_zone["id"]).first
        next if location.nil?
        location.update_attribute(:hv_group_version, hv_zone["supplier_version"])
      rescue Exception => e
        ErrorLogging.new.track_exception(e, extra: { source: 'UpdateHypervisorGroupVersion', hv_zone: hv_zone["id"] })
      end
    end
  end
end
