Yostalgia.ApplicationSerializer = DS.ActiveModelSerializer.extend
  serializeAttribute: (record, json, key, attribute) ->
    if !attribute.options.readOnly
      return @_super(record, json, key, attribute)

  serializeBelongsTo: (record, json, relationship) ->
    if !relationship.options.readOnly
      return @_super(record, json, relationship)

  typeForRoot: (root) ->
    root = 'attachments' if root == 'cover_photos'
    root = 'attachments' if root == 'photos'
    @_super(root)


Yostalgia.ApplicationAdapter = DS.ActiveModelAdapter.extend
  namespace: 'api/v1'
  pathForType: (type) ->
    underscored = Ember.String.underscore(type)
    return Ember.String.pluralize(underscored)


Yostalgia.RawTransform = DS.Transform.extend
  deserialize: (serialized) ->
    serialized
  serialize: (deserialized) ->
    deserialized

Yostalgia.DateTransform = DS.DateTransform.extend
  serialize: (deserialized) ->
    moment(deserialized).format(Yostalgia.MS_DATE_FORMAT)

Yostalgia.OnlyDateTransform = DS.DateTransform.extend
  deserialize: (serialized) ->
    if !Ember.isEmpty(serialized)
      @_super(moment.utc(serialized).format('YYYY-MM-DD'))
    else
      @_super()

  serialize: (deserialized) ->
    if !Ember.isEmpty(deserialized)
      moment(deserialized).format('YYYY-MM-DD 00:00:00')
    else
      @_super(deserialized)

# when loading:
#   if we receive a time of midnight then remove timezone
#   else pass to super
# when saving:
#   if today then save with time information
#   else save only date with no timezone
Yostalgia.PostDateTransform = DS.DateTransform.extend
  deserialize: (serialized) ->
    if !Ember.isEmpty(serialized) && serialized.indexOf('00:00:00')
      @_super(serialized.replace('00:00Z', '00:00'))
    else
      @_super(serialized)
  serialize: (deserialized) ->
    if !Ember.isEmpty(deserialized) && moment(deserialized).isSame(new Date(), 'day')
      @_super(deserialized)
    else if !Ember.isEmpty(deserialized)
      moment(deserialized).format('YYYY-MM-DD 00:00:00')
    else
      @_super(deserialized)

# this is needed as Ember Data doesn't save hasMany by default
Yostalgia.SaveHasManySerializer = Yostalgia.ApplicationSerializer.extend
  serializeHasMany: (record, json, relationship) ->
    if !relationship.options.readOnly
      key = relationship.key
      serializedKey = Em.String.singularize(key).underscore(key) + '_ids'
      relationshipType = DS.RelationshipChange.determineRelationshipType record.constructor, relationship

      if relationshipType == 'manyToNone' || relationshipType == 'manyToMany' || relationshipType == 'manyToOne'
        json[serializedKey] = Em.get(record, key).mapBy('id')

Yostalgia.MessageSerializer = Yostalgia.SaveHasManySerializer.extend()
Yostalgia.PostSerializer = Yostalgia.SaveHasManySerializer.extend()

