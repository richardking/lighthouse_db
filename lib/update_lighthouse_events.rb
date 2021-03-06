class UpdateLighthouseEvents < Struct.new(:ticket, :api)

  def create_lighthouse_event_from_version(event_type, version)
    event = LighthouseEvent.new(
      event:       event_type,
      body:        (version[:body][0..40959] rescue nil),
      milestone:   version[:milestone_title],
      state:       version[:state],
      happened_at: version[:created_at],
      assigned_lighthouse_id: version[:assigned_user_id],
      lighthouse_id:          version[:user_id],
      lighthouse_ticket_id:   ticket.id
    )

    event.token = api.token
    UpdateLighthouseUsers.new(event, api, ticket.namespace).update
    event.save
  end

  def update
    ticket.lighthouse_events.delete_all
    
    api.ticket(ticket.number)[:versions][1..-1].each do |version|
      if version[:body]
        create_lighthouse_event_from_version(:body, version)
      end
      version[:diffable_attributes].keys.each do |key|
        if [ :assigned_user, :state ].include?(key)
          create_lighthouse_event_from_version(key, version)
        end
      end
    end
  end
end