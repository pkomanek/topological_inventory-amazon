module Amazon
  class Parser
    module ServicePlan
      def parse_service_plans(service_plan)
        launch_path = service_plan[:launch_path]
        artifact    = service_plan[:artifact]

        service_offering_uid  = service_plan[:service_offering].product_view_summary.product_id
        service_offering_name = service_plan[:service_offering].product_view_summary.name
        source_ref            = "#{service_offering_uid}__#{artifact.id}__#{launch_path.id}"

        service_offering      = lazy_find(:service_offerings, :source_ref => service_offering_uid) if service_offering_uid

        service_plan_data = TopologicalInventory::IngressApi::Client::ServicePlan.new(
          :source_ref         => source_ref,
          :name               => "#{service_offering_name} #{artifact.name} #{launch_path.name}",
          :description        => nil,
          :service_offering   => service_offering,
          :source_created_at  => nil,
          :create_json_schema => nil,
          :extra              => {
            :artifact                         => artifact,
            :launch_path                      => launch_path,
            :provisioning_artifact_parameters => service_plan[:provisioning_parameters]&.provisioning_artifact_parameters,
            :constraint_summaries             => service_plan[:provisioning_parameters]&.constraint_summaries,
            :usage_instructions               => service_plan[:provisioning_parameters]&.usage_instructions,
          }
        )

        collections[:service_plans].data << service_plan_data

        uid(service_plan_data)
      end
    end
  end
end
