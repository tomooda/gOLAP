Extension { #name : 'Morph' }

{ #category : '*Golap-Networking' }
Morph >> clearEvent: eventName [
	self eventHandler
		ifNotNil: [ :handler | handler clearAllSubscriptionsToEvent: eventName ]
]
