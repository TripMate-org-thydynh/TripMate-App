class TripMateMcpConfig {
  static const String mcpVersion = '1.0.0';
  static const String protocolName = 'Model Context Protocol';

  static const Map<String, dynamic> schema = {
    'server': {
      'name': 'tripmate-mcp-server',
      'version': mcpVersion,
      'description':
          'Exposes TripMate itinerary and checklists context to AI agents',
    },
    'tools': [
      {
        'name': 'get_trip_itinerary',
        'description': 'Retrieve the current trip itinerary and place nodes',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'tripId': {
              'type': 'string',
              'description': 'The unique identifier of the active trip',
            },
          },
          'required': ['tripId'],
        },
      },
      {
        'name': 'get_squad_checklist',
        'description':
            'Retrieve the active gear packing checklists and task status',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'tripId': {
              'type': 'string',
              'description': 'The unique identifier of the active trip',
            },
          },
          'required': ['tripId'],
        },
      },
      {
        'name': 'suggest_itinerary_proposal',
        'description':
            'Send an AI proposed alternative activity to the squad itinerary',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'tripId': {'type': 'string'},
            'day': {'type': 'integer'},
            'activityIndex': {'type': 'integer'},
            'proposalText': {'type': 'string'},
            'reason': {'type': 'string'},
          },
          'required': [
            'tripId',
            'day',
            'activityIndex',
            'proposalText',
            'reason',
          ],
        },
      },
    ],
  };
}
